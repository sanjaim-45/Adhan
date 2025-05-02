import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../model/api/edit_customer/edit_customer_api_model.dart';
import '../templete_api/api_service.dart';

class CustomerService {
  final String baseUrl;
  final ApiService _apiService;

  CustomerService({required this.baseUrl}) : _apiService = ApiService(baseUrl: baseUrl);

  Future<Map<String, dynamic>> getCustomerById(int id) async {
    final response = await _apiService.sendRequest(
      '$baseUrl/api/Customer/getCustomerById?id=$id',
      'GET',
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      // Token refresh already attempted by ApiService
      throw Exception('Authentication failed. Please login again.');
    } else {
      throw Exception('Failed to load customer data: ${response.statusCode}');
    }
  }

  Future<EditCustomerResponse> editCustomer(EditCustomerRequest request) async {
    final response = await _apiService.sendRequest(
      '$baseUrl/api/Customer/EditCustomer',
      'POST',
      body: request.toJson(),
    );

    if (response.statusCode == 200) {
      return EditCustomerResponse.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('Authentication failed. Please login again.');
    } else {
      throw Exception('Failed to update customer: ${response.statusCode}');
    }
  }
}