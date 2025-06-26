// device_request_model.dart
class DeviceRequest {
  final List<DeviceRequestItem> devices;
  final int selectedShippingAddressId;
  final String paymentMethod;

  DeviceRequest({
    required this.devices,
    required this.selectedShippingAddressId,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      'devices': devices.map((device) => device.toJson()).toList(),
      'selectedShippingAddressId': selectedShippingAddressId,
      'paymentMethod': paymentMethod,
    };
  }
}

class DeviceRequestItem {
  final int deviceTypeId;
  final int quantity;
  final int subscriptionPlanId;
  final int mosqueId;

  DeviceRequestItem({
    this.deviceTypeId = 1, // Default to 1 as specified
    required this.quantity,
    required this.subscriptionPlanId,
    required this.mosqueId,
  });

  Map<String, dynamic> toJson() {
    return {
      'deviceTypeId': deviceTypeId,
      'quantity': quantity,
      'subscriptionPlanId': subscriptionPlanId,
      'mosqueId': mosqueId,
    };
  }
}

class DeviceRequestResponse {
  final bool success;
  final String message;
  final int orderId;

  DeviceRequestResponse({
    required this.success,
    required this.message,
    required this.orderId,
  });

  factory DeviceRequestResponse.fromJson(Map<String, dynamic> json) {
    return DeviceRequestResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      orderId: json['orderId'] ?? 0,
    );
  }
}
