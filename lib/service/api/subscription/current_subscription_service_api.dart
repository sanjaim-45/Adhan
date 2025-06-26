import 'dart:convert';

import '../../../model/api/subscription/current_subscription_model.dart';
import '../templete_api/api_service.dart';

class CurrentSubscriptionServiceApi {
  late final String baseUrl;
  late final ApiService _apiService;
  Future<CurrentSubscriptionModel?> getCurrentSubscription() async {
    try {
      final response = await _apiService.sendRequest(
        '$baseUrl/api/CustomerSubscription/GetByCustomerId',
        'GET',
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Check if the response is an empty array
        if (jsonData is List && jsonData.isEmpty) {
          return null;
        }

        return CurrentSubscriptionModel.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        // No active subscription found
        return null;
      } else {
        throw Exception('Failed to load subscription: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load subscription: $e');
    }
  }
}
