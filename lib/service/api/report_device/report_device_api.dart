import 'dart:convert';

import 'package:prayerunitesss/model/api/report_device/report_device_model.dart';

import '../templete_api/api_service.dart';

class ReportDeviceApiService {
  final ApiService apiService;

  ReportDeviceApiService({required this.apiService});

  Future<List<ReportDeviceModel>> getAllMyReports() async {
    try {
      final response = await apiService.sendRequest(
        '${apiService.baseUrl}/api/ReportDeviceRequest/GetAllMyReports',
        'GET',
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((item) => ReportDeviceModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to load reports: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching reports: $e');
    }
  }

  Future<bool> cancelReportRequest(String reportId) async {
    try {
      final response = await apiService.sendRequest(
        '${apiService.baseUrl}/api/ReportDeviceRequest/CancelReportRequest',
        'POST',
        body: {'reportId': reportId},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to cancel request: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to cancel request: $e');
    }
  }

  Future<bool> cancelOrderRequest(String reportId, String reason) async {
    try {
      final response = await apiService.sendRequest(
        '${apiService.baseUrl}/api/Customer/CancelOrder',
        'POST',
        body: {'orderId': reportId, 'cancellationReason': 'test'},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to cancel request: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to cancel request: $e');
    }
  }

  Future<bool> cancelOrderRequestItem(String reportId, String reason) async {
    try {
      final response = await apiService.sendRequest(
        '${apiService.baseUrl}/api/Customer/CancelOrderItem',
        'POST',
        body: {'orderItemId': reportId, 'cancellationReason': 'test'},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to cancel request: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to cancel request: $e');
    }
  }
}
