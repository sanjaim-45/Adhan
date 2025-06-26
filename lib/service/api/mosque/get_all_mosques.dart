import 'dart:convert';

import '../../../model/api/mosque/mosque_model.dart';
import '../templete_api/api_service.dart';

class MosqueService {
  final ApiService apiService;

  MosqueService({required this.apiService});

  Future<MosqueResponse> getAllMosques() async {
    try {
      final response = await apiService.sendRequest(
        '${apiService.baseUrl}/api/Mosque/getAllMosques',
        'GET',
      );

      if (response.statusCode == 200) {
        return MosqueResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to load mosques. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to load mosques: $e');
    }
  }
}
