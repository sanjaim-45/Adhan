import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../utils/font_mediaquery.dart';
import '../../../utils/home/home_utils.dart';
import '../notification/live_notification.dart';
import '../subscription/device_request/device_request_screen.dart';
import '../subscription/upgrade.dart';

class HomePageMosqueHeader extends StatelessWidget {
  const HomePageMosqueHeader({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required Duration timeRemaining,
    required Map<String, dynamic> nextPrayer,
    required this.hasActiveSubscription, // Add this parameter
  }) : _timeRemaining = timeRemaining,
       _nextPrayer = nextPrayer;

  final double screenHeight;
  final double screenWidth;
  final Duration _timeRemaining;
  final Map<String, dynamic> _nextPrayer;
  final bool hasActiveSubscription; // To check subscription status

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: screenHeight * 0.04,
        right: screenWidth * 0.05,
      ),
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.8,
          colors: [Color(0xFF2E7D32), Color(0xFF004408)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: screenWidth * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  "assets/images/name_logo.png",
                  height: screenHeight * 0.08,
                  width: screenWidth * 0.3,
                ),
                Row(
                  children: [
                    if (hasActiveSubscription) // Show Upgrade button only if there's an active subscription
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SubscriptionPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA1812E),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenHeight * 0.015,
                          ),
                        ),
                        child: Text(
                          "Upgrade",
                          style: GoogleFonts.beVietnamPro(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: getFontRegularSize(context),
                          ),
                        ),
                      ),
                    SizedBox(width: screenWidth * 0.02),
                    CircleAvatar(
                      radius: screenWidth * 0.05,
                      backgroundColor: Colors.white,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const LiveNotification(),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.notifications_none_outlined,
                          size: screenWidth * 0.05,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Show different content based on subscription status
          if (hasActiveSubscription)
            _buildPrayerInfoContent()
          else
            _buildSubscriptionPromotionContent(context),

          Image.asset("assets/images/border_ui.png", fit: BoxFit.cover),
        ],
      ),
    );
  }

  Widget _buildPrayerInfoContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: screenWidth * 0.05,
            top: screenHeight * 0.010,
          ),
          child: Row(
            children: [
              Text(
                "NEXT PRAYER IN",
                style: GoogleFonts.beVietnamPro(
                  color: Colors.white70,
                  fontSize: screenWidth * 0.03,
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.004,
                  horizontal: screenWidth * 0.02,
                ),
                child: Text(
                  HomeUtils().formatCountdown(_timeRemaining),
                  style: GoogleFonts.beVietnamPro(
                    fontSize: screenWidth * 0.025,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: screenWidth * 0.05,
            top: screenHeight * 0.01,
          ),
          child: Text(
            _nextPrayer['name'],
            style: GoogleFonts.beVietnamPro(
              fontSize: screenWidth * 0.08,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.05),
          child: Text(
            _nextPrayer['arabic'],
            style: GoogleFonts.beVietnamPro(
              color: Colors.white,
              fontSize: screenWidth * 0.04,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: screenWidth * 0.05,
            top: screenHeight * 0.005,
          ),
          child: Row(
            children: [
              Image.asset(
                _nextPrayer['imagePath'] ??
                    'assets/images/cloud/Clear-night.png',
                height: 24,
                width: 24,
              ),
              SizedBox(width: screenWidth * 0.01),
              Text(
                DateFormat('hh:mm a').format(DateTime.now()),
                style: GoogleFonts.beVietnamPro(
                  fontSize: screenWidth * 0.055,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionPromotionContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: screenWidth * 0.05,
        top: screenHeight * 0.02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "🕌 Unlock the Voice of the Masjid",
            style: GoogleFonts.beVietnamPro(
              color: Colors.white,
              fontSize: screenWidth * 0.045,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            "Subscribe monthly to listen to live salah directly from your masjid, wherever you are.",
            style: GoogleFonts.beVietnamPro(
              color: Colors.white70,
              fontSize: screenWidth * 0.03,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Row(
            children: [
              // Subscribe Button - make sure it has sufficient padding
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionPage(),
                    ),
                  );
                },
                icon: Image.asset(
                  "assets/images/upgrade/king.png",
                  height: 18,
                  width: 18,
                ),
                label: Text(
                  'Subscribe',
                  style: GoogleFonts.beVietnamPro(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.015,
                  ),
                  minimumSize: Size(
                    screenWidth * 0.3,
                    screenHeight * 0.05,
                  ), // Ensure minimum tap area
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ), // This was misplaced. It should close the ElevatedButton.icon
              SizedBox(width: screenWidth * 0.03),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DeviceRequestScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.015,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          "assets/images/device_request_black.png",
                          height: 18,
                          width: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Device Request',
                          style: GoogleFonts.beVietnamPro(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
