
import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Screen size breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Detect device type
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  // Get responsive padding
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0);
    }
  }

  // Get responsive width for form fields
  static double getFormWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopBreakpoint) {
      return width * 0.5; // 50% of screen width for desktop
    } else if (width >= tabletBreakpoint) {
      return width * 0.7; // 70% of screen width for large tablets
    } else if (width >= mobileBreakpoint) {
      return width * 0.85; // 85% of screen width for tablets
    } else {
      return width * 0.95; // 95% of screen width for mobile
    }
  }

  // Get responsive column count for form fields
  static int getColumnCount(BuildContext context) {
    if (isDesktop(context)) {
      return 2; // Two columns on desktop
    } else {
      return 1; // One column on mobile/tablet
    }
  }
}