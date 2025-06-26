import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/font_mediaquery.dart';

class LiveNotification extends StatelessWidget {
  const LiveNotification({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
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
          child: Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
            ), // Add padding to push content down
            child: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leadingWidth: 70,
              leading: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.grey.withOpacity(0.5),
                      ), // Optional: specify color
                      borderRadius: BorderRadius.circular(5),
                    ),

                    width: 40,
                    height: 15, // This constrains the arrow container size
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 15, // Icon size
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              title: Padding(
                padding: const EdgeInsets.only(
                  top: 0.0,
                ), // Adjust title position if needed
                child: Text(
                  'Notifications',
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
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/notification_bell.png",
              height: 80,
              width: 80,
            ),
            SizedBox(height: 10),
            Text(
              "No notifications yet",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 10),

            Text(
              "We'll let you know when updates arrive!",
              style: GoogleFonts.inter(fontSize: 14, color: Color(0xFF334155)),
            ),
          ],
        ),
      ),
    );
  }
}
