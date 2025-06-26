// services/order_api_service.dart
import 'dart:convert';

import '../../../model/api/order/get_all_orders.dart';
import '../templete_api/api_service.dart';

class OrderApiService {
  final ApiService apiService;

  OrderApiService(this.apiService);

  Future<List<Order>> getMyOrders() async {
    try {
      final response = await apiService.sendRequest(
        '${apiService.baseUrl}/api/Customer/MyOrders',
        'GET',
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((order) => Order.fromJson(order)).toList();
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }
}
