import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


import '../../../utils/font_mediaquery.dart';
import '../../widgets/main_screen.dart';

class NotificationPreference extends StatefulWidget {
  const NotificationPreference({super.key});

  @override
  State<NotificationPreference> createState() => _NotificationPreferenceState();
}

class _NotificationPreferenceState extends State<NotificationPreference> {
  bool livePrayerAlert = false;
  bool subscriptionReminder = true;
  bool specialAnnouncements = true;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final textScaleFactor = mediaQuery.textScaleFactor;

    return Scaffold(
      backgroundColor: const Color(0xFF3B873E),
      body: Column(
        children: [
          // Top green section with logo and blur
          SizedBox(
            height: screenHeight * 0.22,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.08),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: screenHeight * 0.12,
                      width: screenWidth * 0.30,
                    ),
                  ),
                ),

                Positioned(
                  top: screenHeight * 0.001,
                  right: screenWidth * 0.013, // 5 for 375 width
                  child: Image.asset(
                    'assets/images/logo_blur.png',
                    height: screenHeight * 0.27, // 200 for 750 height
                    width: screenWidth * 0.50, // 200 for 375 width
                  ),
                ),
              ],
            ),
          ),

          // White container with switches
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.04,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notification Preference',
                      style: GoogleFonts.beVietnamPro(
                        fontSize:getFontBoldSize(context),
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.007), // 8 for 750 height
                    Text(
                      'Keep your heart connected — receive reminders for prayers, renewals, and special announcements.',
                      style: GoogleFonts.beVietnamPro(
                        fontSize:getFontRegularSize(context),
                        color: Colors.black87,
                          letterSpacing: -0.5

                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025), // 24 for 750 height
                    // Live Prayer Streaming Alerts
                    _buildSwitchTile(
                      context: context,
                      title: "Live Prayer Streaming Alerts",
                      subtitle:
                          "Get notified when live prayer audio starts from your masjid.",
                      value: livePrayerAlert,
                      onChanged: (val) => setState(() => livePrayerAlert = val),
                    ),

                    SizedBox(height: screenHeight * 0.015), // 16 for 750 height
                    // Subscription Renewal Reminders
                    _buildSwitchTile(
                      context: context,
                      title: "Subscription Renewal Reminders",
                      subtitle:
                          "Reminder when your subscription is about to expire",
                      value: subscriptionReminder,
                      onChanged:
                          (val) => setState(() => subscriptionReminder = val),
                    ),

                    SizedBox(height: screenHeight * 0.015), // 16 for 750 height
                    // Special Announcements from Masjid
                    _buildSwitchTile(
                      context: context,
                      title: "Special Announcements from Masjid",
                      subtitle:
                          "Receive announcements like special prayers, community updates, or events",
                      value: specialAnnouncements,
                      onChanged:
                          (val) => setState(() => specialAnnouncements = val),
                    ),

                    SizedBox(height: screenHeight * 0.015), // 16 for 750 height
                    // Home Button
                    SizedBox(
                      width: double.infinity,
                      height: screenHeight * 0.050, // 50 for 750 height
                      child: ElevatedButton(

                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFF3B873E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MainScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Home',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: getFontRegularSize(context),
                            letterSpacing: -0.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.010), // 12 for 750 height
                    // Skip Text
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MainScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Skip',
                          style: GoogleFonts.beVietnamPro(
                            color: Colors.black,
                            letterSpacing: -0.5,
                           fontWeight: FontWeight.w500,
                            fontSize:getFontRegularSize(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,

    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    final textScaleFactor = mediaQuery.textScaleFactor;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: mediaQuery.size.width * 0.025, // 16 for 375 width
        vertical: screenHeight * 0.016, // 14 for 750 height
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: getFontRegularSize(context),
                    letterSpacing: -0.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: screenHeight * 0.002), // 4 for 750 height
                Text(
                  subtitle,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: getFontRegularSize(context),
                    letterSpacing: -0.5,

                    color: Color(0xFF767676),
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Material(
              type: MaterialType.transparency, // Removes background
              child: SwitchTheme(
                data: SwitchThemeData(
                  thumbColor: MaterialStateProperty.resolveWith<Color>((
                    states,
                  ) {
                    return Colors.white; // Thumb color (always white)
                  }),
                  trackColor: MaterialStateProperty.resolveWith<Color>((
                    states,
                  ) {
                    if (states.contains(MaterialState.selected)) {
                      return const Color(
                        0xFF3B873E,
                      ); // Active track color (green)
                    }
                    return const Color(
                      0xFFF2F4F7,
                    ); // Inactive track color (gray)
                  }),
                  trackOutlineColor: WidgetStateProperty.resolveWith<Color>((
                    states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.transparent; // No border when active
                    }
                    return Colors.transparent; // Black border when inactive
                  }),
                  trackOutlineWidth: WidgetStateProperty.resolveWith<double>((
                    states,
                  ) {
                    return 0.0; // Border width (1px)
                  }),
                ),
                child: Switch(
                  value: value,
                  onChanged: onChanged,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
