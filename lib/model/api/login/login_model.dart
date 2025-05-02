class LoginResponse {
  final String message;
  final LoginData data;

  LoginResponse({
    required this.message,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw FormatException('Null JSON provided to LoginResponse');
    }

    return LoginResponse(
      message: json['message'] as String? ?? 'No message',
      data: LoginData.fromJson(json['data'] as Map<String, dynamic>?),
    );
  }
}

class LoginData {
  final String customerId;
  final List<dynamic> devices;
  final Subscription? subscription;

  LoginData({
    required this.customerId,
    required this.devices,
    this.subscription,
  });

  factory LoginData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return LoginData(
        customerId: '',
        devices: [],
        subscription: null,
      );
    }

    return LoginData(
      customerId: (json['customerId']?.toString() ?? ''),
      devices: json['devices'] as List<dynamic>? ?? [],
      subscription: json['subscription'] != null
          ? Subscription.fromJson(json['subscription'] as Map<String, dynamic>?)
          : null,
    );
  }
}

class Subscription {
  final String firstName;
  final String lastName;
  final String mosque;
  final String mosqueLocation;
  final SubscriptionPlan? subscriptionPlan;

  Subscription({
    required this.firstName,
    required this.lastName,
    required this.mosque,
    required this.mosqueLocation,
    this.subscriptionPlan,
  });

  factory Subscription.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Subscription(
        firstName: '',
        lastName: '',
        mosque: '',
        mosqueLocation: '',
        subscriptionPlan: null,
      );
    }

    return Subscription(
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      mosque: json['mosque'] as String? ?? '',
      mosqueLocation: json['mosqueLocation'] as String? ?? '',
      subscriptionPlan: json['subscriptionPlan'] != null
          ? SubscriptionPlan.fromJson(json['subscriptionPlan'] as Map<String, dynamic>)
          : null,
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

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
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