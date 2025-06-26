import 'package:flutter/cupertino.dart';

import '../templete_api/api_service.dart';

class MosqueChangeRequestService {
  final ApiService apiService;

  MosqueChangeRequestService({required this.apiService});

  Future<void> submitMosqueChangeRequest({
    required int deviceId,
    required int currentMosqueId,
    required int requestedMosqueId,
    required String reason,
  }) async {
    try {
      final response = await apiService.sendRequest(
        '${apiService.baseUrl}/api/MosqueChangeRequest/RequestMosqueChange',
        'POST',
        body: {
          'deviceId': deviceId,
          'currentMosqueId': currentMosqueId,
          'requestedMosqueId': requestedMosqueId,
          'reason': reason,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to submit mosque change request. Status code: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      // Log the error or handle it as needed
      debugPrint('Error submitting mosque change request: $e');
      throw Exception('Failed to submit mosque change request: $e');
    }
  }
}
