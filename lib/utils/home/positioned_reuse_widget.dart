import 'package:flutter/material.dart';

class PositionedImageWidget extends StatelessWidget {
  final double top;
  final double right;
  final double offsetY;
  final String imagePath;
  final double height;
  final double? width;
  final bool ignorePointer; // Add this

  const PositionedImageWidget({
    Key? key,
    required this.top,
    required this.right,
    required this.offsetY,
    required this.imagePath,
    required this.height,
    this.width,
    this.ignorePointer = false, // Add this
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      child: IgnorePointer(
        ignoring: ignorePointer, // Use it here

        child: Transform.translate(
          offset: Offset(0, offsetY),
          child: Image.asset(imagePath, height: height, width: width),
        ),
      ),
    );
  }
}
