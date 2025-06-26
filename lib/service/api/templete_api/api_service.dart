import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:prayerunitesss/model/api/subscription/current_subscription_model.dart';
import 'package:prayerunitesss/utils/app_urls.dart';

import '../../../model/api/transaction/transaction_response.dart';
import '../tokens/token_service.dart';

class ApiService {
  final String baseUrl;
  Timer? _refreshTimer;
  Timer? _countdownTimer;
  bool _isTimerRunning = false;
  int _countdown = 5 * 60; // 5 minutes in seconds

  ApiService({required this.baseUrl});

  Future<void> startTokenRefreshTimer() async {
    if (_isTimerRunning) return;

    final refreshToken = await TokenService.getRefreshToken();
    if (refreshToken == null) {
      _stopTimers();
      return;
    }

    _isTimerRunning = true;
    _startTimers();
  }

  void _startTimers() {
    // Cancel existing timers if any
    _stopTimers();

    // Initial print
    _printTimeRemaining(_countdown);

    // Countdown timer (every second)
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _countdown--;
      _printTimeRemaining(_countdown);

      if (_countdown <= 0) {
        _countdown = 5 * 60; // Reset to 5 minutes
      }
    });

    // Main refresh timer (every 5 minutes)
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      debugPrint('======== TOKEN REFRESH STARTED ========');
      final refreshToken = await TokenService.getRefreshToken();
      if (refreshToken == null) {
        _stopTimers();
        return;
      }

      debugPrint('--- Initiating token refresh at ${DateTime.now()} ---');
      final success = await this.refreshToken(); // Call the refreshToken method
      if (!success) {
        _stopTimers();
        return;
      }
      debugPrint('--- Token refresh completed at ${DateTime.now()} ---');
      debugPrint('======== TOKEN REFRESH FINISHED ========');

      // Reset countdown after successful refresh
      _countdown = 5 * 60;
    });
  }

  void _printTimeRemaining(int seconds) {
    final minutes = (seconds ~/ 60);
    final remainingSeconds = seconds % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    debugPrint('🔃 Token refresh in: $timeStr');
  }

  void _stopTimers() {
    _refreshTimer?.cancel();
    _countdownTimer?.cancel();
    _refreshTimer = null;
    _countdownTimer = null;
    _isTimerRunning = false;
    debugPrint('🛑 Token refresh timers stopped');
  }

  void dispose() {
    _stopTimers();
  }

  Future<http.Response> sendRequest(
    String url,
    String method, {
    Map<String, String>? headers,
    dynamic body,
    int retryCount = 0,
    int maxRetries = 3,
  }) async {
    final accessToken = await TokenService.getAccessToken();
    final defaultHeaders = {
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };

    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    final uri = Uri.parse(url);
    http.Response response;

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: defaultHeaders);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: defaultHeaders,
            body: body != null ? json.encode(body) : null,
          );
          break;
        default:
          throw Exception('Unsupported HTTP method');
      }

      // Handle 401 errors - try to refresh token
      if (response.statusCode == 401 && retryCount < maxRetries) {
        if (await TokenService.shouldMaintainSession()) {
          debugPrint('🔄 Attempting token refresh (attempt ${retryCount + 1})');
          final refreshed = await refreshToken();
          if (refreshed) {
            // Recursively call sendRequest with incremented retryCount
            return await sendRequest(
              url,
              method,
              headers: headers,
              body: body,
              retryCount: retryCount + 1,
              maxRetries: maxRetries,
            );
          }
        }
        throw Exception('Unauthorized - please login again');
      }

      return response;
    } catch (e) {
      // If we're maintaining session, don't throw - let the caller handle it
      if (!await TokenService.shouldMaintainSession()) {
        rethrow;
      }
      throw Exception('Request failed: $e');
    }
  }

  // In ApiService
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await TokenService.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('${AppUrls.appUrl}/api/RefreshToken/refresh-token'),
        headers: {
          'Content-Type': 'application/json', // Required!
        },
        body: json.encode({
          'token': refreshToken, // This is the required POST body
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newAccessToken = data['accessToken'];
        final newRefreshToken = data['refreshToken'];

        if (newAccessToken != null && newRefreshToken != null) {
          await TokenService.saveTokens(newAccessToken, newRefreshToken);
          return true;
        }
        return false;
      } else if (response.statusCode == 401) {
        if (response.body.contains('invalid_token') ||
            response.body.contains('expired')) {
          await TokenService.clearTokens();
        }
        return false;
      }

      return false;
    } catch (e) {
      print('Refresh Token Error: $e');
      return false;
    }
  }

  Future<bool> cancelSubscription(int subscriptionId) async {
    try {
      final response = await sendRequest(
        '$baseUrl/api/CustomerSubscription/Cancel?subscriptionId=$subscriptionId',
        'POST',
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
          'Failed to cancel subscription: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to cancel subscription: $e');
    }
  }

  // services/api_service.dart
  Future<TransactionResponse?> getAllCustomerTransactions() async {
    try {
      final response = await sendRequest(
        '$baseUrl/api/CustomerSubscription/GetAllCustomerTransactions',
        'GET',
      );

      if (response.statusCode == 200) {
        return TransactionResponse.fromJson(json.decode(response.body));
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

  // Add this method to your ApiService class
  // Updated API service method
  Future<CurrentSubscriptionModel?> getCurrentSubscription() async {
    try {
      final response = await sendRequest(
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

  // Future<bool> refreshToken() async {
  //   try {
  //     final refreshToken = await TokenService.getRefreshToken();
  //     if (refreshToken == null) {
  //       if (kDebugMode) {
  //         print('🔴 No refresh token available');
  //       }
  //       return false;
  //     }
  //
  //     final refreshUrl = Uri.parse('$baseUrl/api/RefreshToken/refresh-token');
  //     final response = await http
  //         .post(
  //           refreshUrl,
  //           headers: {'Content-Type': 'application/json'},
  //           body: json.encode({'token': refreshToken}),
  //         )
  //         .timeout(const Duration(seconds: 10));
  //
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       await TokenService.saveTokens(
  //         data['accessToken'],
  //         data['refreshToken'] ?? refreshToken, // Keep old if new not provided
  //       );
  //       if (kDebugMode) {
  //         print('🟢 Token refresh successful');
  //       }
  //       return true;
  //     } else if (response.statusCode == 401) {
  //       if (kDebugMode) {
  //         print('🔴 Refresh token invalid - clearing tokens');
  //       }
  //       return false;
  //     } else {
  //       if (kDebugMode) {
  //         print('🟠 Token refresh failed with status: ${response.statusCode}');
  //       }
  //       return false;
  //     }
  //   } on TimeoutException {
  //     if (kDebugMode) {
  //       print('🟠 Token refresh timed out');
  //     }
  //     return false;
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('⚠️ Token refresh error: $e');
  //     }
  //     return false;
  //   }
  // }
}
