import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationReceivingPage extends StatelessWidget {
  const NotificationReceivingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
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
            title: Text(
              'Notifications',
              style: GoogleFonts.beVietnamPro(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: false,
            elevation: 0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://cdn-icons-png.flaticon.com/512/4076/4076478.png', // Free empty state illustration
              height: size.height * 0.25,
              fit: BoxFit.contain,
              color: isDark ? Colors.white.withOpacity(0.8) : null,
              errorBuilder:
                  (context, error, stackTrace) => Icon(
                    Icons.notifications_off_outlined,
                    size: 100,
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
            ),
            const SizedBox(height: 32),
            Text(
              'No Notifications Yet',
              style: GoogleFonts.beVietnamPro(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Your notification center is quiet now. We\'ll alert you about prayer times, announcements, and updates when they arrive.',
                textAlign: TextAlign.center,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 15,
                  color: theme.colorScheme.onBackground.withOpacity(0.6),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
