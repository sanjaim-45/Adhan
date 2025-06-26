import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prayerunitesss/utils/app_urls.dart';
import 'package:shimmer/shimmer.dart';

import '../../../model/api/customer/customer_all_details_model/customer_all_details.dart';
import '../../../service/api/customer/customer_service_api.dart';
import '../../../utils/font_mediaquery.dart';
import '../../screens/subscription/upgrade.dart';

class SubscriptionCard extends StatefulWidget {
  const SubscriptionCard({super.key});

  @override
  State<SubscriptionCard> createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends State<SubscriptionCard> {
  CustomerAllDetails? customerDetails;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchCustomerDetails();
  }

  Future<void> _fetchCustomerDetails() async {
    try {
      final customerServices = CustomerServices(baseUrl: AppUrls.appUrl);
      final details = await customerServices.getAllCustomerDetails();
      if (mounted) {
        setState(() {
          customerDetails = details;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 120, height: 20, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(width: 150, height: 24, color: Colors.white),
                  const SizedBox(height: 4),
                  Container(width: 100, height: 16, color: Colors.white),
                ],
              ),
              Container(
                width: 80,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(child: Text("Error Occurred "));
    }

    // Safely check for devices and subscriptions
    final devices = customerDetails?.data?.devices ?? [];
    Subscriptionss? subscription;

    try {
      subscription =
          devices
              .firstWhere((device) => device.subscription != null)
              .subscription;
    } catch (e) {
      // No device with subscription found
      subscription = null;
    }

    if (subscription == null) {
      return _buildSubscribeNowCard(context);
    }

    final formattedEndDate = DateFormat(
      'd MMM y',
    ).format(DateTime.parse(subscription.endDate));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004408), Color(0xFF2E7D32)],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF73A876),
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: Text(
                  "My Current Plan",
                  style: GoogleFonts.beVietnamPro(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${subscription.paidAmount} KWD',
                      style: GoogleFonts.beVietnamPro(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' / month',
                      style: GoogleFonts.beVietnamPro(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Expires on:',
                      style: GoogleFonts.beVietnamPro(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    TextSpan(
                      text: ' $formattedEndDate',
                      style: GoogleFonts.beVietnamPro(
                        color: const Color(0xFFF4DE8B),
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Transform.translate(
            offset: Offset(
              MediaQuery.of(context).size.width * 0.01,
              MediaQuery.of(context).size.height * 0.03,
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SubscriptionPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Upgrade',
                style: GoogleFonts.beVietnamPro(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribeNowCard(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        leading: Image.asset(
          "assets/images/upgrade/king.png",
          height: width * 0.05,
          width: width * 0.05,
        ),
        title: Text(
          "Subscribe Now",
          style: GoogleFonts.beVietnamPro(
            fontSize: getFontRegularSize(context),
            letterSpacing: -0.5,
            color: Colors.white,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: getFontRegularSize(context),
          color: Colors.white,
        ),
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => SubscriptionPage()));
        },
        dense: true,
        isThreeLine: false,
      ),
    );
  }
}
