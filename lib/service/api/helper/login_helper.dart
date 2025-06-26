import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../model/api/login/login_model.dart';
import '../../../providers/user_details_from_login/user_details.dart';
import '../tokens/token_service.dart';

class LoginHelper {
  static Future<void> handleLoginSuccess({
    required http.Response response,
    required LoginResponse loginResponse,
    required BuildContext context,
  }) async {
    final accessToken = _getHeaderCaseInsensitive(
      response.headers,
      'access-token',
    );
    final refreshToken = _getHeaderCaseInsensitive(
      response.headers,
      'refresh-token',
    );

    if (accessToken == null || refreshToken == null) {
      throw Exception(
        'Tokens not found in response headers. Available headers: ${response.headers.keys}',
      );
    }

    await TokenService.saveTokens(accessToken, refreshToken);

    final userDetailsProvider = Provider.of<UserDetailsProvider>(
      context,
      listen: false,
    );

    final subscription = loginResponse.customerDetailResponse.subscription;
    if (subscription != null) {
      await userDetailsProvider.updateUserDetails(
        fullName: '${subscription.firstName} ${subscription.lastName}',
        mosque: subscription.mosque,
        mosqueLocation: subscription.mosqueLocation,
      );

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
        await userDetailsProvider.clearSubscription();
      }
    } else {
      await userDetailsProvider.updateUserDetails(
        fullName: '',
        mosque: '',
        mosqueLocation: '',
      );
      await userDetailsProvider.clearSubscription();
    }
  }

  static String? _getHeaderCaseInsensitive(
    Map<String, String> headers,
    String key,
  ) {
    final lowerKey = key.toLowerCase();
    for (final headerKey in headers.keys) {
      if (headerKey.toLowerCase() == lowerKey) {
        return headers[headerKey];
      }
    }
    return null;
  }
}
