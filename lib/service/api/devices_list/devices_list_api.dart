// services/device_service.dart
import 'dart:convert';

import '../../../model/api/devices/my_devices_model.dart';
import '../templete_api/api_service.dart';

class DeviceService {
  final ApiService apiService;

  DeviceService({required this.apiService});

  Future<List<DeviceDropdown>> getMyDevices() async {
    try {
      final response = await apiService.sendRequest(
        '${apiService.baseUrl}/api/ReportDeviceRequest/GetEligibleDevices',
        'GET',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((item) => DeviceDropdown.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load devices: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load devices: $e');
    }
  }
}
