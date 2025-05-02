// lib/service/api/prayer/prayer_service.dart
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../../model/api/prayer/prayer_times.dart';
import '../../../utils/app_urls.dart';
import '../templete_api/api_service.dart';
import '../tokens/token_service.dart';

class PrayerService {
  final ApiService apiService;
  final http.Client client;

  PrayerService(this.client) : apiService = ApiService(baseUrl: AppUrls().appUrl);


  Future<PrayerTimes> fetchPrayerTimes(
      DateTime date,
      Position position,
      String accessToken,
      ) async {
    try {
      final response = await apiService.sendRequest(
        '${AppUrls().appUrl}/api/PrayerTiming/GetPrayerTimings',
        'POST',
        body: {
          "prayerDate": _formatDate(date),
          "latitude": position.latitude,
          "longitude": position.longitude,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PrayerTimes.fromJson(data);
      } else {
        throw Exception('Failed to load prayer times: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch prayer times: $e');
    }
  }

  Future<Position> getCurrentLocation() async {
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}