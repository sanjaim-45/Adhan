// lib/model/api/shipping_address/shipping_address_model.dart

class ShippingAddressModel {
  final int shippingAddressId;
  final int customerId;
  final String fullName;
  final String phoneNumber;
  final String email;
  final String address;
  final bool isDefault;

  ShippingAddressModel({
    required this.shippingAddressId,
    required this.customerId,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.isDefault,
  });

  factory ShippingAddressModel.fromJson(Map<String, dynamic> json) {
    return ShippingAddressModel(
      shippingAddressId: json['shippingAddressId'],
      customerId: json['customerId'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      address: json['address'],
      isDefault: json['isDefault'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'makeDefault': isDefault,
    };
  }
}

class ShippingAddressResponse {
  final String message;
  final ShippingAddressModel address;

  ShippingAddressResponse({required this.message, required this.address});

  factory ShippingAddressResponse.fromJson(Map<String, dynamic> json) {
    return ShippingAddressResponse(
      message: json['message'],
      address: ShippingAddressModel.fromJson(json['address']),
    );
  }
}

// lib/model/shipping_address_model.dart
class ShippingAddress {
  final int shippingAddressId;
  final String fullName;
  final String phoneNumber;
  final String email;
  final String address;
  final bool isDefault;

  ShippingAddress({
    required this.shippingAddressId,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.isDefault,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      shippingAddressId: json['shippingAddressId'] as int,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String,
      address: json['address'] as String,
      isDefault: json['isDefault'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shippingAddressId': shippingAddressId,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'isDefault': isDefault,
    };
  }
}
