class CurrentSubscriptionModel {
  final int customerId;
  final int subscriptionId;
  final DateTime startDate;
  final DateTime endDate;
  final int planId;
  final String planName;
  final String description;
  final String billingCycle;
  final int durationDays;
  final int remainingDays;
  final double price;
  final String currency;
  final double ratePerMonth;

  CurrentSubscriptionModel({
    required this.customerId,
    required this.subscriptionId,
    required this.startDate,
    required this.endDate,
    required this.planId,
    required this.planName,
    required this.description,
    required this.billingCycle,
    required this.durationDays,
    required this.remainingDays,
    required this.price,
    required this.currency,
    required this.ratePerMonth,
  });

  factory CurrentSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return CurrentSubscriptionModel(
      customerId: json['customerId'],
      subscriptionId: json['subscriptionId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      planId: json['planId'],
      planName: json['planName'],
      description: json['description'],
      billingCycle: json['billingCycle'],
      durationDays: json['durationDays'],
      remainingDays: json['remainingDays'],
      price: json['price'].toDouble(),
      currency: json['currency'],
      ratePerMonth: json['ratePerMonth'].toDouble(),
    );
  }
}
