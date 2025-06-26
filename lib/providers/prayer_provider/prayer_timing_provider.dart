import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prayerunitesss/service/api/templete_api/api_service.dart';
import 'package:prayerunitesss/utils/app_urls.dart';

import '../../model/api/prayer/prayer_times.dart';
import '../../service/api/prayer/prayer_timing_api.dart';
import '../../service/api/tokens/token_service.dart';
import '../../ui/screens/login_page/login_page.dart';

class PrayerController {
  final PrayerService prayerService;
  final BuildContext context;

  PrayerController(this.prayerService, this.context);

  Future<PrayerTimes> getPrayerTimes(DateTime selectedDate) async {
    try {
      // Get current position
      final position = await prayerService.getCurrentLocation();

      return await prayerService.fetchPrayerTimes(
        selectedDate,
        position,
        await TokenService.getAccessToken() ?? '',
      );
    } catch (e) {
      if (e.toString().contains('authenticated') ||
          e.toString().contains('Session expired')) {
        // Clear tokens and navigate to login if auth error
        final apiService = ApiService(baseUrl: AppUrls.appUrl);
        await apiService.refreshToken();
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      }
      rethrow;
    }
  }

  String getPrayerStatus(
    String prayerName,
    DateTime selectedDate,
    PrayerTimes prayerTimes,
  ) {
    // Get current time
    final now = DateTime.now();

    // Check if selected date is today
    final isToday =
        selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    try {
      final prayerTimeStr = prayerTimes.toMap()[prayerName];

      // If no time is available yet, return a default status
      if (prayerTimeStr == null || prayerTimeStr == '--:--') {
        return 'Upcoming'; // Or 'Loading' or any neutral state
      }

      // Parse prayer time
      final parsedPrayerTime = DateFormat('HH:mm').parse(prayerTimeStr);

      final prayerDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        parsedPrayerTime.hour,
        parsedPrayerTime.minute,
      );

      if (!isToday) {
        return selectedDate.isBefore(now) ? 'Completed' : 'Upcoming';
      }

      final liveEndTime = prayerDateTime.add(const Duration(minutes: 30));

      if (now.isBefore(prayerDateTime)) {
        return 'Upcoming';
      } else if (now.isBefore(liveEndTime)) {
        return 'Live';
      } else {
        return 'Completed';
      }
    } catch (e) {
      print('Error in getPrayerStatus: $e');
      return 'Upcoming';
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'Live':
        return Colors.red;
      case 'Upcoming':
      default:
        return const Color(0xFFA1812E);
    }
  }

  String getImagePath(String prayerName) {
    switch (prayerName) {
      case 'Fajr':
        return "assets/images/cloud/Sunny.png";
      case 'Dhuhr':
        return "assets/images/cloud/Partly-cloudy.png";
      case 'Asr':
        return "assets/images/cloud/Cloudy-clear at times-night.png";
      case 'Maghrib':
        return "assets/images/cloud/Cloudy-clear at times.png";
      case 'Isha':
      default:
        return "assets/images/cloud/Clear-night.png";
    }
  }
}
