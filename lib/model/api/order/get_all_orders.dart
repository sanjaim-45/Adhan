class Order {
  final int orderId;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final String deliveryStatus;
  final String paymentMethod;
  final String paymentStatus;
  final double totalAmount;
  final List<OrderItem> items;

  Order({
    required this.orderId,
    required this.orderDate,
    this.deliveryDate,
    required this.deliveryStatus,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.totalAmount,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'] as int? ?? 0,
      orderDate:
          json['orderDate'] != null
              ? DateTime.tryParse(json['orderDate'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
      deliveryDate:
          json['deliveryDate'] != null
              ? DateTime.tryParse(json['deliveryDate'].toString())
              : null,
      deliveryStatus: json['deliveryStatus'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? '',
      paymentStatus: json['paymentStatus'] as String? ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      items:
          (json['items'] as List<dynamic>?)?.map((item) {
            return OrderItem.fromJson(item as Map<String, dynamic>);
          }).toList() ??
          [],
    );
  }
}

class OrderItem {
  final int orderItemId;
  final int deviceTypeId;
  final int quantity;
  final int subscriptionPlanId;
  final String planName;
  final double price;
  final String currency;
  final int? assignmentId;
  final int deviceId;
  final String deviceName;
  final String serialNumber;
  final String macAddress;
  final String qrPath;
  final String assignmentRemarks;
  final DateTime? deviceAssignedDate;
  final int mosqueId;
  final String mosqueName;
  final String mosqueLocation;
  final String contactPersonName;
  final String contactNumber;
  final String streetName;
  final String area;
  final String city;
  final String governorate;
  final String paciNumber;
  final String orderStatus;

  OrderItem({
    required this.orderItemId,
    required this.deviceTypeId,
    required this.quantity,
    required this.subscriptionPlanId,
    required this.planName,
    required this.price,
    required this.currency,
    this.assignmentId,
    required this.deviceId,
    required this.deviceName,
    required this.serialNumber,
    required this.macAddress,
    required this.qrPath,
    required this.assignmentRemarks,
    this.deviceAssignedDate,
    required this.mosqueId,
    required this.mosqueName,
    required this.mosqueLocation,
    required this.contactPersonName,
    required this.contactNumber,
    required this.streetName,
    required this.area,
    required this.city,
    required this.governorate,
    required this.paciNumber,
    required this.orderStatus,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      orderItemId: json['orderItemId'] as int? ?? 0,
      deviceTypeId: json['deviceTypeId'] as int? ?? 0,
      quantity: json['quantity'] as int? ?? 0,
      subscriptionPlanId: json['subscriptionPlanId'] as int? ?? 0,
      planName: json['planName'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? '',
      assignmentId: json['assignmentId'] as int?,
      deviceId: json['deviceId'] as int? ?? 0,
      deviceName: json['deviceName'] as String? ?? '',
      serialNumber: json['serialNumber'] as String? ?? '',
      macAddress: json['macAddress'] as String? ?? '',
      qrPath: json['qrPath'] as String? ?? '',
      assignmentRemarks: json['assignmentRemarks'] as String? ?? '',
      deviceAssignedDate:
          json['deviceAssignedDate'] != null
              ? DateTime.tryParse(json['deviceAssignedDate'].toString())
              : null,
      mosqueId: json['mosqueId'] as int? ?? 0,
      mosqueName: json['mosqueName'] as String? ?? '',
      mosqueLocation: json['mosqueLocation'] as String? ?? '',
      contactPersonName: json['contactPersonName'] as String? ?? '',
      contactNumber: json['contactNumber'] as String? ?? '',
      streetName: json['streetName'] as String? ?? '',
      area: json['area'] as String? ?? '',
      city: json['city'] as String? ?? '',
      governorate: json['governorate'] as String? ?? '',
      paciNumber: json['paciNumber'] as String? ?? '',
      orderStatus: json['orderStatus'] as String? ?? '',
    );
  }
}
