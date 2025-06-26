import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:prayerunitesss/service/api/templete_api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/app_urls.dart';

class TokenService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  static Future<void> saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  static Future<bool> shouldMaintainSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('maintain_session') ?? false;
  }

  static Future<bool> hasRefreshToken() async {
    final refreshToken = await getRefreshToken();
    return refreshToken != null && refreshToken.isNotEmpty;
  }

  static Future<void> setMaintainSession(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('maintain_session', value);
  }

  static Future<bool> hasValidTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && refreshToken != null; // Only checks existence
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove('maintain_session');
  }
}

class TokenRefreshService {
  static final TokenRefreshService _instance = TokenRefreshService._internal();
  Timer? _refreshTimer;
  bool _isRunning = false;

  factory TokenRefreshService() => _instance;

  TokenRefreshService._internal();

  void start() {
    if (_refreshTimer != null) return;

    // Check every 4 minutes (less than access token expiry)
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 4),
      (_) => _checkAndRefresh(),
    );
    if (kDebugMode) {
      print('🔄 Token refresh service started');
    }
  }

  void stop() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _isRunning = false;
    if (kDebugMode) {
      print('🛑 Token refresh service stopped');
    }
  }

  // In TokenRefreshService
  Future<void> _checkAndRefresh() async {
    if (_isRunning) return;
    _isRunning = true;

    try {
      if (kDebugMode) {
        print('🔄 Checking token status...');
      }

      // Only proceed if we have both tokens
      if (!(await TokenService.hasRefreshToken())) {
        if (kDebugMode) {
          print('❌ Missing refresh token - stopping refresh');
        }
        stop();
        return;
      }

      // Check connectivity before attempting refresh
      final hasConnection = await checkInternetConnection();

      if (hasConnection) {
        final refreshed =
            await ApiService(baseUrl: AppUrls.appUrl).refreshToken();
        if (!refreshed) {
          if (kDebugMode) {
            print('⚠️ Token refresh failed - but keeping tokens');
          }
        }
      } else {
        if (kDebugMode) {
          print('⚠️ No internet connection - skipping refresh');
        }
        // Don't clear tokens when offline
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error during token check: ${e.toString()}');
      }
      // Don't clear tokens on error - just wait for next attempt
    } finally {
      _isRunning = false;
    }
  }

  Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}
