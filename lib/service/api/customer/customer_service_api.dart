import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:prayerunitesss/model/api/customer/customer_all_details_model/customer_all_details.dart';

import '../../../model/api/edit_customer/edit_customer_api_model.dart';
import '../templete_api/api_service.dart';
import '../tokens/token_service.dart';

class CustomerServices {
  final String baseUrl;
  final ApiService _apiService;

  CustomerServices({required this.baseUrl})
    : _apiService = ApiService(baseUrl: baseUrl);

  Future<Map<String, dynamic>> getCustomerById() async {
    final response = await _apiService.sendRequest(
      '$baseUrl/api/Customer/getCustomerById',
      'GET',
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load customer data: ${response.statusCode}');
    }
  }

  Future<http.Response> editCustomer(
    EditCustomerRequest request, {
    File? profileImage,
  }) async {
    final uri = Uri.parse('$baseUrl/api/Customer/EditCustomer');
    final accessToken = await TokenService.getAccessToken();

    var multipartRequest = http.MultipartRequest('POST', uri);

    // Add JSON fields
    multipartRequest.fields['CustomerId'] = request.customerId.toString();
    multipartRequest.fields['FirstName'] = request.firstName;
    multipartRequest.fields['LastName'] = request.lastName;
    if (request.email != null) {
      multipartRequest.fields['Email'] = request.email!;
    }
    if (request.civilIdExpiryDate != null) {
      multipartRequest.fields['CivilIdExpiryDate'] =
          request.civilIdExpiryDate!.toIso8601String();
    }

    if (request.civilId != null) {
      multipartRequest.fields['CivilId'] = request.civilId!;
    }
    if (request.passportNumber != null) {
      multipartRequest.fields['PassportNumber'] = request.passportNumber!;
    }
    multipartRequest.fields['Status'] = request.status.toString();
    multipartRequest.fields['UserTypeId'] = request.userTypeId.toString();

    // Add image file if available
    if (profileImage != null) {
      final mimeTypeData = lookupMimeType(profileImage.path);
      final mimeParts = mimeTypeData?.split('/') ?? ['image', 'jpeg'];

      final file = await http.MultipartFile.fromPath(
        'ProfilePicture',
        profileImage.path,
        contentType: MediaType(mimeParts[0], mimeParts[1]),
      );
      multipartRequest.files.add(file);
    }

    // Add authorization header
    if (accessToken != null) {
      multipartRequest.headers['Authorization'] = 'Bearer $accessToken';
    }

    try {
      final responseStream = await multipartRequest.send();
      final response = await http.Response.fromStream(responseStream);
      return response;
    } catch (e) {
      throw Exception('Failed to edit customer: $e');
    }
  }

  Future<CustomerAllDetails> getAllCustomerDetails() async {
    final response = await _apiService.sendRequest(
      '$baseUrl/api/Customer/getAllCustomers',
      'GET',
    );

    if (response.statusCode == 200) {
      return CustomerAllDetails.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to load customer details: ${response.statusCode}',
      );
    }
  }

  // Example method for delivery address operations using the template
  Future<dynamic> addDeliveryAddress(Map<String, dynamic> addressData) async {
    final response = await _apiService.sendRequest(
      '$baseUrl/api/DeliveryAddress/Add',
      'POST',
      body: addressData,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add delivery address: ${response.statusCode}');
    }
  }
}
