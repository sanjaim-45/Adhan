// lib/providers/customer_provider.dart
import 'package:flutter/material.dart';

import '../../model/api/customer/customer_all_details_model/customer_all_details.dart';
import '../../service/api/customer/customer_service_api.dart';

class CustomerProvider extends ChangeNotifier {
  CustomerAllDetails? _customerDetails;
  bool _isLoading = false;
  String? _error;

  CustomerAllDetails? get customerDetails => _customerDetails;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCustomerDetails(String baseUrl) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final customerServices = CustomerServices(baseUrl: baseUrl);
      final details = await customerServices.getAllCustomerDetails();
      _customerDetails = details;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCustomerDetails(CustomerAllDetails details) {
    _customerDetails = details;
    notifyListeners();
  }
}
