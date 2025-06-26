class MosqueResponse {
  final String message;
  final List<Mosque> data;

  MosqueResponse({required this.message, required this.data});

  factory MosqueResponse.fromJson(Map json) {
    return MosqueResponse(
      message: json['message'] ?? '',
      data:
          (json['data'] as List?)?.map((i) => Mosque.fromJson(i)).toList() ??
          [],
    );
  }
}

class Mosque {
  final int customerCount;
  final int mosqueId;
  final String mosqueName;
  final String mosqueLocation;
  final String contactPersonName;
  final String contactNumber;
  final String streetName;
  final String area;
  final String city;
  final String governorate;
  final String pacinumber;
  final bool status;

  Mosque({
    required this.customerCount,
    required this.mosqueId,
    required this.mosqueName,
    required this.mosqueLocation,
    required this.contactPersonName,
    required this.contactNumber,
    required this.streetName,
    required this.area,
    required this.city,
    required this.governorate,
    required this.pacinumber,
    required this.status,
  });

  factory Mosque.fromJson(Map json) {
    return Mosque(
      customerCount: json['customerCount'] ?? 0,
      mosqueId: json['mosqueId'] ?? 0,
      mosqueName: json['mosqueName'] ?? '',
      mosqueLocation: json['mosqueLocation'] ?? '',
      contactPersonName: json['contactPersonName'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      streetName: json['streetName'] ?? '',
      area: json['area'] ?? '',
      city: json['city'] ?? '',
      governorate: json['governorate'] ?? '',
      pacinumber: json['pacinumber'] ?? '',
      status: json['status'] ?? false,
    );
  }
}
