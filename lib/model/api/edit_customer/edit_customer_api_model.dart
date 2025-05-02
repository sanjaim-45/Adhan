

import '../customer/customer.dart';

class EditCustomerRequest {
  final int customerId;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  final String? civilId;
  final String? passportNumber;

  EditCustomerRequest({
    required this.customerId,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    this.civilId,
    this.passportNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'email': email,
      if (civilId != null) 'civilId': civilId,
      if (passportNumber != null) 'passportNumber': passportNumber,
    };
  }
}

class EditCustomerResponse {
  final String message;
  final Customer data;

  EditCustomerResponse({
    required this.message,
    required this.data,
  });

  factory EditCustomerResponse.fromJson(Map<String, dynamic> json) {
    return EditCustomerResponse(
      message: json['message'],
      data: Customer.fromJson(json['data']),
    );
  }
}