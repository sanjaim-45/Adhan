import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDetails {
  final String fullName;
  final String mosque;
  final String mosqueLocation;
  final String? profileImage;
  final SubscriptionDetails? subscription;

  UserDetails({
    required this.fullName,
    required this.mosque,
    required this.mosqueLocation,
    this.profileImage,
    this.subscription,
  });

  String get displayMosque => mosque.isEmpty ? 'Mosque' : mosque;
  String get displayMosqueLocation =>
      mosqueLocation.isEmpty ? 'Masjid Al-Rahma – Kuwait' : mosqueLocation;
}

class SubscriptionDetails {
  final String planName;
  final String billingCycle;
  final double price;
  final String currency;
  final int remainingDays;

  SubscriptionDetails({
    required this.planName,
    required this.billingCycle,
    required this.price,
    required this.currency,
    required this.remainingDays,
  });

  String get formattedPrice => '$price ${currency.trim()}';
  String get formattedPlan => '$planName ($billingCycle)';
}

class UserDetailsProvider with ChangeNotifier {
  UserDetails? _userDetails;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  UserDetails? get userDetails => _userDetails;

  Future<void> loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();

    final fullName = prefs.getString('full_name') ?? '';
    final mosque = prefs.getString('mosque') ?? '';
    final mosqueLocation = prefs.getString('mosque_location') ?? '';
    final profileImage = prefs.getString('profile_image');

    SubscriptionDetails? subscription;
    if (prefs.containsKey('subscription_plan_name')) {
      subscription = SubscriptionDetails(
        planName: prefs.getString('subscription_plan_name') ?? '',
        billingCycle: prefs.getString('subscription_billing_cycle') ?? '',
        price: prefs.getDouble('subscription_price') ?? 0.0,
        currency: prefs.getString('subscription_currency') ?? 'KWD',
        remainingDays: prefs.getInt('subscription_remaining_days') ?? 0,
      );
    }

    _userDetails = UserDetails(
      fullName: fullName,
      mosque: mosque,
      mosqueLocation: mosqueLocation,
      subscription: subscription,
      profileImage: profileImage,
    );
    notifyListeners();
  }

  Future<void> updateUserDetails({
    required String fullName,
    required String mosque,
    required String mosqueLocation,
    String? profileImage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('full_name', fullName);
    await prefs.setString('mosque', mosque);
    await prefs.setString('mosque_location', mosqueLocation);
    if (profileImage != null) {
      await prefs.setString('profile_image', profileImage);
    }

    _userDetails = UserDetails(
      fullName: fullName,
      mosque: mosque,
      mosqueLocation: mosqueLocation,
      profileImage: profileImage ?? _userDetails?.profileImage,
      subscription: _userDetails?.subscription,
    );
    notifyListeners();
  }

  Future<void> updateSubscriptionDetails({
    required String planName,
    required String billingCycle,
    required double price,
    required String currency,
    required int remainingDays,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('subscription_plan_name', planName);
    await prefs.setString('subscription_billing_cycle', billingCycle);
    await prefs.setDouble('subscription_price', price);
    await prefs.setString('subscription_currency', currency);
    await prefs.setInt('subscription_remaining_days', remainingDays);

    if (_userDetails != null) {
      _userDetails = UserDetails(
        fullName: _userDetails!.fullName,
        mosque: _userDetails!.mosque,
        mosqueLocation: _userDetails!.mosqueLocation,
        profileImage: _userDetails!.profileImage,
        subscription: SubscriptionDetails(
          planName: planName,
          billingCycle: billingCycle,
          price: price,
          currency: currency,
          remainingDays: remainingDays,
        ),
      );
      notifyListeners();
    }
  }

  Future<void> clearSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('subscription_plan_name');
    await prefs.remove('subscription_billing_cycle');
    await prefs.remove('subscription_price');
    await prefs.remove('subscription_currency');
    await prefs.remove('subscription_remaining_days');

    if (_userDetails != null) {
      _userDetails = UserDetails(
        fullName: _userDetails!.fullName,
        mosque: _userDetails!.mosque,
        mosqueLocation: _userDetails!.mosqueLocation,
        profileImage: _userDetails!.profileImage,
        subscription: null,
      );
      notifyListeners();
    }
  }

  Future<void> clearUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('full_name');
    await prefs.remove('mosque');
    await prefs.remove('mosque_location');
    await prefs.remove('profile_image');
    await clearSubscription();

    _userDetails = null;
    notifyListeners();
  }
}
