import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrayerPlayer extends StatelessWidget {
  final String prayerName;

  const PrayerPlayer({super.key, required this.prayerName});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$prayerName Live Stream",
                style: GoogleFonts.beVietnamPro(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.035,
                ),
              ),
              Text(
                "Live",
                style: GoogleFonts.beVietnamPro(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.035,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "From 12:00 PM to 1:30 PM",
                style: GoogleFonts.beVietnamPro(
                  color: Colors.grey,
                  fontSize: screenWidth * 0.03,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous, size: 24),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.play_arrow,
                      size: 24,
                      color: Colors.green,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, size: 24),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
