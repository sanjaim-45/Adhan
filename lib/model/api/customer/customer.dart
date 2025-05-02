
class Customer {
  final int customerId;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  final String? civilId;
  final String? passportNumber;
  final String? profileImageUrl;
  final DateTime createdDate;

  Customer({
    required this.customerId,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    this.civilId,
    this.passportNumber,
    this.profileImageUrl,
    required this.createdDate,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customerId'] as int,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String,
      civilId: json['civilId'] as String?,
      passportNumber: json['passportNumber'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      createdDate: DateTime.parse(json['createdDate'] as String),
    );
  }

  String get fullName => '$firstName $lastName';
}