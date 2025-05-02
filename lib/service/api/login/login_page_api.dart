import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../model/api/login/login_model.dart';
import '../../../providers/user_details_from_login/user_details.dart';
import '../../../utils/app_urls.dart';
import '../tokens/token_service.dart';

class LoginService {
  static Future<LoginResponse> login({
    required String userName,
    required String password,
    required BuildContext context
  }) async {
    final url = Uri.parse('${AppUrls().appUrl}/api/Login/Login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'userName': userName,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Parse the response body
      final loginResponse = LoginResponse.fromJson(json.decode(response.body));

      // Case-insensitive header lookup
      final accessToken = _getHeaderCaseInsensitive(response.headers, 'access-token');
      final refreshToken = _getHeaderCaseInsensitive(response.headers, 'refresh-token');

      if (accessToken == null || refreshToken == null) {
        throw Exception('Tokens not found in response headers. Available headers: ${response.headers.keys}');
      }

      // Save tokens to SharedPreferences
      await TokenService.saveTokens(accessToken, refreshToken);

      // Save user details
      final userDetailsProvider = Provider.of<UserDetailsProvider>(context, listen: false);

      if (loginResponse.data.subscription != null) {
        final subscription = loginResponse.data.subscription!;

        await userDetailsProvider.updateUserDetails(
          fullName: '${subscription.firstName} ${subscription.lastName}',
          mosque: subscription.mosque,
          mosqueLocation: subscription.mosqueLocation,
        );

        // ✅ Only update subscription details if subscriptionPlan is not null
        if (subscription.subscriptionPlan != null) {
          final plan = subscription.subscriptionPlan!;
          await userDetailsProvider.updateSubscriptionDetails(
            planName: plan.planName,
            billingCycle: plan.billingCycle,
            price: plan.price,
            currency: plan.currency,
            remainingDays: plan.remainingDays,
          );
        } else {
          // Clear or skip subscription details
          await userDetailsProvider.clearSubscription();
        }
      } else {
        // No subscription at all
        await userDetailsProvider.updateUserDetails(
          fullName: '',
          mosque: '',
          mosqueLocation: '',
        );
        await userDetailsProvider.clearSubscription();
      }

      return loginResponse;
    } else {
      throw Exception('Failed to login: ${response.statusCode}');
    }
  }

  // Helper method for case-insensitive header lookup
  static String? _getHeaderCaseInsensitive(Map<String, String> headers, String key) {
    final lowerKey = key.toLowerCase();
    for (final headerKey in headers.keys) {
      if (headerKey.toLowerCase() == lowerKey) {
        return headers[headerKey];
      }
    }
    return null;
  }
}