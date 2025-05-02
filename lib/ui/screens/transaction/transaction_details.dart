import 'package:flutter/material.dart';

class TransactionDetailsPage extends StatelessWidget {
  const TransactionDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = size.width * 0.05;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Transaction Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent transaction history',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Wrap(
                runSpacing: 16,
                children: const [
                  TransactionRow(title: 'Transaction ID', value: 'TXN-324AJHS1'),
                  TransactionRow(title: 'Invoice Number', value: 'INV-000234'),
                  TransactionRow(title: 'User Name', value: 'Ahmed Al-Mutairi'),
                  TransactionRow(title: 'User ID', value: 'UID1023'),
                  TransactionRow(title: 'Masjid', value: 'Masjid Al-Noor, Salmiya'),
                  TransactionRow(title: 'Subscription Type', value: 'Monthly'),
                  TransactionRow(title: 'Amount', value: '1.000 KWD'),
                  TransactionRow(title: 'Payment Status', value: 'Success'),
                  TransactionRow(title: 'Payment Date', value: '01 April 2025, 10:32 AM'),
                  TransactionRow(title: 'Payment Method', value: 'K-Net'),
                  TransactionRow(title: 'Next Renewal', value: '01 May 2025'),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF8F8F8),
    );
  }
}

class TransactionRow extends StatelessWidget {
  final String title;
  final String value;

  const TransactionRow({Key? key, required this.title, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyleTitle = TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87);
    final textStyleValue = TextStyle(fontSize: 14, color: Colors.grey[700]);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(title, style: textStyleTitle)),
        Expanded(child: Text(value, style: textStyleValue, textAlign: TextAlign.end)),
      ],
    );
  }
}
