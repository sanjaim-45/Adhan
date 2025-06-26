import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/font_mediaquery.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  bool isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final contentPadding = screenWidth * 0.05;
    const overlapHeight = 20.0;

    return Scaffold(
      body: Stack(
        children: [
          // Background image with rounded bottom
          Column(
            children: [
              SizedBox(
                height: screenHeight * 0.5 - overlapHeight,
                child: ClipRRect(
                  child: Image.asset(
                    'assets/images/mosque.png',
                    width: screenWidth,
                    height: screenHeight * 0.4,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // This empty expanded pushes the content area down
              Expanded(child: Container(color: Colors.white)),
            ],
          ),

          // Back button and title
          Positioned(
            top: screenHeight * 0.06,
            left: screenWidth * 0.04,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: screenWidth * 0.043,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Text(
                    "About Us",
                    style: GoogleFonts.beVietnamPro(
                      color: Colors.white,
                      fontSize: getDynamicFontSize(context, 0.05),
                      letterSpacing: -0.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content area that overlaps the image
          Positioned(
            top: screenHeight * 0.35, // Adjust this value to control overlap
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: contentPadding,
                    vertical: screenHeight * 0.04,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Introduction
                      Text(
                        "Introduction",
                        style: GoogleFonts.beVietnamPro(
                          fontSize: getFontBoldSize(context),
                          letterSpacing: -0.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      Text(
                        "\" Our Mosque is dedicated to serving our community by connecting hearts through faith and prayer. Established in [Year], we aim to bring the beauty of prayer closer to every home.\"",
                        style: GoogleFonts.beVietnamPro(
                          fontSize: getFontRegularSize(context),
                          letterSpacing: -0.5,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),

                      // App Purpose
                      Text(
                        "App Purpose",
                        style: GoogleFonts.beVietnamPro(
                          fontSize: getFontBoldSize(context),
                          letterSpacing: -0.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        "Why this app was created:",
                        style: GoogleFonts.beVietnamPro(
                          fontSize: getFontRegularSize(context),
                          letterSpacing: -0.5,
                          color: const Color(0xFF767676),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        "\"With prayerunites, we bring the sound of prayer into your home. Our subscription service provides users with a speaker, so they can stay connected to the mosque anytime.\"",
                        style: GoogleFonts.beVietnamPro(
                          fontSize: getFontRegularSize(context),
                          letterSpacing: -0.5,
                          color: const Color(0xFF767676),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),

                      // Features
                      Text(
                        "Features",
                        style: GoogleFonts.beVietnamPro(
                          fontSize: getFontBoldSize(context),
                          letterSpacing: -0.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _featureBullet("Speaker delivery", screenWidth),
                          _featureBullet(
                            "Live prayer broadcasting",
                            screenWidth,
                          ),
                          _featureBullet(
                            "Prayer time notifications",
                            screenWidth,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureBullet(String text, double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.025),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: screenWidth * 0.012),
            height: screenWidth * 0.019,
            width: screenWidth * 0.019,
            decoration: const BoxDecoration(
              color: Color(0xFF767676),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: screenWidth * 0.02),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.beVietnamPro(
                fontSize: getFontRegularSize(context),
                letterSpacing: -0.5,
                color: const Color(0xFF767676),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
