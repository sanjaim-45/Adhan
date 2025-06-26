import 'package:flutter/cupertino.dart';

import '../templete_api/api_service.dart';

class CustomerMosqueMapService {
  final ApiService apiService;

  CustomerMosqueMapService({required this.apiService});

  Future<void> assignDevicesToMosques(
    List<Map<String, dynamic>> assignments,
  ) async {
    try {
      final response = await apiService.sendRequest(
        '${apiService.baseUrl}/api/CustomerMosqueMap/map',
        'POST',
        body: assignments,
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to assign devices to mosques: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error assigning devices to mosques: $e');
      throw Exception('Failed to assign devices to mosques: ${e.toString()}');
    }
  }
}
