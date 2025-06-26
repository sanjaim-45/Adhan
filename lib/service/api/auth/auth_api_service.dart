import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../model/api/auth_model/forgot_password_models.dart';
import '../tokens/token_service.dart';

class AuthApiService {
  final String baseUrl;
  final http.Client client;

  AuthApiService({required this.baseUrl, required this.client});

  Future<ForgotPasswordResponse> forgotPassword(String userIdentifier) async {
    // Construct URL with query parameter (like Postman)
    final url = Uri.parse(
      '$baseUrl/api/Customer/SendResetPassword-otp',
    ).replace(queryParameters: {'PhoneOrEmail': userIdentifier});

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('Response Status: ${response.statusCode}'); // Debugging
      print('Response Body: ${response.body}'); // Debugging

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Server returned empty response');
        }
        try {
          final decodedJson = json.decode(response.body);
          return ForgotPasswordResponse.fromJson(decodedJson);
        } catch (e) {
          throw Exception('Failed to decode JSON: $e');
        }
      } else {
        // Handle non-200 status codes here
        throw response.body;
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<VerifyOtpResponse> verifyResetPasswordOtp({
    required String otp,
    required String userIdentifier,
  }) async {
    final url = Uri.parse('$baseUrl/api/Login/ResetPassword-verify-otp');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'code': otp, 'phoneOrEmail': userIdentifier}),
      );

      if (response.statusCode == 200) {
        // Parse the response
        final verifyOtpResponse = VerifyOtpResponse.fromJson(
          json.decode(response.body),
        );

        // Save the new tokens
        await TokenService.saveTokens(
          verifyOtpResponse.accessToken,
          verifyOtpResponse.refreshToken,
        );

        return verifyOtpResponse;
      } else {
        final errorResponse = json.decode(response.body);
        print('Error Response: $errorResponse'); // Debugging
        if (errorResponse is Map<String, dynamic> &&
            errorResponse.containsKey('message')) {
          throw Exception(errorResponse['message']);
        } else {
          throw Exception('An unknown error occurred: ${response.body}');
        }
      }
    } catch (e) {
      print(e);
      throw e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<ChangePasswordResponse> confirmPasswordApi({
    required String userConfirmPassword,
  }) async {
    final url = Uri.parse('$baseUrl/api/Customer/ResetPassword');

    // Get the stored access token
    final accessToken = await TokenService.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('No access token found');
    }

    try {
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken', // Add authorization header
        },
        body: json.encode({'password': userConfirmPassword}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          if (response.body.isEmpty) {
            return ChangePasswordResponse(message: "Password reset successful");
          }
          return ChangePasswordResponse.fromJson(json.decode(response.body));
        } catch (e) {
          throw Exception("Failed to parse response: ${e.toString()}");
        }
      } else {
        final errorResponse = json.decode(response.body);
        print(errorResponse);
        throw Exception(errorResponse['message'] ?? 'Failed to reset password');
      }
    } catch (e) {
      throw Exception('Failed to reset password: ${e.toString()}');
    }
  }
}
