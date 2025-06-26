class LoginResponse {
  final String message;
  final CustomerDetailResponse customerDetailResponse;
  final String accessToken;
  final String refreshToken;

  LoginResponse({
    required this.message,
    required this.customerDetailResponse,
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw FormatException('Null JSON provided to LoginResponse');
    }

    return LoginResponse(
      message: json['message'] as String? ?? '',
      customerDetailResponse: CustomerDetailResponse.fromJson(
        json['customerDetailResponse'] as Map<String, dynamic>?,
      ),
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
    );
  }
}

class CustomerDetailResponse {
  final String customerId;
  final String userType;
  final List<Device> devices;
  final Subscription subscription;
  final String profileImage;

  CustomerDetailResponse({
    required this.customerId,
    required this.userType,
    required this.devices,
    required this.subscription,
    required this.profileImage,
  });

  factory CustomerDetailResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return CustomerDetailResponse(
        customerId: '',
        userType: '',
        devices: [],
        subscription: Subscription.fromJson(null),
        profileImage: '',
      );
    }

    return CustomerDetailResponse(
      customerId: json['customerId']?.toString() ?? '',
      userType: json['userType'] as String? ?? '',
      devices:
          (json['devices'] as List<dynamic>?)
              ?.map((e) => Device.fromJson(e as Map<String, dynamic>?))
              .toList() ??
          [],
      subscription: Subscription.fromJson(
        json['subscription'] as Map<String, dynamic>?,
      ),
      profileImage: json['profileImage'] as String? ?? '',
    );
  }
}

class Device {
  final int customerDeviceMapId;
  final int customerId;
  final int deviceId;
  final bool status;
  final String customerName;
  final String deviceName;

  Device({
    required this.customerDeviceMapId,
    required this.customerId,
    required this.deviceId,
    required this.status,
    required this.customerName,
    required this.deviceName,
  });

  factory Device.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Device(
        customerDeviceMapId: 0,
        customerId: 0,
        deviceId: 0,
        status: false,
        customerName: '',
        deviceName: '',
      );
    }

    return Device(
      customerDeviceMapId: (json['customerDeviceMapId'] as int?) ?? 0,
      customerId: (json['customerId'] as int?) ?? 0,
      deviceId: (json['deviceId'] as int?) ?? 0,
      status: (json['status'] as bool?) ?? false,
      customerName: (json['customerName'] as String?) ?? '',
      deviceName: (json['deviceName'] as String?) ?? '',
    );
  }
}

class Subscription {
  final String firstName;
  final String? lastName;
  final String mosque;
  final String mosqueLocation;
  final SubscriptionPlan subscriptionPlan;

  Subscription({
    required this.firstName,
    this.lastName,
    required this.mosque,
    required this.mosqueLocation,
    required this.subscriptionPlan,
  });

  factory Subscription.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Subscription(
        firstName: '',
        lastName: null,
        mosque: '',
        mosqueLocation: '',
        subscriptionPlan: SubscriptionPlan.fromJson(null),
      );
    }

    return Subscription(
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String?,
      mosque: json['mosque'] as String? ?? '',
      mosqueLocation: json['mosqueLocation'] as String? ?? '',
      subscriptionPlan: SubscriptionPlan.fromJson(
        json['subscriptionPlan'] as Map<String, dynamic>?,
      ),
    );
  }
}

class SubscriptionPlan {
  final int planId;
  final String planName;
  final String description;
  final String billingCycle;
  final int durationDays;
  final int remainingDays;
  final double price;
  final String currency;

  SubscriptionPlan({
    required this.planId,
    required this.planName,
    required this.description,
    required this.billingCycle,
    required this.durationDays,
    required this.remainingDays,
    required this.price,
    required this.currency,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return SubscriptionPlan(
        planId: 0,
        planName: '',
        description: '',
        billingCycle: '',
        durationDays: 0,
        remainingDays: 0,
        price: 0.0,
        currency: 'KWD',
      );
    }

    return SubscriptionPlan(
      planId: (json['planId'] as int?) ?? 0,
      planName: (json['planName'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      billingCycle: (json['billingCycle'] as String?) ?? '',
      durationDays: (json['durationDays'] as int?) ?? 0,
      remainingDays: (json['remainingDays'] as int?) ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: (json['currency'] as String?) ?? 'KWD',
    );
  }
}
