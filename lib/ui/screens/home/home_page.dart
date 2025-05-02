// lib/views/prayer/prayer_home_page.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../model/api/prayer/prayer_times.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/prayer_provider/prayer_timing_provider.dart';
import '../../../service/api/prayer/prayer_timing_api.dart';
import '../../../utils/font_mediaquery.dart';
import '../../widgets/prayer_card.dart';
import '../notification/notification_receiving_page.dart';
import '../subscription/upgrade.dart';

class PrayerHomePage extends StatefulWidget {
  const PrayerHomePage({super.key});

  @override
  State<PrayerHomePage> createState() => _PrayerHomePageState();
}

class _PrayerHomePageState extends State<PrayerHomePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  DateTime selectedDate = DateTime.now();
  // Map<String, String> prayerTimes = {};
  bool isLoading = true;
  String errorMessage = '';
  PrayerTimes prayerTimes = PrayerTimes(
    fajr: '--:--',
    dhuhr: '--:--',
    asr: '--:--',
    maghrib: '--:--',
    isha: '--:--',
  );
  late PrayerController _prayerController;

  @override
  void initState() {
    super.initState();
    _prayerController = PrayerController(PrayerService(http.Client()), context);
    _fetchPrayerTimes();
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
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().contains('authenticated') || e.toString().contains('Session expired')
            ? 'Please login again.'
            : 'Failed to load prayer times. Please try again.';
        isLoading = false;
      });

      if (e.toString().contains('Location services')) {
        _showEnableLocationDialog(context);
      } else if (e.toString().contains('Location permissions')) {
        _showPermissionDeniedDialog(context);
      } else if (e.toString().contains('authenticated') || e.toString().contains('Session expired')) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  Future<void> _showEnableLocationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Services Disabled'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('To get accurate prayer times, please enable location services.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  errorMessage = 'Location services required for prayer times';
                });
              },
            ),
            TextButton(
              child: Text('Enable'),
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openLocationSettings();
                // Retry after user enables location
                await Future.delayed(Duration(seconds: 1));
                _fetchPrayerTimes();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPermissionDeniedDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 4,
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Location Access Needed',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'To provide accurate prayer times based on your location, we need access to your device location.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please grant permission in settings.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  errorMessage = 'Location permission required for prayer times';
                });
              },
              child: Text(
                'Not Now',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openAppSettings();
                // Retry after user grants permission
                await Future.delayed(const Duration(seconds: 1));
                _fetchPrayerTimes();
              },
              child: Text(
                'Open Settings',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final _ = Provider.of<AuthProvider>(context);
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF0C5E38),
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: screenHeight * 0.04,
                  right: screenWidth * 0.05,
                ),
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [Color(0xFF2E7D32), Color(0xFF004408)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: screenWidth * 0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            "assets/images/name_logo.png",
                            height: screenHeight * 0.08,
                            width: screenWidth * 0.3,
                          ),
                          Row(
                            children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => SubscriptionPage(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFA1812E),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.03,
                                      vertical: screenHeight * 0.015,
                                    ),
                                  ),
                                  child: Text(
                                    "Upgrade",
                                    style: GoogleFonts.beVietnamPro(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: getFontRegularSize(context),
                                    ),
                                  ),
                                ),
                              SizedBox(width: screenWidth * 0.02),
                              CircleAvatar(
                                radius: screenWidth * 0.05,
                                backgroundColor: Colors.white,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => NotificationReceivingPage(),
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    Icons.notifications_none_outlined,
                                    size: screenWidth * 0.05,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: screenWidth * 0.05,
                            top: screenHeight * 0.010,
                          ),
                          child: Row(
                            children: [
                              Text(
                                "NEXT PRAYER IN",
                                style: GoogleFonts.beVietnamPro(
                                  color: Colors.white70,
                                  fontSize: screenWidth * 0.03,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4AF37),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.004,
                                  horizontal: screenWidth * 0.02,
                                ),
                                child: Text(
                                  "51.25",
                                  style: GoogleFonts.beVietnamPro(
                                    fontSize: screenWidth * 0.025,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: screenWidth * 0.05,
                            top: screenHeight * 0.01,
                          ),
                          child: Text(
                            "Maghrib",
                            style: GoogleFonts.beVietnamPro(
                              fontSize: screenWidth * 0.08,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: screenWidth * 0.05),
                          child: Text(
                            "المغرب",
                            style: GoogleFonts.beVietnamPro(
                              color: Colors.white,
                              fontSize: screenWidth * 0.04,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: screenWidth * 0.05,
                            top: screenHeight * 0.005,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.wb_sunny_outlined,
                                color: Colors.amber,
                                size: screenWidth * 0.06,
                              ),
                              SizedBox(width: screenWidth * 0.01),
                              Text(
                                DateFormat('hh:mm a').format(DateTime.now()),
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: screenWidth * 0.055,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Image.asset(
                      "assets/images/border_ui.png",
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: screenHeight * 0.05,
                right: screenWidth * 0.34,
                child: Transform.translate(
                  offset: Offset(0, screenHeight * 0.01),
                  child: Image.asset(
                    "assets/images/lamp_shot.png",
                    height: screenHeight * 0.1,
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.1,
                right: screenWidth * 0.26,
                child: Transform.translate(
                  offset: Offset(0, screenHeight * 0.01),
                  child: Image.asset(
                    "assets/images/lamp.png",
                    height: screenHeight * 0.1,
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.12,
                right: -screenWidth * 0.05,
                child: Transform.translate(
                  offset: Offset(0, screenHeight * 0.01),
                  child: Image.asset(
                    "assets/images/logo_blur.png",
                    height: screenHeight * 0.21,
                    width: screenWidth * 0.45,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(
                        height: 0,
                        color: Colors.yellow,
                        thickness: 5,
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.035,
                        ),
                        child: Text(
                          "🙌 Stay Aligned with the Call of Prayer",
                          style: GoogleFonts.beVietnamPro(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.045,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.035,
                          vertical: screenHeight * 0.005,
                        ),
                        child: Text(
                          "Check today's prayer timings and stay connected to your masjid, wherever you are.",
                          style: GoogleFonts.beVietnamPro(
                            color: Colors.grey,
                            fontSize: screenWidth * 0.035,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.only(top: screenHeight * 0.01),
                          children: [
                            // Fajr Prayer Card
                            // Fajr Prayer Card
                            PrayerCard(
                              imagePath: _prayerController.getImagePath('Fajr'),
                              title: 'Fajr',
                              arabic: 'الفجر',
                              time: prayerTimes.fajr,
                              status: _prayerController.getPrayerStatus('Fajr', selectedDate, prayerTimes),
                              statusColor: _prayerController.getStatusColor(
                                  _prayerController.getPrayerStatus('Fajr', selectedDate, prayerTimes)
                              ),
                              trailingIcon: Icons.notifications,
                            ),

// Dhuhr Prayer Card
                            PrayerCard(
                              imagePath: _prayerController.getImagePath('Dhuhr'),
                              title: 'Dhuhr',
                              arabic: 'الظهر',
                              time: prayerTimes.dhuhr,
                              status: _prayerController.getPrayerStatus('Dhuhr', selectedDate, prayerTimes),
                              statusColor: _prayerController.getStatusColor(
                                  _prayerController.getPrayerStatus('Dhuhr', selectedDate, prayerTimes)
                              ),
                              trailingIcon: Icons.notifications,
                            ),

// Asr Prayer Card
                            PrayerCard(
                              imagePath: _prayerController.getImagePath('Asr'),
                              title: 'Asr',
                              arabic: 'العصر',
                              time: prayerTimes.asr,
                              status: _prayerController.getPrayerStatus('Asr', selectedDate, prayerTimes),
                              statusColor: _prayerController.getStatusColor(
                                  _prayerController.getPrayerStatus('Asr', selectedDate, prayerTimes)
                              ),
                              // No trailing icon for Asr as per your original code
                            ),

// Maghrib Prayer Card
                            PrayerCard(
                              imagePath: _prayerController.getImagePath('Maghrib'),
                              title: 'Maghrib',
                              arabic: 'المغرب',
                              time: prayerTimes.maghrib,
                              status: _prayerController.getPrayerStatus('Maghrib', selectedDate, prayerTimes),
                              statusColor: _prayerController.getStatusColor(
                                  _prayerController.getPrayerStatus('Maghrib', selectedDate, prayerTimes)
                              ),
                              // No trailing icon for Maghrib as per your original code
                            ),

// Isha Prayer Card
                            PrayerCard(
                              imagePath: _prayerController.getImagePath('Isha'),
                              title: 'Isha',
                              arabic: 'العشاء',
                              time: prayerTimes.isha,
                              status: _prayerController.getPrayerStatus('Isha', selectedDate, prayerTimes),
                              statusColor: _prayerController.getStatusColor(
                                  _prayerController.getPrayerStatus('Isha', selectedDate, prayerTimes)
                              ),
                              // No trailing icon for Isha as per your original code
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}