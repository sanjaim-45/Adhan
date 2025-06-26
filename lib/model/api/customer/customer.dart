class Customer {
  final int customerId;
  final String firstName;
  final String? lastName; // Made nullable
  final String phoneNumber;
  final String? email; // Made nullable
  final String? civilId;
  final String? passportNumber;
  final String? profileImageUrl;
  final DateTime createdDate;
  final DateTime? civilIdExpiryDate; // Made nullable

  Customer({
    required this.customerId,
    required this.firstName,
    this.lastName, // No longer required
    required this.phoneNumber,
    this.email, // No longer required
    this.civilId,
    this.passportNumber,
    this.profileImageUrl,
    required this.createdDate,
    this.civilIdExpiryDate,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: _parseInt(json['customerId']),
      firstName: _parseString(json['firstName'], isRequired: true),
      lastName: _parseString(json['lastName']),
      phoneNumber: _parseString(json['phoneNumber'], isRequired: true),
      email: _parseString(json['email']),
      civilId: _parseString(json['civilId']),
      passportNumber: _parseString(json['passportNumber']),
      profileImageUrl: _parseString(json['profileImagePath']),
      createdDate: _parseDateTime(json['createdDate']),
      civilIdExpiryDate: _parseNullableDateTime(json['civilIdExpiryDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      'phoneNumber': phoneNumber,
      if (email != null) 'email': email,
      if (civilId != null) 'civilId': civilId,
      if (passportNumber != null) 'passportNumber': passportNumber,
      if (profileImageUrl != null) 'profileImagePath': profileImageUrl,
      'createdDate': createdDate.toIso8601String(),
      if (civilIdExpiryDate != null)
        'civilIdExpiryDate': civilIdExpiryDate!.toIso8601String(),
    };
  }

  String get fullName =>
      [firstName, lastName].where((n) => n?.isNotEmpty ?? false).join(' ');

  // Helper methods for safe parsing
  static String _parseString(dynamic value, {bool isRequired = false}) {
    if (value == null || value.toString().isEmpty) {
      if (isRequired) {
        throw FormatException('Required field is null or empty');
      }
      return '';
    }
    return value.toString();
  }

  static int _parseInt(dynamic value) {
    if (value == null) {
      throw FormatException('Customer ID cannot be null');
    }
    if (value is int) return value;
    final parsedValue = int.tryParse(value.toString());
    if (parsedValue == null) {
      throw FormatException('Invalid customerId: $value');
    }
    return parsedValue;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) {
      throw FormatException('Created date cannot be null');
    }
    if (value is DateTime) return value;
    final parsedDate = DateTime.tryParse(value.toString());
    if (parsedDate == null) {
      throw FormatException('Invalid date format: $value');
    }
    return parsedDate;
  }

  static DateTime? _parseNullableDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) return value;
    final parsedDate = DateTime.tryParse(value.toString());
    if (parsedDate == null) {
      // Optionally, you could log a warning here or handle it differently
    }
    return parsedDate;
  }

  @override
  String toString() {
    return 'Customer(customerId: $customerId, name: $fullName, phone: $phoneNumber, email: ${email ?? "not provided"})';
  }
}
