import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prayerunitesss/ui/screens/transaction/transaction_details.dart';
import 'package:provider/provider.dart';

import '../../../model/api/transaction/transaction_response.dart';
import '../../../service/api/templete_api/api_service.dart';
import '../../../utils/custom_appbar.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  late Future<TransactionResponse?> _transactionsFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = _loadTransactions();
  }

  Future<TransactionResponse?> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final response = await apiService.getAllCustomerTransactions();
      return response;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: CustomAppBar(
        title: 'Payment History',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.05,
          vertical: height * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height * 0.02),
            Expanded(
              child: FutureBuilder<TransactionResponse?>(
                future: _transactionsFuture,
                builder: (context, snapshot) {
                  if (_isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 50,
                            color: Colors.red[400],
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Error loading payments',
                            style: TextStyle(
                              fontSize: width * 0.04,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 10),
                          Text(
                            'No Payment found',
                            style: TextStyle(
                              fontSize: width * 0.04,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    );
                  }

                  final transactions = snapshot.data!.data;

                  return RefreshIndicator(
                    onRefresh: _loadTransactions,
                    child: ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => TransactionDetailsPage(
                                      transaction: transaction,
                                    ),
                              ),
                            );
                          },
                          child: PaymentTile(
                            width: width,
                            height: height,
                            transaction: transaction,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentTile extends StatelessWidget {
  final double width;
  final double height;
  final CustomerTransaction transaction;

  const PaymentTile({
    super.key,
    required this.width,
    required this.height,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: height * 0.015),
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: height * 0.018,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(width * 0.03),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(transaction.paymentDate),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: width * 0.040,
                  ),
                ),
                SizedBox(height: height * 0.005),
                Text(
                  'Subscription ${_formatCustomDate(transaction.startDate)} - ${_formatCustomDate(transaction.endDate)}',
                  style: TextStyle(
                    fontSize: width * 0.033,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${transaction.amountPaid.toStringAsFixed(2)} KWD" ??
                    'N/A', // Handle null case
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.04,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: height * 0.005),
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.02,
                  vertical: height * 0.001,
                ),
                decoration: BoxDecoration(
                  color: transaction.statusBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  transaction.status,
                  style: TextStyle(
                    color: transaction.statusColor,
                    fontSize: width * 0.03,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatCustomDate(DateTime date) {
    return DateFormat('M/d/yyyy').format(date);
  }
}
