import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prayerunitesss/ui/screens/transaction/transaction_details.dart';

import '../../../utils/font_mediaquery.dart';

class PaymentHistoryPage extends StatelessWidget {
  const PaymentHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final List<Map<String, dynamic>> payments = [
      {"status": "Paid", "color": Colors.green[100], "textColor": Colors.green},
      {"status": "Paid", "color": Colors.green[100], "textColor": Colors.green},
      {"status": "Cancelled", "color": Colors.red[100], "textColor": Colors.red},
      {"status": "Cancelled", "color": Colors.red[100], "textColor": Colors.red},
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leadingWidth: 30,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, size: width * 0.043),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: Text(
              'Payment History',
              style: GoogleFonts.beVietnamPro(
                color: Colors.black,
                letterSpacing: -0.5,
                fontSize: getDynamicFontSize(context, 0.05),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Past Payment history",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: width * 0.045,
              ),
            ),
            SizedBox(height: height * 0.02),
            ...payments.map((payment) => GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TransactionDetailsPage(),
                  ),
                );
              },
              child: PaymentTile(
                width: width,
                height: height,
                status: payment["status"],
                bgColor: payment["color"],
                textColor: payment["textColor"],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class PaymentTile extends StatelessWidget {
  final double width;
  final double height;
  final String status;
  final Color bgColor;
  final Color textColor;

  const PaymentTile({
    super.key,
    required this.width,
    required this.height,
    required this.status,
    required this.bgColor,
    required this.textColor,
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
                  '17 Sep 2023',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: width * 0.045,
                  ),
                ),
                SizedBox(height: height * 0.005),
                Text(
                  'Subscription from 4/14/2023–5/13/2023',
                  style: TextStyle(
                    fontSize: width * 0.035,
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
                '1.000 KWD',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.045,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: height * 0.005),
                padding: EdgeInsets.symmetric(horizontal: width * 0.025, vertical: height * 0.003),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: textColor,
                    fontSize: width * 0.03,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
