import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/api/prayer_notification_request/prayer_notification_request_model.dart';
import '../../service/api/prayer_notification_request/prayer_notification_request_api.dart';

class NotificationProvider with ChangeNotifier {
  bool _livePrayerAlert = false;
  bool _isLoading = false;

  bool get livePrayerAlert => _livePrayerAlert;
  bool get isLoading => _isLoading;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;
  Future<void> loadInitialSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final customerIdString = prefs.getString('customerId');

      if (customerIdString != null) {
        final customerId = int.tryParse(customerIdString);
        if (customerId != null) {
          // Here you would call an API to get the current state if available
          // For now, we'll just load from SharedPreferences
          _livePrayerAlert = prefs.getBool('prayerNotification') ?? false;
        }
      }
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> togglePrayerNotification(bool newValue) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final customerIdString = prefs.getString('customerId');

      if (customerIdString == null) throw Exception('Customer ID not found');

      final customerId = int.tryParse(customerIdString);
      if (customerId == null) throw Exception('Invalid Customer ID format');

      _fcmToken ??= await _firebaseMessaging.getToken();
      if (_fcmToken == null) {
        throw Exception('Failed to get FCM token');
      }

      final notificationService = NotificationService();
      final request = PrayerNotificationRequest(
        customerId: customerId,
        isPrayerNotificationEnabled: newValue,
        androidDeviceToken: _fcmToken!,
      );

      final success = await notificationService
          .updatePrayerNotificationSettings(request);

      if (success) {
        _livePrayerAlert = newValue;
        await prefs.setBool('prayerNotification', newValue);
      } else {
        throw Exception('Failed to update prayer notification settings');
      }
    } catch (e) {
      debugPrint('Error toggling prayer notification: $e');
      // Optionally show error to user
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
