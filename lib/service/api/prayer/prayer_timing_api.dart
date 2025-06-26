import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import '../../../model/api/prayer/prayer_times.dart';
import '../../../utils/app_urls.dart';
import '../templete_api/api_service.dart';

class PrayerService {
  final ApiService apiService;
  final http.Client client;

  PrayerService(this.client) : apiService = ApiService(baseUrl: AppUrls.appUrl);
  Position? _lastPosition;
  DateTime? _lastDate;
  PrayerTimes? _lastPrayerTimes;
  Future<PrayerTimes> fetchPrayerTimes(
    DateTime date,
    Position position,
    String accessToken,
  ) async {
    try {
      // Validate position data
      if (position.longitude == null) {
        throw Exception('Invalid location coordinates');
      }

      // Check if we can use cached data
      if (_lastPrayerTimes != null &&
          _lastPosition != null &&
          _lastDate != null) {
        // Calculate distance from last position (in meters)
        final distance = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );

        // If same date and location hasn't changed significantly (less than 10m)
        if (_lastDate == date && distance < 10) {
          return _lastPrayerTimes!;
        }
      }

      final response = await apiService.sendRequest(
        '${AppUrls.appUrl}/api/PrayerTiming/GetPrayerTimings',
        'POST',
        body: {
          "prayerDate": _formatDate(date),
          "latitude": position.latitude,
          "longitude": position.longitude,
        },
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prayerTimes = PrayerTimes.fromJson(data);

        // Update cache
        _lastPosition = position;
        _lastDate = date;
        _lastPrayerTimes = prayerTimes;

        return prayerTimes;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('Failed to load prayer times: ${response.statusCode}');
      }
    } on FormatException {
      throw Exception('Invalid prayer times data format');
    } catch (e) {
      await ApiService(baseUrl: AppUrls.appUrl).refreshToken();
      throw Exception('Failed to fetch prayer times: ${e.toString()}');
    }
  }

  Future<Position> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      final isLocationServiceEnabled =
          await Geolocator.isLocationServiceEnabled();
      if (!isLocationServiceEnabled) {
        throw Exception(
          'Location services are disabled. '
          'Please enable location services to get accurate prayer times.',
        );
      }

      // Check location permission status
      final permissionStatus = await Permission.location.status;

      if (!permissionStatus.isGranted) {
        // Request permission if not granted
        final requestedStatus = await Permission.location.request();

        if (!requestedStatus.isGranted) {
          if (requestedStatus.isPermanentlyDenied) {
            throw Exception(
              'Location permissions are permanently denied. '
              'Please enable them in app settings.',
            );
          }
          throw Exception('Location permissions are required');
        }
      }

      // Get current position with timeout
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout:
            () =>
                throw Exception(
                  'Location request timed out. '
                  'Please check your connection and try again.',
                ),
      );
    } on PlatformException catch (e) {
      throw Exception('Location error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get location: ${e.toString()}');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}'
        '-${date.day.toString().padLeft(2, '0')}';
  }

  // Combined method to get prayer times with automatic location handling
  Future<PrayerTimes> getPrayerTimesWithLocation(
    DateTime date,
    String accessToken,
  ) async {
    try {
      final position = await getCurrentLocation();
      return await fetchPrayerTimes(date, position, accessToken);
    } catch (e) {
      // Re-throw with more context if needed
      if (e.toString().contains('Location services') ||
          e.toString().contains('Location permissions')) {
        throw Exception('Location required: ${e.toString()}');
      }
      rethrow;
    }
  }
}
