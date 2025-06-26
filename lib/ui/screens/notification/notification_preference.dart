import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../providers/notification/notification_provider.dart';
import '../../../utils/font_mediaquery.dart';
import '../../widgets/main_screen.dart';

class NotificationPreference extends StatefulWidget {
  const NotificationPreference({super.key});

  @override
  State<NotificationPreference> createState() => _NotificationPreferenceState();
}

class _NotificationPreferenceState extends State<NotificationPreference> {
  bool subscriptionReminder = true;
  bool specialAnnouncements = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadInitialSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

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
                  right: screenWidth * 0.013,
                  child: Image.asset(
                    'assets/images/logo_blur.png',
                    height: screenHeight * 0.27,
                    width: screenWidth * 0.50,
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
                        fontSize: getFontBoldSize(context),
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.007),
                    Text(
                      'Keep your heart connected — receive reminders for prayers, renewals, and special announcements.',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: getFontRegularSize(context),
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025),

                    // Live Prayer Streaming Alerts (with API)
                    _buildSwitchTile(
                      context: context,
                      title: "Live Prayer Streaming Alerts",
                      subtitle:
                          "Get notified when live prayer audio starts from your masjid.",
                      value: notificationProvider.livePrayerAlert,
                      onChanged:
                          (val) => notificationProvider
                              .togglePrayerNotification(val),
                      isLoading: notificationProvider.isLoading,
                    ),

                    SizedBox(height: screenHeight * 0.015),
                    // Subscription Renewal Reminders (no API yet)
                    _buildSwitchTile(
                      context: context,
                      title: "Subscription Renewal Reminders",
                      subtitle:
                          "Reminder when your subscription is about to expire",
                      value: subscriptionReminder,
                      onChanged:
                          (val) => setState(() => subscriptionReminder = val),
                    ),

                    SizedBox(height: screenHeight * 0.015),
                    // Special Announcements from Masjid (no API yet)
                    _buildSwitchTile(
                      context: context,
                      title: "Special Announcements from Masjid",
                      subtitle:
                          "Receive announcements like special prayers, community updates, or events",
                      value: specialAnnouncements,
                      onChanged:
                          (val) => setState(() => specialAnnouncements = val),
                    ),

                    SizedBox(height: screenHeight * 0.015),
                    // Home Button
                    // Home Button
                    SizedBox(
                      width: double.infinity,
                      height: screenHeight * 0.050,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFF3B873E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool(
                            'hasSetNotificationPreferences',
                            true,
                          );
                          if (!mounted) return;
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const MainScreen(),
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

                    SizedBox(height: screenHeight * 0.010),
                    // Skip Text
                    Center(
                      child: TextButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool(
                            'hasSetNotificationPreferences',
                            true,
                          );
                          if (!mounted) return;
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const MainScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Skip',
                          style: GoogleFonts.beVietnamPro(
                            color: Colors.black,
                            letterSpacing: -0.5,
                            fontWeight: FontWeight.w500,
                            fontSize: getFontRegularSize(context),
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
    bool isLoading = false,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: mediaQuery.size.width * 0.025,
        vertical: screenHeight * 0.016,
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
                SizedBox(height: screenHeight * 0.002),
                Text(
                  subtitle,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: getFontRegularSize(context),
                    letterSpacing: -0.5,
                    color: const Color(0xFF767676),
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child:
                isLoading
                    ? const CircularProgressIndicator()
                    : Material(
                      type: MaterialType.transparency,
                      child: SwitchTheme(
                        data: SwitchThemeData(
                          thumbColor: MaterialStateProperty.resolveWith<Color>((
                            states,
                          ) {
                            return Colors.white;
                          }),
                          trackColor: MaterialStateProperty.resolveWith<Color>((
                            states,
                          ) {
                            if (states.contains(MaterialState.selected)) {
                              return const Color(0xFF3B873E);
                            }
                            return const Color(0xFFF2F4F7);
                          }),
                          trackOutlineColor:
                              MaterialStateProperty.resolveWith<Color>((
                                states,
                              ) {
                                return Colors.transparent;
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
