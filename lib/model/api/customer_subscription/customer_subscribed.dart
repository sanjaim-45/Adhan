import 'package:intl/intl.dart';

class CustomerSubscription {
  final int subscriptionId;
  final int userId;
  final int planId;
  final int? mosqueId;
  final DateTime startDate;
  final DateTime endDate;
  final String paymentStatus;

  CustomerSubscription({
    required this.subscriptionId,
    required this.userId,
    required this.planId,
    this.mosqueId,
    required this.startDate,
    required this.endDate,
    required this.paymentStatus,
  });

  factory CustomerSubscription.fromJson(Map<String, dynamic> json) {
    return CustomerSubscription(
      subscriptionId: json['subscriptionId'],
      userId: json['userId'],
      planId: json['planId'],
      mosqueId: json['mosqueId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      paymentStatus: json['paymentStatus'],
    );
  }

  String get formattedStartDate => DateFormat('dd MMM yyyy').format(startDate);
  String get formattedEndDate => DateFormat('dd MMM yyyy').format(endDate);
  String get duration => '${startDate.year != endDate.year ? formattedStartDate : DateFormat('dd MMM').format(startDate)} - $formattedEndDate';
}