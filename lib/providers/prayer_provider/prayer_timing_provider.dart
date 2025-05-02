import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/api/prayer/prayer_times.dart';
import '../../service/api/prayer/prayer_timing_api.dart';
import '../../service/api/tokens/token_service.dart';

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
        await TokenService.clearTokens();
        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
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
    final now = DateTime.now();
    final isToday = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    try {
      final prayerTime = prayerTimes.toMap()[prayerName]!;
      final prayerDateTime = DateFormat('HH:mm').parse(prayerTime);
      final prayerTimeToday = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        prayerDateTime.hour,
        prayerDateTime.minute,
      );

      if (isToday) {
        // For today's date, calculate status based on current time
        final differenceInMinutes = prayerTimeToday.difference(now).inMinutes.abs();
        final isAfterPrayerTime = now.isAfter(prayerTimeToday);

        if (isAfterPrayerTime) {
          return differenceInMinutes > 60 ? 'Completed' : 'Live';
        } else {
          return differenceInMinutes > 60 ? 'Upcoming' : 'Live';
        }
      } else {
        // For past dates, all prayers should be 'Completed'
        // For future dates, all prayers should be 'Upcoming'
        return selectedDate.isBefore(now) ? 'Completed' : 'Upcoming';
      }
    } catch (e) {
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