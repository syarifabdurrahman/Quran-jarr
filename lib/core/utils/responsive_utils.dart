import 'package:flutter/material.dart';

/// Responsive design utilities for adapting UI to different screen sizes
class ResponsiveUtils {
  ResponsiveUtils._();

  /// Get screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return ScreenSize.small;
    if (width < 900) return ScreenSize.medium;
    return ScreenSize.large;
  }

  /// Check if device is a small screen (phone)
  static bool isSmallScreen(BuildContext context) {
    return getScreenSize(context) == ScreenSize.small;
  }

  /// Check if device is a medium screen (tablet portrait)
  static bool isMediumScreen(BuildContext context) {
    return getScreenSize(context) == ScreenSize.medium;
  }

  /// Check if device is a large screen (tablet landscape/desktop)
  static bool isLargeScreen(BuildContext context) {
    return getScreenSize(context) == ScreenSize.large;
  }

  /// Get responsive value based on screen size
  /// Returns [small] for phones, [medium] for tablets, [large] for desktops
  static T getValue<T>(
    BuildContext context, {
    required T small,
    T? medium,
    T? large,
  }) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.small:
        return small;
      case ScreenSize.medium:
        return medium ?? small;
      case ScreenSize.large:
        return large ?? medium ?? small;
    }
  }

  /// Get responsive padding
  static EdgeInsets getPadding(BuildContext context) {
    return getValue(
      context,
      small: const EdgeInsets.all(16),
      medium: const EdgeInsets.all(24),
      large: const EdgeInsets.all(32),
    );
  }

  /// Get responsive spacing
  static double getSpacing(BuildContext context) {
    return getValue(
      context,
      small: 16.0,
      medium: 24.0,
      large: 32.0,
    );
  }

  /// Get responsive border radius
  static double getBorderRadius(BuildContext context) {
    return getValue(
      context,
      small: 12.0,
      medium: 16.0,
      large: 20.0,
    );
  }

  /// Get responsive dialog max width
  static double getDialogMaxWidth(BuildContext context) {
    return getValue(
      context,
      small: 400,
      medium: 500,
      large: 600,
    ).toDouble();
  }

  /// Get responsive dialog max height (percentage of screen)
  static double getDialogMaxHeight(BuildContext context) {
    return getValue(
      context,
      small: 0.75,
      medium: 0.65,
      large: 0.55,
    ).toDouble();
  }

  /// Scale a value based on screen width
  static double scaleWidth(BuildContext context, double value) {
    final width = MediaQuery.of(context).size.width;
    const baseWidth = 375.0; // iPhone SE base width
    return value * (width / baseWidth).clamp(0.8, 1.3);
  }

  /// Scale a value based on screen height
  static double scaleHeight(BuildContext context, double value) {
    final height = MediaQuery.of(context).size.height;
    const baseHeight = 667.0; // iPhone SE base height
    return value * (height / baseHeight).clamp(0.8, 1.3);
  }

  /// Get responsive icon size
  static double getIconSize(BuildContext context) {
    return getValue(
      context,
      small: 20,
      medium: 24,
      large: 28,
    ).toDouble();
  }

  /// Get responsive font scale
  static double getFontScale(BuildContext context) {
    return getValue(
      context,
      small: 1.0,
      medium: 1.1,
      large: 1.2,
    ).toDouble();
  }

  /// Get responsive container constraints
  static BoxConstraints getContainerConstraints(BuildContext context) {
    return getValue(
      context,
      small: const BoxConstraints(maxWidth: 400),
      medium: const BoxConstraints(maxWidth: 600),
      large: const BoxConstraints(maxWidth: 800),
    );
  }
}

/// Screen size categories
enum ScreenSize {
  small,  // < 600dp (phone)
  medium, // 600-900dp (tablet portrait)
  large,  // > 900dp (tablet landscape, desktop)
}

/// Extension on BuildContext for easy access to responsive utilities
extension ResponsiveContext on BuildContext {
  ScreenSize get screenSize => ResponsiveUtils.getScreenSize(this);
  bool get isSmallScreen => ResponsiveUtils.isSmallScreen(this);
  bool get isMediumScreen => ResponsiveUtils.isMediumScreen(this);
  bool get isLargeScreen => ResponsiveUtils.isLargeScreen(this);
}
