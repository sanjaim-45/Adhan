// lib/services/api/shipping_address_api_service.dart

import 'dart:convert';

import '../../../../model/api/address/shipping_address_create_model.dart';
import '../../templete_api/api_service.dart';

class ShippingAddressApiService {
  final ApiService _apiService;

  ShippingAddressApiService(this._apiService);

  Future<ShippingAddressResponse> createShippingAddress({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String address,
    required bool makeDefault,
  }) async {
    try {
      final response = await _apiService.sendRequest(
        '${_apiService.baseUrl}/api/CustomerShippingAddress/CreateShippingAddress',
        'POST',
        body: {
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'email': email,
          'address': address,
          'makeDefault': makeDefault,
        },
      );

      if (response.statusCode == 200) {
        return ShippingAddressResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to create shipping address: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to create shipping address: $e');
    }
  }
}
