import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:prayerunitesss/ui/screens/login_page/login_page.dart';
import 'package:prayerunitesss/utils/app_urls.dart';
import 'package:prayerunitesss/utils/home/home_utils.dart';
import 'package:provider/provider.dart';

import '../../../model/api/customer/customer_all_details_model/customer_all_details.dart';
import '../../../model/api/prayer/prayer_times.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/prayer_provider/prayer_timing_provider.dart';
import '../../../service/api/customer/customer_service_api.dart';
import '../../../service/api/prayer/prayer_timing_api.dart';
import '../../../utils/home/positioned_reuse_widget.dart';
import 'home_page_mosque_header.dart';
import 'my_devices_and_prayers.dart';

class PrayerHomePage extends StatefulWidget {
  const PrayerHomePage({super.key});

  @override
  State<PrayerHomePage> createState() => _PrayerHomePageState();
}

class _PrayerHomePageState extends State<PrayerHomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  StreamSubscription<geo.ServiceStatus>? _locationStatusSubscription;
  DateTime selectedDate = DateTime.now();
  bool hasActiveSubscription = false;

  PrayerTimes prayerTimes = PrayerTimes(
    fajr: '--:--',
    dhuhr: '--:--',
    asr: '--:--',
    maghrib: '--:--',
    isha: '--:--',
  );
  bool isLoading = true;
  String errorMessage = '';
  late PrayerController _prayerController;
  Timer? _timer;
  Duration _timeRemaining = const Duration();
  Map<String, dynamic> _nextPrayer = {
    'name': '--',
    'arabic': '--',
    'time': DateTime.now(),
  };
  DateTime? currentBackPressTime;
  CustomerAllDetails? customerDetails;

  @override
  void initState() {
    super.initState();

    _prayerController = PrayerController(PrayerService(http.Client()), context);
    _checkPermissions();
    _initAlarms();

    _fetchCustomerDetails();

    _initLocationMonitoring(); // Handles initial fetch and listens for changes
    _locationStatusSubscription = HomeUtils.locationServiceStatusStream.listen((
      geo.ServiceStatus status,
    ) async {
      if (status == geo.ServiceStatus.enabled && mounted) {
        await _fetchPrayerTimes();
      }
    });
    _startTimer();
  }

  Future<void> _initAlarms() async {
    // Request notification permission
    final status = await Permission.notification.request();
    if (status.isGranted) {
      // Schedule alarms when prayer times are loaded
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchPrayerTimes();
      });
    }
  }

  Future<void> _fetchCustomerDetails() async {
    try {
      final customerServices = CustomerServices(baseUrl: AppUrls.appUrl);
      final details = await customerServices.getAllCustomerDetails();
      if (mounted) {
        setState(() {
          customerDetails = details;
        });
      }

      hasActiveSubscription =
          customerDetails!.data?.devices.any(
            (device) => device.subscription?.subscriptionStatus == true,
          ) ??
          false;
    } catch (e) {
      debugPrint('Error fetching customer details: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();

    _locationStatusSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkPermissionsAndFetch() async {
    // First check location permission
    final hasPermission = await HomeUtils.checkLocationPermission(context);
    if (!hasPermission) return;

    // If we have permission, fetch prayer times
    await _fetchPrayerTimes();
  }

  Future<void> _checkPermissions() async {
    try {
      // Check location permission (for prayer times)
      var locationStatus = await Permission.location.status;
      if (!locationStatus.isGranted) {
        locationStatus = await Permission.location.request();
        if (!locationStatus.isGranted) {
          if (mounted) HomeUtils.showPermissionDeniedDialog(context);
        }
      }

      // Check notification permission (if your app uses notifications)
      var notificationStatus = await Permission.notification.status;
      if (!notificationStatus.isGranted) {
        notificationStatus = await Permission.notification.request();
      }

      // For Android-specific permissions
      if (Platform.isAndroid) {
        // Check storage permission
        var storageStatus = await Permission.storage.status;
        if (!storageStatus.isGranted) {
          storageStatus = await Permission.storage.request();
        }

        // Check microphone permission if needed
        var micStatus = await Permission.microphone.status;
        if (!micStatus.isGranted) {
          micStatus = await Permission.microphone.request();
        }
      }
    } on PlatformException catch (e) {
      debugPrint("Permission error: ${e.toString()}");
      if (!mounted) return;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      final now = DateTime.now();
      _nextPrayer = HomeUtils().getNextPrayer(prayerTimes, now);
      _timeRemaining = _nextPrayer['time'].difference(now);

      setState(() {});
    });
  }

  Future<void> _fetchPrayerTimes() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final times = await _prayerController.getPrayerTimes(selectedDate);
      if (!mounted) return;

      setState(() {
        prayerTimes = times;
        isLoading = false;
      });

      // Schedule the new prayer alerts

      _timer?.cancel();
      _startTimer();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage =
            e.toString().contains('authenticated') ||
                    e.toString().contains('Session expired')
                ? 'Please login again.'
                : 'Failed to load prayer times. Please try again.';
        isLoading = false;
      });

      if (e.toString().contains('Location services') ||
          e.toString().contains('Location permission')) {
        // The overlay is already shown by checkLocationPermission
      } else if (e.toString().contains('authenticated') ||
          e.toString().contains('Session expired')) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      }
    }
  }

  void _initLocationMonitoring() {
    // Listen for location service status changes
    _locationStatusSubscription = HomeUtils.locationServiceStatusStream.listen((
      geo.ServiceStatus status,
    ) async {
      if (status == geo.ServiceStatus.enabled && mounted) {
        await _fetchPrayerTimes();
      }
    });

    // Initial check
    _checkPermissionsAndFetch();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final _ = Provider.of<AuthProvider>(context);
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    // List of prayers data for ListView.builder
    final List<Map<String, dynamic>> prayers = [
      {'name': 'Fajr', 'arabic': 'الفجر', 'time': prayerTimes.fajr},
      {'name': 'Dhuhr', 'arabic': 'الظهر', 'time': prayerTimes.dhuhr},
      {'name': 'Asr', 'arabic': 'العصر', 'time': prayerTimes.asr},
      {'name': 'Maghrib', 'arabic': 'المغرب', 'time': prayerTimes.maghrib},
      {'name': 'Isha', 'arabic': 'العشاء', 'time': prayerTimes.isha},
    ];

    return WillPopScope(
      onWillPop: () async {
        DateTime now = DateTime.now();
        if (currentBackPressTime == null ||
            now.difference(currentBackPressTime!) >
                const Duration(seconds: 2)) {
          currentBackPressTime = now;
          Fluttertoast.showToast(msg: "Press back again to exit");
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0C5E38),
        body: Column(
          children: [
            // In PrayerHomePage's build method, update the Stack like this:
            // In PrayerHomePage's build method
            Stack(
              children: [
                // 1. Main header content (with interactive elements)
                HomePageMosqueHeader(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  timeRemaining: _timeRemaining,
                  nextPrayer: _nextPrayer,
                  hasActiveSubscription: hasActiveSubscription,
                ),

                // 2. Decorative images (with hit testing disabled where they overlap buttons)
                PositionedImageWidget(
                  top: screenHeight * 0.05,
                  right: screenWidth * 0.34,
                  offsetY: screenHeight * 0.01,
                  imagePath: "assets/images/lamp_shot.png",
                  height: screenHeight * 0.1,
                  ignorePointer: true, // Add this property
                ),
                PositionedImageWidget(
                  top: screenHeight * 0.1,
                  right: screenWidth * 0.26,
                  offsetY: screenHeight * 0.01,
                  imagePath: "assets/images/lamp.png",
                  height: screenHeight * 0.1,
                  ignorePointer: true, // Add this property
                ),
                PositionedImageWidget(
                  top: screenHeight * 0.12,
                  right: -screenWidth * 0.05,
                  offsetY: screenHeight * 0.01,
                  imagePath: "assets/images/logo_blur.png",
                  height: screenHeight * 0.21,
                  width: screenWidth * 0.45,
                  ignorePointer: true, // Add this property
                ),
              ],
            ),
            Expanded(
              child: MyDevicesAndPrayers(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                prayers: prayers,
                prayerController: _prayerController,
                selectedDate: selectedDate,
                prayerTimes: prayerTimes,
                customerDetails: customerDetails,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
