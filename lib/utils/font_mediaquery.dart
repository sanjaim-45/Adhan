import 'package:flutter/cupertino.dart';

const double fontSizeFactor = 0.037;

const double fontSize55Factor = 0.048;
const double fontSize35Factor = 0.032;
//
// const double fontSizeFactor = 0.045;
//
// const double fontSize55Factor = 0.055;
// const double fontSize35Factor = 0.035;

const double fontSizeBold = 0.06;
double getFontRegularSize(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  return screenWidth * fontSizeFactor;
}


double getFontBoldSize(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  return screenWidth * fontSizeBold;
}

double getFontRegular55Size(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  return screenWidth * fontSize55Factor;
}

double getFontRegular35Size(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  return screenWidth * fontSize35Factor;
}

double getDynamicFontSize(BuildContext context, double factor) {
  final screenWidth = MediaQuery.of(context).size.width;
  return screenWidth * factor;
}
