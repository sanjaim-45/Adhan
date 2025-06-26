import 'dart:convert';

import 'package:prayerunitesss/utils/app_urls.dart';

import '../../../model/api/change_password/change_password_model.dart';
import '../templete_api/api_service.dart';

class ChangePasswordService {
  final ApiService _apiService;

  ChangePasswordService(this._apiService);

  static String get _baseUrl => '${AppUrls.appUrl}/api/Customer/ChangePassword';

  Future<ChangePasswordResponse> changePassword(
    ChangePasswordRequest request,
  ) async {
    try {
      final response = await _apiService.sendRequest(
        _baseUrl,
        'POST',
        body: request.toJson(),
      );

      if (response.statusCode == 200) {
        return ChangePasswordResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to change password: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
      throw Exception('$e');
    }
  }
}
