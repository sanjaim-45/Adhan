import '../customer/customer.dart';

class EditCustomerRequest {
  final int customerId;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? email;
  final String? civilId;
  final String? passportNumber;
  final bool status;
  final int userTypeId;
  final String? profileImagePath;
  final DateTime? civilIdExpiryDate;

  EditCustomerRequest({
    required this.customerId,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.email,
    this.civilId,
    this.passportNumber,
    required this.status,
    required this.userTypeId,
    this.profileImagePath,
    this.civilIdExpiryDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'CustomerId': customerId,
      'FirstName': firstName,
      'LastName': lastName,
      'PhoneNumber': phoneNumber,
      'Email': email,
      if (civilId != null) 'CivilId': civilId,
      if (passportNumber != null) 'PassportNumber': passportNumber,
      'Status': status,
      'UserTypeId': userTypeId,
      if (profileImagePath != null) 'ProfileImagePath': profileImagePath,
      if (civilIdExpiryDate != null)
        'CivilIdExpiryDate': civilIdExpiryDate!.toIso8601String(),
    };
  }
}

class EditCustomerResponse {
  final String message;
  final Customer data;

  EditCustomerResponse({required this.message, required this.data});

  factory EditCustomerResponse.fromJson(Map<String, dynamic> json) {
    return EditCustomerResponse(
      message: json['message'],
      data: Customer.fromJson(json['data']),
    );
  }
}
