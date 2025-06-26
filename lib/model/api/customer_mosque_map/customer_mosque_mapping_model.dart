class CustomerMosqueMapRequest {
  final int customerId;
  final int deviceId;
  final int mosqueId;

  CustomerMosqueMapRequest({
    required this.customerId,
    required this.deviceId,
    required this.mosqueId,
  });

  Map<String, dynamic> toJson() => {
    "customerId": customerId,
    "deviceId": deviceId,
    "mosqueId": mosqueId,
  };
}
