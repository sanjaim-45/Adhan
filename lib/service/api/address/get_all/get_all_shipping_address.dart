// lib/services/api/shipping_address_api_service.dart
import 'dart:convert';

import '../../../../model/api/address/shipping_address_create_model.dart';
import '../../templete_api/api_service.dart';

class ShippingAddressGetAllApiService {
  final ApiService apiService;

  ShippingAddressGetAllApiService({required this.apiService});

  Future<List<ShippingAddress>> getShippingAddresses() async {
    try {
      final response = await apiService.sendRequest(
        '${apiService.baseUrl}/api/CustomerShippingAddress/GetShippingAddress',
        'GET',
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Server returned empty response');
        }

        try {
          final List<dynamic> decodedJson = json.decode(response.body);
          return decodedJson
              .map((addressJson) => ShippingAddress.fromJson(addressJson))
              .toList();
        } catch (e) {
          throw Exception('Failed to decode JSON: $e');
        }
      } else {
        throw Exception(
          'Failed to fetch shipping addresses (Status: ${response.statusCode})\n'
          'Response: ${response.body.isNotEmpty ? response.body : "No error message"}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
