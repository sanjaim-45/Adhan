// models/transaction_model.dart
import 'package:flutter/material.dart';

class TransactionResponse {
  final String message;
  final List<CustomerTransaction> data;

  TransactionResponse({required this.message, required this.data});

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      message: json['message'] ?? '',
      data:
          json['data'] == null
              ? []
              : (json['data'] as List)
                  .map((item) => CustomerTransaction.fromJson(item))
                  .toList(),
    );
  }
}

class CustomerTransaction {
  final String transactionNumber;
  final int customerId;
  final String customerName;
  final String mosqueName;
  final String subscriptionType;
  final double amountPaid;
  final String amountPaidFormatted;
  final String paymentStatus;
  final DateTime paymentDate;
  final String paymentMethod;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime nextRenewal;
  final double? amount;
  final bool? isCancelled;

  CustomerTransaction({
    required this.transactionNumber,
    required this.customerId,
    required this.customerName,
    required this.mosqueName,
    required this.subscriptionType,
    required this.amountPaid,
    required this.amountPaidFormatted,
    required this.paymentStatus,
    required this.paymentDate,
    required this.paymentMethod,
    required this.startDate,
    required this.endDate,
    required this.nextRenewal,
    this.amount,
    this.isCancelled,
  });

  factory CustomerTransaction.fromJson(Map<String, dynamic> json) {
    return CustomerTransaction(
      transactionNumber: json['transactionNumber'] ?? '',
      customerId: json['customerId'] ?? 0,
      customerName: json['customerName'] ?? '',
      mosqueName: json['mosqueName'] ?? '',
      subscriptionType: json['subscriptionType'] ?? '',
      amountPaid: (json['amountPaid'] ?? 0).toDouble(),
      amountPaidFormatted: json['amountPaidFormatted'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      paymentDate:
          json['paymentDate'] != null
              ? DateTime.parse(json['paymentDate'])
              : DateTime.now(),
      paymentMethod: json['paymentMethod'] ?? '',
      startDate:
          json['startDate'] != null
              ? DateTime.parse(json['startDate'])
              : DateTime.now(),
      endDate:
          json['endDate'] != null
              ? DateTime.parse(json['endDate'])
              : DateTime.now(),
      nextRenewal:
          json['nextRenewal'] != null
              ? DateTime.parse(json['nextRenewal'])
              : DateTime.now(),
      amount: json['amount'] != null ? (json['amount']).toDouble() : null,
      isCancelled: json['isCancelled'], // Nullable bool
    );
  }

  String get status => isCancelled == true ? 'Cancelled' : paymentStatus;
  Color get statusColor => isCancelled == true ? Colors.red : Colors.green;
  Color get statusBgColor =>
      isCancelled == true ? Colors.red[100]! : Colors.green[100]!;
}
