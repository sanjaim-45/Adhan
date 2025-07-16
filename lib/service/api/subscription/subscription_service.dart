import 'dart:convert';

import 'package:prayerunitesss/service/api/templete_api/api_service.dart';
import 'package:prayerunitesss/utils/app_urls.dart';

class SubscriptionService {
  static final ApiService _apiService = ApiService(baseUrl: AppUrls.appUrl);

  static Future<Map<String, dynamic>> getSubscriptionPlans() async {
    final response = await _apiService.sendRequest(
      '${AppUrls.appUrl}/api/SubscriptionPlan/getAll',
      'GET',
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load plans: ${response.statusCode}');
    }
  }

  static Future<dynamic> subscribeToPlan({
    required String customerId,
    required int planId,
    required int deviceId,
  }) async {
    final response = await _apiService.sendRequest(
      '${AppUrls.appUrl}/api/CustomerSubscription/create',
      'POST',
      body: {'userId': customerId, 'planId': planId, 'deviceId': deviceId},
    );

    try {
      return json.decode(response.body);
    } catch (e) {
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'message': response.body.trim()};
      } else {
        throw response.body;
      }
    }
  }
}
