class ShippingAddressss {
  final int id;
  final String fullName;
  final String? phoneNumber;
  final String? email;
  final String address;
  final bool isDefault;

  ShippingAddressss({
    required this.id,
    required this.fullName,
    this.phoneNumber,
    this.email,
    required this.address,
    required this.isDefault,
  });

  // Add fromJson method if you don't have one
  factory ShippingAddressss.fromJson(Map<String, dynamic> json) {
    return ShippingAddressss(
      id: json['id'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      address: json['address'],
      isDefault: json['isDefault'],
    );
  }
}
