import 'package:flutter/widgets.dart';

bool isTablet(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide >= 600;

double getWidth(
  BuildContext context,
  double value, {
  double? denominator,
}) {
  final width = MediaQuery.of(context).size.width;
  final defaultDenominator = isTablet(context) ? 600 : 375;
  return (value / (denominator ?? defaultDenominator)) * width;
}

double getHeight(
  BuildContext context,
  double value, {
  double? denominator,
}) {
  final height = MediaQuery.of(context).size.height;
  final defaultDenominator = isTablet(context) ? 800 : 812;
  return (value / (denominator ?? defaultDenominator)) * height;
}

double getResponsiveFontSize(BuildContext context, double baseSize) {
  final width = MediaQuery.of(context).size.width;
  return baseSize * (width / (isTablet(context) ? 600 : 375));
}
