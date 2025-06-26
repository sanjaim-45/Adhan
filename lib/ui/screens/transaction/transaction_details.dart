import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prayerunitesss/utils/custom_appbar.dart';

import '../../../model/api/transaction/transaction_response.dart';

class TransactionDetailsPage extends StatelessWidget {
  final CustomerTransaction transaction;

  const TransactionDetailsPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBar(
        title: "Transaction Details",
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Column(
          children: [
            const SizedBox(height: 24),

            Image.asset(
              'assets/images/profile/success_gif.gif',
              height: 250,
              width: 250,
            ),

            const SizedBox(height: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  transaction.transactionNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    transaction.paymentStatus,
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat(
                'dd MMM yyyy, hh:mm a',
              ).format(transaction.paymentDate),
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // User Info Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoTile(
                  icon: Icons.person,
                  title: transaction.customerName ?? 'N/A',
                  subtitle: transaction.customerId.toString(),
                ),
                const SizedBox(width: 12),

                _buildInfoTile(
                  icon: Icons.smartphone,
                  title: 'Mobile Subscription',
                  subtitle: transaction.subscriptionType,
                ),
              ],
            ),

            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: _buildInfoTile(
                icon: Icons.tag,
                title: "Payment Method",
                subtitle: transaction.paymentMethod,
              ),
            ),

            const SizedBox(height: 24),

            // General Information Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.info_outline, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'General Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildLabelValue(
                          'Transaction ID',
                          transaction.transactionNumber,
                          inRow: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildLabelValue(
                          'Status',
                          transaction.paymentStatus,
                          isStatus: true,
                          inRow: true,
                        ),
                      ),
                    ],
                  ),
                  _buildLabelValue('Amount', transaction.amountPaidFormatted),
                  _buildLabelValue(
                    'Device',
                    'Device 1 (DEV123) - Mapped to Grand Mosque',
                  ),
                  _buildLabelValue(
                    'Start Date',
                    DateFormat(
                      'dd MMM yyyy, hh:mm a',
                    ).format(transaction.startDate!),
                  ),
                  if (transaction.nextRenewal != null)
                    _buildLabelValue(
                      'Next Renewal Date',
                      DateFormat(
                        'dd MMM yyyy, hh:mm a',
                      ).format(transaction.nextRenewal!),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.black54),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(subtitle, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildLabelValue(
    String label,
    String value, {
    bool isStatus = false,
    bool inRow = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align label to the start
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4), // Add some space between label and value
          isStatus
              ? Container(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  value, // Use the passed value for status as well
                  style: const TextStyle(color: Colors.green),
                ),
              )
              : Text(value, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}
