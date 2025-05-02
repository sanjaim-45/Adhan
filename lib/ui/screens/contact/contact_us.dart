import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/font_mediaquery.dart';

class ContactUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
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
            leadingWidth: 30, // Adjust the width of the leading icon
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_new,                      size: screenWidth * 0.043,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: Text(
              'Contact Us',
              style: GoogleFonts.beVietnamPro(
                color: Colors.black,
                letterSpacing: -0.5,
                fontSize: getDynamicFontSize(context,0.05),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(

          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.01),

              // "We're Here to Help"
              Text(
                "We're Here to Help",
                style: GoogleFonts.beVietnamPro(
                  fontSize: getFontRegularSize(context),
                  letterSpacing: -0.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                "If you have any questions, need assistance with your subscription, or want to know more about the speaker service, feel free to reach out to us.",
                style: GoogleFonts.beVietnamPro(
                  fontSize: getFontRegularSize(context),
                  letterSpacing: -0.5,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Contact Information Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Contact Information",
                      style: GoogleFonts.beVietnamPro(
                        fontSize: getFontRegularSize(context),
                        letterSpacing: -0.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on, size: screenWidth * 0.05),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Mosque Address:",
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: getFontRegularSize(context),
                                  letterSpacing: -0.5,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                "Masjid Al-Noor, 123 Islamic Street,\nChennai, Tamil Nadu, India – 600001",
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: getFontRegularSize(context),
                                  letterSpacing: -0.5,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    Row(
                      children: [
                        Icon(Icons.phone, size: screenWidth * 0.05),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          "Phone:",
                          style: GoogleFonts.beVietnamPro(
                            fontSize: getFontRegularSize(context),
                            letterSpacing: -0.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          "+123 987654321",
                          style: GoogleFonts.beVietnamPro(
                            fontSize: getFontRegularSize(context),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    Row(
                      children: [
                        Icon(Icons.email, size: screenWidth * 0.05),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          "Email:",
                          style: GoogleFonts.beVietnamPro(
                            fontSize: getFontRegularSize(context),
                            letterSpacing: -0.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          "support@majid.com",
                          style: GoogleFonts.beVietnamPro(
                            fontSize: getFontRegularSize(context),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.04),

              // App Support
              Text(
                "App Support",
                style: GoogleFonts.beVietnamPro(
                  fontSize: getFontRegularSize(context),
                  letterSpacing: -0.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.005),
              Text(
                "Facing issues with the app or speaker?",
                style: GoogleFonts.beVietnamPro(
                  fontSize: getFontRegularSize(context),
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              bulletPoint(context, "Speaker not working?", "Try restarting the device and ensure it’s connected to power."),
              bulletPoint(context, "Subscription not showing?", "Go to My Account > Restore Subscription"),
              bulletPoint(context, "Didn’t receive your speaker yet?", "Check status in My Orders or contact us directly."),

              SizedBox(height: screenHeight * 0.01),

              // Support Hours
              Text(
                "Support Hours",
                style: GoogleFonts.beVietnamPro(
                  fontSize: getFontRegularSize(context),
                  letterSpacing: -0.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                "Monday – Saturday: 9 AM – 6 PM\nSunday: Closed",
                style: GoogleFonts.beVietnamPro(
                  fontSize: getFontRegularSize(context),
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
            ],
          ),
        ),
      ),
    );
  }

  Widget bulletPoint(BuildContext context, String title, String description) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.03),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "• ",
            style: GoogleFonts.beVietnamPro(fontSize: screenWidth * 0.04),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: "$title\n",
                style: GoogleFonts.beVietnamPro(
                  fontSize: getFontRegularSize(context),
                  letterSpacing: -0.5,                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: "→ $description",
                    style: GoogleFonts.beVietnamPro(
                      fontSize: getFontRegular35Size(context),
                      letterSpacing: -0.5,                      fontWeight: FontWeight.normal,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
