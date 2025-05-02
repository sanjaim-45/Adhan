import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrayerCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String arabic;
  final String time;
  final String status; // Completed, Live, Upcoming
  final Color statusColor;
  final IconData? trailingIcon; // optional

  const PrayerCard({
    required this.imagePath,
    required this.title,
    required this.arabic,
    required this.time,
    required this.status,
    required this.statusColor,
    this.trailingIcon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4,horizontal: 12),
      padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(imagePath,width: 35,height: 35,),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title $arabic',
                  style:  GoogleFonts.beVietnamPro(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      time,
                      style:  GoogleFonts.beVietnamPro(color: Colors.grey[700],fontSize: 12),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: [
                          if (status == "Live") ...[
                            const Icon(Icons.podcasts, size: 14, color: Colors.red),
                            const SizedBox(width: 4),
                          ] else if (status == "Completed") ...[
                            const Icon(Icons.check_circle, size: 14, color: Colors.green),
                            const SizedBox(width: 4),
                          ] else ...[
                            const Icon(Icons.access_time_filled, size: 14, color: Colors.brown),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            status,
                            style:  GoogleFonts.beVietnamPro(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (trailingIcon != null)
            Icon(trailingIcon, color: Colors.green, size: 26),
        ],
      ),
    );
  }
}
