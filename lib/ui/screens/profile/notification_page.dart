import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../providers/notification/notification_provider.dart';
import '../../../utils/custom_appbar.dart';
import '../../../utils/font_mediaquery.dart';

class NotificationPreferencePage extends StatefulWidget {
  const NotificationPreferencePage({super.key});

  @override
  State<NotificationPreferencePage> createState() =>
      _NotificationPreferencePageState();
}

class _NotificationPreferencePageState
    extends State<NotificationPreferencePage> {
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
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: CustomAppBar(
        title: 'Notification Preference',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Column(
        children: [
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
