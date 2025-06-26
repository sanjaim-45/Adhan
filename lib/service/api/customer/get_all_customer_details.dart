import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:prayerunitesss/model/api/customer/customer_all_details_model/customer_all_details.dart';

import '../templete_api/api_service.dart';

class CustomerssService {
  final ApiService apiService;

  CustomerssService({required this.apiService});

  Future<CustomerAllDetails> getAllCustomerDetails() async {
    try {
      final response = await apiService.sendRequest(
        '${apiService.baseUrl}/api/Customer/GetAllCustomerDetails',
        'GET',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CustomerAllDetails.fromJson(data);
      } else {
        throw Exception(
          'Failed to load customer details. Status code: ${response.statusCode}',
        );
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error occurred: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Error parsing response data: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<CustomerAllDetails> getCustomerById(int customerId) async {
    try {
      final response = await apiService.sendRequest(
        '${apiService.baseUrl}/api/Customer/GetCustomerById/$customerId',
        'GET',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CustomerAllDetails.fromJson(data);
      } else {
        throw Exception(
          'Failed to load customer details. Status code: ${response.statusCode}',
        );
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error occurred: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Error parsing response data: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
