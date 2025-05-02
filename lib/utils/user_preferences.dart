import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String _fullNameKey = 'full_name';
  static const String _mosqueKey = 'mosque';
  static const String _mosqueLocationKey = 'mosque_location';

  static Future<void> saveUserDetails({
    required String firstName,
    required String lastName,
    required String mosque,
    required String mosqueLocation,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fullNameKey, '$firstName $lastName');
    await prefs.setString(_mosqueKey, mosque);
    await prefs.setString(_mosqueLocationKey, mosqueLocation);
  }

  static Future<Map<String, String>> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'fullName': prefs.getString(_fullNameKey) ?? '',
      'mosque': prefs.getString(_mosqueKey) ?? '',
      'mosqueLocation': prefs.getString(_mosqueLocationKey) ?? '',
    };
  }

  static Future<void> clearUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_fullNameKey);
    await prefs.remove(_mosqueKey);
    await prefs.remove(_mosqueLocationKey);
  }
}