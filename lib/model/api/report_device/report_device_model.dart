class ReportDeviceModel {
  final int reportId;
  final String deviceName;
  final String serialNumber;
  final String reason;
  final String description;
  final List<String> imagePath; // Changed to List<String>
  final String status;
  final DateTime submittedOn;
  final String shippingFullName;
  final String shippingPhoneNumber;
  final String shippingEmail;
  final String shippingAddress;

  ReportDeviceModel({
    required this.reportId,
    required this.deviceName,
    required this.serialNumber,
    required this.reason,
    required this.description,
    required this.imagePath,
    required this.status,
    required this.submittedOn,
    required this.shippingFullName,
    required this.shippingPhoneNumber,
    required this.shippingEmail,
    required this.shippingAddress,
  });

  factory ReportDeviceModel.fromJson(Map<String, dynamic> json) {
    return ReportDeviceModel(
      reportId: json['reportId'],
      deviceName: json['deviceName'],
      serialNumber: json['serialNumber'],
      reason: json['reason'],
      description: json['description'],
      imagePath: List<String>.from(
        json['imagePath'],
      ), // Convert to List<String>
      status: json['status'],
      submittedOn: DateTime.parse(json['submittedOn']),
      shippingFullName: json['shippingFullName'],
      shippingPhoneNumber: json['shippingPhoneNumber'],
      shippingEmail: json['shippingEmail'],
      shippingAddress: json['shippingAddress'],
    );
  }
}
