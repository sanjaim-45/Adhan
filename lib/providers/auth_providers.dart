import 'package:flutter/foundation.dart';

import '../service/api/tokens/token_service.dart';

class AuthProvider with ChangeNotifier {
  bool? _isLoggedIn;
  bool _isOffline = false;

  bool? get isLoggedIn => _isLoggedIn;
  bool get isOffline => _isOffline;

  Future<void> checkAuthStatus() async {
    try {
      // First check if we have tokens
      final hasRefreshToken = await TokenService.hasRefreshToken();
      final accessToken = await TokenService.getAccessToken();

      if (hasRefreshToken && accessToken != null) {
        _isLoggedIn = true;
      } else {
        _isLoggedIn = false;
      }
      _isOffline = false;
    } catch (e) {
      // If we're maintaining session, stay logged in during network errors
      if (await TokenService.shouldMaintainSession()) {
        _isLoggedIn = true;
        _isOffline = true;
      } else {
        _isLoggedIn = false;
      }
    }
    notifyListeners();
  }

  Future<void> softLogin() async {
    try {
      if (await TokenService.hasValidTokens()) {
        _isLoggedIn = true;
        notifyListeners();
      }
    } catch (e) {
      // Don't clear tokens here - just remain in current state
      if (kDebugMode) {
        print('Soft login error: $e');
      }
    }
  }

  Future<void> login() async {
    _isLoggedIn = true;
    _isOffline = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _isOffline = false;
    notifyListeners();
  }
}
