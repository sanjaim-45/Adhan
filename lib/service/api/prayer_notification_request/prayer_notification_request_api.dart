// services/notification_service.dart
import 'package:prayerunitesss/utils/app_urls.dart';

import '../../../model/api/prayer_notification_request/prayer_notification_request_model.dart';
import '../templete_api/api_service.dart';

class NotificationService {
  final ApiService _apiService = ApiService(baseUrl: AppUrls.appUrl);

  Future<bool> updatePrayerNotificationSettings(
    PrayerNotificationRequest request,
  ) async {
    try {
      final response = await _apiService.sendRequest(
        '${AppUrls.appUrl}/api/Notification/UpdatePrayerNotificationSettings',
        'POST',
        body: request.toJson(),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
          'Failed to update notification settings. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error updating notification settings: $e');
    }
  }
}
