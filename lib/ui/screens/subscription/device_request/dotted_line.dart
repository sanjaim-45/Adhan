import 'package:flutter/material.dart';

class DottedLine extends StatelessWidget {
  final bool isActive;

  const DottedLine({required this.isActive});

  @override
  Widget build(BuildContext context) {
    const lineHeight = 1.0;
    return Expanded(
      child: Padding(
        // Adjusted padding to align with the center of the CircleAvatar in _StepperItem
        padding: const EdgeInsets.only(
          top: 35.0,
        ), // Approximate vertical center of the dot/tick
        child: SizedBox(
          height: lineHeight, // Height of the line container
          child: CustomPaint(
            // The line itself
            painter: DottedLinePainter(isActive: isActive),
          ),
        ),
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  final bool isActive;
  DottedLinePainter({required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = isActive ? const Color(0xFF2E7D32) : Colors.grey.shade300
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;

    const dashWidth = 4;
    const dashSpace = 4;
    double startX = 0;

    while (startX < size.width) {
      // Draw line in the vertical center of the available space (size.height)
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
