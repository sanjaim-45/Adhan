// device_request_service.dart
import 'dart:convert';

import 'package:prayerunitesss/model/api/device_request/device_request_model.dart';

import '../templete_api/api_service.dart';

class DeviceRequestService {
  final ApiService apiService;

  DeviceRequestService({required this.apiService});

  Future<DeviceRequestResponse> submitDeviceRequest(
    DeviceRequest request,
  ) async {
    try {
      final response = await apiService.sendRequest(
        '${apiService.baseUrl}/api/Customer/DeviceRequest',
        'POST',
        body: request.toJson(),
      );

      if (response.statusCode == 200) {
        return DeviceRequestResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to submit device request: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to submit device request: ${e.toString()}');
    }
  }
}
