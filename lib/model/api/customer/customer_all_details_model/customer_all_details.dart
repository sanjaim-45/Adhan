class CustomerAllDetails {
  final String message;
  final CustomerAll? data;

  CustomerAllDetails({required this.message, this.data});

  factory CustomerAllDetails.fromJson(Map<String, dynamic>? json) {
    if (json == null) return CustomerAllDetails(message: '');

    final dataJson = json['data'];
    return CustomerAllDetails(
      message: json['message']?.toString() ?? '',
      data:
          (dataJson is Map<String, dynamic>)
              ? CustomerAll.fromJson(dataJson)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'data': data?.toJson()};
  }
}

class CustomerAll {
  final int customerId;
  final String fullName;
  final String phoneNumber;
  final String email;
  final String? profileImagePath;
  final String? address;
  final String? civilId;
  final String? civilIdExpiryDate;
  final String createdDate;
  final bool isActive;
  final List<CustomerDevice> devices;

  CustomerAll({
    required this.customerId,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    this.profileImagePath,
    this.address,
    this.civilId,
    this.civilIdExpiryDate,
    required this.createdDate,
    required this.isActive,
    required this.devices,
  });

  factory CustomerAll.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return CustomerAll(
        customerId: 0,
        fullName: '',
        phoneNumber: '',
        email: '',
        createdDate: '',
        isActive: false,
        devices: [],
      );
    }

    return CustomerAll(
      customerId: json['customerId'] as int? ?? 0,
      fullName: json['fullName']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      profileImagePath: json['profileImagePath']?.toString(),
      address: json['address']?.toString() ?? '',
      civilId: json['civilId']?.toString() ?? '',
      civilIdExpiryDate: json['civilIdExpiryDate']?.toString(),
      createdDate: json['createdDate']?.toString() ?? '',
      isActive: json['isActive'] as bool? ?? false,
      devices:
          json['devices'] is List
              ? (json['devices'] as List)
                  .map(
                    (i) => CustomerDevice.fromJson(i as Map<String, dynamic>?),
                  )
                  .whereType<CustomerDevice>()
                  .toList()
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'profileImagePath': profileImagePath,
      'address': address,
      'civilId': civilId,
      'civilIdExpiryDate': civilIdExpiryDate,
      'createdDate': createdDate,
      'isActive': isActive,
      'devices': devices.map((device) => device.toJson()).toList(),
    };
  }
}

class CustomerDevice {
  final int customerDeviceMapId;
  final int deviceId;
  final String deviceName;
  final String serialNumber;
  final String macAddress;
  final String ipAddress;
  final String qrPath;
  final bool deviceStatus;
  final String deviceCreatedDate;
  final Mosquess? mosque;
  final Subscriptionss? subscription;

  CustomerDevice({
    required this.customerDeviceMapId,
    required this.deviceId,
    required this.deviceName,
    required this.serialNumber,
    required this.macAddress,
    required this.ipAddress,
    required this.qrPath,
    required this.deviceStatus,
    required this.deviceCreatedDate,
    this.mosque,
    this.subscription,
  });

  factory CustomerDevice.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return CustomerDevice(
        customerDeviceMapId: 0,
        deviceId: 0,
        deviceName: '',
        serialNumber: '',
        macAddress: '',
        ipAddress: '',
        qrPath: '',
        deviceStatus: false,
        deviceCreatedDate: '',
      );
    }

    return CustomerDevice(
      customerDeviceMapId: json['customerDeviceMapId'] as int? ?? 0,
      deviceId: json['deviceId'] as int? ?? 0,
      deviceName: json['deviceName']?.toString() ?? '',
      serialNumber: json['serialNumber']?.toString() ?? '',
      macAddress: json['macAddress']?.toString() ?? '',
      ipAddress: json['ipAddress']?.toString() ?? '',
      qrPath: json['qrPath']?.toString() ?? '',
      deviceStatus: json['deviceStatus'] as bool? ?? false,
      deviceCreatedDate: json['deviceCreatedDate']?.toString() ?? '',
      mosque:
          json['mosque'] is Map<String, dynamic>
              ? Mosquess.fromJson(json['mosque'] as Map<String, dynamic>)
              : null,
      subscription:
          json['subscription'] is Map<String, dynamic>
              ? Subscriptionss.fromJson(
                json['subscription'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerDeviceMapId': customerDeviceMapId,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'serialNumber': serialNumber,
      'macAddress': macAddress,
      'ipAddress': ipAddress,
      'qrPath': qrPath,
      'deviceStatus': deviceStatus,
      'deviceCreatedDate': deviceCreatedDate,
      'mosque': mosque?.toJson(),
      'subscription': subscription?.toJson(),
    };
  }
}

class Mosquess {
  final int mosqueId;
  final String mosqueName;
  final String mosqueLocation;
  final String streetName;
  final String area;
  final String city;
  final String governorate;
  final String paciNumber;
  final String contactPersonName;
  final String contactNumber;
  final bool mosqueMapStatus;
  final String mosqueMapCreatedDate;

  Mosquess({
    required this.mosqueId,
    required this.mosqueName,
    required this.mosqueLocation,
    required this.streetName,
    required this.area,
    required this.city,
    required this.governorate,
    required this.paciNumber,
    required this.contactPersonName,
    required this.contactNumber,
    required this.mosqueMapStatus,
    required this.mosqueMapCreatedDate,
  });

  factory Mosquess.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Mosquess(
        mosqueId: 0,
        mosqueName: '',
        mosqueLocation: '',
        streetName: '',
        area: '',
        city: '',
        governorate: '',
        paciNumber: '',
        contactPersonName: '',
        contactNumber: '',
        mosqueMapStatus: false,
        mosqueMapCreatedDate: '',
      );
    }

    return Mosquess(
      mosqueId: json['mosqueId'] as int? ?? 0,
      mosqueName: json['mosqueName']?.toString() ?? '',
      mosqueLocation: json['mosqueLocation']?.toString() ?? '',
      streetName: json['streetName']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      governorate: json['governorate']?.toString() ?? '',
      paciNumber: json['paciNumber']?.toString() ?? '',
      contactPersonName: json['contactPersonName']?.toString() ?? '',
      contactNumber: json['contactNumber']?.toString() ?? '',
      mosqueMapStatus: json['mosqueMapStatus'] as bool? ?? false,
      mosqueMapCreatedDate: json['mosqueMapCreatedDate']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mosqueId': mosqueId,
      'mosqueName': mosqueName,
      'mosqueLocation': mosqueLocation,
      'streetName': streetName,
      'area': area,
      'city': city,
      'governorate': governorate,
      'paciNumber': paciNumber,
      'contactPersonName': contactPersonName,
      'contactNumber': contactNumber,
      'mosqueMapStatus': mosqueMapStatus,
      'mosqueMapCreatedDate': mosqueMapCreatedDate,
    };
  }
}

class Subscriptionss {
  final int subscriptionID;
  final int planID;
  final String startDate;
  final String endDate;
  final String paymentStatus;
  final double paidAmount;
  final String paymentMethod;
  final bool subscriptionStatus;

  Subscriptionss({
    required this.subscriptionID,
    required this.planID,
    required this.startDate,
    required this.endDate,
    required this.paymentStatus,
    required this.paidAmount,
    required this.paymentMethod,
    required this.subscriptionStatus,
  });

  factory Subscriptionss.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Subscriptionss(
        subscriptionID: 0,
        planID: 0,
        startDate: '',
        endDate: '',
        paymentStatus: '',
        paidAmount: 0.0,
        paymentMethod: '',
        subscriptionStatus: false,
      );
    }

    return Subscriptionss(
      subscriptionID: json['subscriptionID'] as int? ?? 0,
      planID: json['planID'] as int? ?? 0,
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      subscriptionStatus: json['subscriptionStatus'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscriptionID': subscriptionID,
      'planID': planID,
      'startDate': startDate,
      'endDate': endDate,
      'paymentStatus': paymentStatus,
      'paidAmount': paidAmount,
      'paymentMethod': paymentMethod,
      'subscriptionStatus': subscriptionStatus,
    };
  }
}
