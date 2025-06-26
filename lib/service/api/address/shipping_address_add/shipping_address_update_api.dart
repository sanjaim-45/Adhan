// shipping_address_update_service.dart
import 'dart:convert';

import '../../templete_api/api_service.dart';

class ShippingAddressUpdateApiService {
  final ApiService apiService;

  ShippingAddressUpdateApiService({required this.apiService});

  Future<Map<String, dynamic>> updateShippingAddress({
    required int addressId,
    required String fullName,
    required String phoneNumber,
    required String email,
    required String address,
    required bool makeDefault,
  }) async {
    try {
      final response = await apiService.sendRequest(
        '${apiService.baseUrl}/api/CustomerShippingAddress/UpdateShippingAddress?addressId=$addressId',
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
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to update shipping address: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to update shipping address: $e');
    }
  }
}
