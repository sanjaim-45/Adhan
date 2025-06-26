// otp_service.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../model/api/OTP/otp_models.dart';
import '../../../model/api/login/login_model.dart';
import '../../../providers/user_details_from_login/user_details.dart';
import '../templete_api/api_service.dart';
import '../tokens/token_service.dart';

class OtpService {
  final ApiService apiService;

  OtpService({required this.apiService});

  Future<OtpResponse> sendOtp(String phoneOrEmail) async {
    try {
      final url =
          '${apiService.baseUrl}/api/Customer/ResendOtpforchangeEmailorPhone?PhoneOrEmail=$phoneOrEmail';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return OtpResponse.fromJson(json.decode(response.body));
      } else {
        final errorResponse = json.decode(response.body);
        throw Exception(errorResponse['message'] ?? 'Failed to send OTP');
      }
    } on SocketException {
      throw Exception('Network error: Please check your internet connection.');
    } catch (e) {
      throw e;
    }
  }

  Future<OtpResponse> sendOuterOtp(String phoneOrEmail) async {
    // Convert this to use apiService.sendRequest as well for consistency
    final url =
        '${apiService.baseUrl}/api/Customer/ResendOtp?PhoneOrEmail=$phoneOrEmail';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return OtpResponse.fromJson(json.decode(response.body));
    } else {
      final errorResponse = json.decode(response.body);
      throw errorResponse['message'] ?? 'Failed to send OTP';
    }
  }

  Future<OtpResponse> verifyPhoneOuterOtp({
    required String phoneOrEmail,
    required String code,
  }) async {
    try {
      // Convert this to use apiService.sendRequest
      final url = '${apiService.baseUrl}/api/Customer/VerifyChangePhoneOtp';

      final body =
          VerifyOtpRequest(phoneOrEmail: phoneOrEmail, code: code).toJson();

      final response = await apiService.sendRequest(
        url,
        'POST',
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        return OtpResponse.fromJson(json.decode(response.body));
      } else {
        final errorResponse = json.decode(response.body);
        throw errorResponse['message'] ?? 'Failed to verify OTP';
      }
    } catch (e) {
      // Log the error or handle it as needed
      debugPrint('Error verifying phone OTP: $e');
      rethrow; // Re-throw the exception to be caught by the caller
    }
  }

  Future<OtpResponse> verifyPhoneOtp({
    required String phoneOrEmail,
    required String code,
  }) async {
    try {
      final url = '${apiService.baseUrl}/api/Customer/VerifyChangeEmailOtp';

      final body =
          VerifyOtpRequest(phoneOrEmail: phoneOrEmail, code: code).toJson();

      final response = await apiService.sendRequest(
        url,
        'POST',
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        return OtpResponse.fromJson(json.decode(response.body));
      } else {
        final errorResponse = json.decode(response.body);
        throw errorResponse['message'] ?? 'Failed to verify OTP';
      }
    } catch (e) {
      // Log the error or handle it as needed
      debugPrint('Error verifying phone OTP: $e');
      rethrow; // Re-throw the exception to be caught by the caller
    }
  }

  Future<LoginResponse> verifyLoginOtp({
    required String userName,
    required String otp,
    required BuildContext context,
  }) async {
    final url = '${apiService.baseUrl}/api/Login/LoginWithOtp';

    final body = {'userName': userName, 'otp': otp};

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final loginResponse = LoginResponse.fromJson(json.decode(response.body));

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

      if (loginResponse.customerDetailResponse.subscription != null) {
        final subscription = loginResponse.customerDetailResponse.subscription!;

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

      return loginResponse;
    } else {
      final errorResponse = json.decode(response.body);
      throw Exception(errorResponse['message'] ?? 'Failed to verify login OTP');
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
