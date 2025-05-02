import 'package:bottom_picker/resources/arrays.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:http/http.dart' as http;


import '../../../model/api/prayer/prayer_times.dart';
import '../../../providers/prayer_provider/prayer_timing_provider.dart';
import '../../../service/api/prayer/prayer_timing_api.dart';
import '../../../utils/font_mediaquery.dart';
import '../../widgets/prayer_card.dart';
import '../notification/notification_receiving_page.dart';
import '../subscription/upgrade.dart';

class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});

  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;
  late http.Client _httpClient;

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
// Add these methods inside the _PrayerHomePageState class
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

  String getFormattedDate(DateTime date) {
    return DateFormat('dd EEE, MMMM yyyy').format(date);
  }

  void _goToPreviousDay() {
    setState(() {
      selectedDate = selectedDate.subtract(const Duration(days: 1));
      _fetchPrayerTimes();
    });
  }

  void _goToNextDay() {
    setState(() {
      selectedDate = selectedDate.add(const Duration(days: 1));
      _fetchPrayerTimes();
    });
  }

  void _pickDate(BuildContext context) {
    BottomPicker.date(
      pickerTitle: Text(
        'Set Prayer Date',
        style: GoogleFonts.beVietnamPro(
          fontWeight: FontWeight.bold,
          fontSize: getFontRegular55Size(context),
          letterSpacing: -0.5,
          color: Colors.black,
        ),
      ),
      dateOrder: DatePickerDateOrder.dmy,
      initialDateTime: selectedDate,
      pickerTextStyle: GoogleFonts.beVietnamPro(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: MediaQuery.of(context).size.width * 0.05,
      ),
      onSubmit: (pickedDate) {
        setState(() {
          selectedDate = pickedDate;
          _fetchPrayerTimes();
        });
      },
      onChange: (pickedDate) {
        print(pickedDate);
      },
      buttonStyle: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      buttonContent: Text(
        textAlign: TextAlign.center,
        "Done",
        style: GoogleFonts.beVietnamPro(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      bottomPickerTheme: BottomPickerTheme.plumPlate,
    ).show(context);
  }


  @override
  void dispose() {
    _httpClient.close(); // Cancel any pending requests
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          actions: [
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
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    "Upgrade",
                    style: GoogleFonts.beVietnamPro(
                      color: Colors.white,
                      letterSpacing: -0.5,
                      fontSize: getFontRegularSize(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  maxRadius: getFontRegular55Size(context),
                  backgroundColor: Color(0xFFFBF7EB),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => NotificationReceivingPage(),
                        ),
                      );
                    },
                    child: Icon(
                      size: getFontRegular55Size(context),
                      Icons.notifications_none_outlined,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ],
          title: Text(
            'Prayer Times',
            style: GoogleFonts.beVietnamPro(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: screenWidth * 0.12,
                      height: screenHeight * 0.055,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                        onPressed: _goToPreviousDay,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _pickDate(context),
                      child: Text(
                        getFormattedDate(selectedDate),
                        style: GoogleFonts.beVietnamPro(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.12,
                      height: screenHeight * 0.055,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 18),
                        onPressed: _goToNextDay,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5),
              Container(
                height: 1,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
              Expanded(
                child:  ListView(
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
      ),
    );
  }
}
