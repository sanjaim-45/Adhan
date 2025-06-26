class DeviceDropdown {
  final int deviceId;
  final String deviceName;
  final int deviceType;

  DeviceDropdown({
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
  });

  factory DeviceDropdown.fromJson(Map<String, dynamic> json) {
    return DeviceDropdown(
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
      deviceType: json['deviceType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceType': deviceType,
    };
  }
}
