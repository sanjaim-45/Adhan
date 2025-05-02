import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubscriptionCard extends StatelessWidget {
  final String title;
  final String price;
  final String duration;
  final String tag;
  final bool selected;
  final VoidCallback? onTap;

  const SubscriptionCard({
    super.key,
    required this.title,
    required this.price,
    required this.duration,
    required this.tag,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: selected ? 3 : 0,
        shape: RoundedRectangleBorder(
          side: selected
              ? const BorderSide(color: Color(0xFF2E7D32), width: 2)
              : BorderSide(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA1812E),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag,
                        style: GoogleFonts.beVietnamPro(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: GoogleFonts.beVietnamPro(
                        color: const Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(' $duration', style: GoogleFonts.beVietnamPro()),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? Colors.green : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}