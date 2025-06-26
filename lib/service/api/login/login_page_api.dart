import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../model/api/login/login_model.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/user_details_from_login/user_details.dart';
import '../../../utils/app_urls.dart';
import '../tokens/token_service.dart';

class LoginService {
  static Future<LoginResponse> login({
    required String userName,
    required String password,
    required BuildContext context,
    bool maintainSession = false, // New parameter
  }) async {
    final url = Uri.parse('${AppUrls.appUrl}/api/Login/Login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userName': userName, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body); // ✅ Add this line
      final loginResponse = LoginResponse.fromJson(data);

      // Save session preference
      await TokenService.setMaintainSession(maintainSession);

      final accessToken = _getHeaderCaseInsensitive(
        response.headers,
        'access-token',
      );
      final refreshToken = _getHeaderCaseInsensitive(
        response.headers,
        'refresh-token',
      );
      final _ = data['accessTokenExpiresIn'] ?? 300; // 5 min default
      final _ = data['refreshTokenExpiresIn'] ?? 604800; // 7 days default

      if (accessToken == null || refreshToken == null) {
        throw Exception('Tokens not found in response headers');
      }

      // Save tokens
      await TokenService.saveTokens(accessToken, refreshToken);

      // Start auto-refresh
      TokenRefreshService().start();

      // Update auth state
      await Provider.of<AuthProvider>(context, listen: false).login();

      // Save user details
      final userDetailsProvider = Provider.of<UserDetailsProvider>(
        context,
        listen: false,
      );
      final subscription = loginResponse.customerDetailResponse.subscription;
      await userDetailsProvider.updateUserDetails(
        fullName: '${subscription.firstName} ${subscription.lastName}',
        mosque: subscription.mosque,
        mosqueLocation: subscription.mosqueLocation,
        profileImage:
            loginResponse.customerDetailResponse.profileImage, // Add this
      );

      final plan = subscription.subscriptionPlan;
      await userDetailsProvider.updateSubscriptionDetails(
        planName: plan.planName,
        billingCycle: plan.billingCycle,
        price: plan.price,
        currency: plan.currency,
        remainingDays: plan.remainingDays,
      );

      return loginResponse;
    } else {
      String errorMessage = 'Login failed';
      try {
        final errorData = json.decode(response.body);
        errorMessage = errorData['message'] ?? errorMessage;
      } catch (_) {
        // response is not JSON, keep default message
      }
      throw Exception(errorMessage);
    }
  }

  static Future<bool> checkPersistedAuth(BuildContext context) async {
    final maintainSession = await TokenService.shouldMaintainSession();
    if (maintainSession) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.softLogin();
      return true;
    }
    return false;
  }

  static Future<void> logout(BuildContext context) async {
    try {
      TokenRefreshService().stop(); // Stop refresh timer

      // Get SharedPreferences instance first
      final prefs = await SharedPreferences.getInstance();

      // Save the notification preference (if it exists)
      final hasSetNotificationPrefs = prefs.getBool(
        'hasSetNotificationPreferences',
      );

      // Clear all data EXCEPT notification preference
      await TokenService.clearTokens();
      await Provider.of<AuthProvider>(context, listen: false).logout();
      await Provider.of<UserDetailsProvider>(
        context,
        listen: false,
      ).clearUserDetails();
      await prefs.clear(); // This clears everything

      // Restore the notification preference if it existed
      if (hasSetNotificationPrefs != null) {
        await prefs.setBool(
          'hasSetNotificationPreferences',
          hasSetNotificationPrefs,
        );
      }
    } catch (e) {
      // Ensure tokens are cleared even if something fails
      await TokenService.clearTokens();

      // Also attempt to clear SharedPreferences in case of error
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      rethrow;
    }
  }
}

String? _getHeaderCaseInsensitive(Map<String, String> headers, String key) {
  final lowerKey = key.toLowerCase();
  for (final headerKey in headers.keys) {
    if (headerKey.toLowerCase() == lowerKey) {
      return headers[headerKey];
    }
  }
  return null;
}
