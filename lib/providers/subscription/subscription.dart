// lib/providers/subscription_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/api/customer/customer_all_details_model/customer_all_details.dart';
import '../../service/api/customer/customer_service_api.dart';
import '../../utils/app_urls.dart';

class SubscriptionProviders with ChangeNotifier {
  CustomerAllDetails? _customerDetails;
  bool _isLoading = true;
  bool _hasError = false;

  CustomerAllDetails? get customerDetails => _customerDetails;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  bool get hasActiveSubscription {
    return _customerDetails?.data?.devices.any(
          (device) => device.subscription?.subscriptionStatus == true,
        ) ??
        false;
  }

  Future<void> loadCustomerDetails() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getString('customerId');

      if (customerId != null) {
        final service = CustomerServices(baseUrl: AppUrls.appUrl);
        _customerDetails = await service.getAllCustomerDetails();
      }

      _hasError = false;
    } catch (e) {
      _hasError = true;
      debugPrint('Error loading customer details: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshSubscriptionStatus() async {
    await loadCustomerDetails();
  }
}
