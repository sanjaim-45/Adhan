import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

class ReturnRequestApiService {
  final String baseUrl;
  final http.Client client;

  ReturnRequestApiService({required this.baseUrl, required this.client});

  Future<bool> submitReturnRequest({
    required String deviceId,
    required String reason,
    required String description,
    required String shippingAddressId,
    required List<XFile> images,
    required String accessToken,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/ReportDeviceRequest/submit'),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $accessToken';
      request.headers['Accept'] = 'application/json';

      // Add form fields
      request.fields['DeviceId'] = deviceId;
      request.fields['Reason'] = reason;
      request.fields['Description'] = description;
      request.fields['ShippingAddressId'] = shippingAddressId;

      // Add image files with proper MIME types
      for (var image in images) {
        final mimeTypeData = lookupMimeType(image.path);
        final mimeParts = mimeTypeData?.split('/') ?? ['image', 'jpeg'];

        final file = await http.MultipartFile.fromPath(
          'Images', // Ensure this matches the backend's expected field name
          image.path,
          contentType: MediaType(
            mimeParts[0],
            mimeParts[1],
          ), // e.g., image/jpeg
        );

        request.files.add(file);
      }

      // Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print('Response body: ${response.body}');
        print('Images submitted: ${images.map((img) => img.path).toList()}');
        return true;
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception(
          'Failed to submit return request: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error in submitReturnRequest: $e');
      throw Exception('Error submitting return request: $e');
    }
  }
}
