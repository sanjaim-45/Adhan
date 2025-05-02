// auth_provider.dart
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isDemoUser = false; // Track if user used demo credentials

  bool get isLoggedIn => _isLoggedIn;
  bool get isDemoUser => _isDemoUser;

  void login({bool isDemo = false}) {
    _isLoggedIn = true;
    _isDemoUser = isDemo; // Set whether it's a demo user
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _isDemoUser = false;
    notifyListeners();
  }
}