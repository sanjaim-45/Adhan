import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:prayerunitesss/utils/app_urls.dart';

import '../templete_api/api_service.dart';

class DeleteAccountService {
  final ApiService _apiService;

  DeleteAccountService(this._apiService);

  Future<bool> deleteCustomerAccount(int customerId) async {
    try {
      final response = await _apiService.sendRequest(
        '${AppUrls.appUrl}/api/Customer/DeleteCustomer?id=$customerId',
        'POST',
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['message'] == "Customer deleted successfully") {
          return true;
        }
      } else {
        final errorData = json.decode(response.body);
        debugPrint('Server error: ${errorData['message'] ?? 'Unknown error'}');
      }

      return false;
    } catch (e) {
      debugPrint('Exception while deleting account: $e');
      return false;
    }
  }
}
