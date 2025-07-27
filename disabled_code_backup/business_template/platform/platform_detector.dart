import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

/// 🖥️ **Platform Detection System**
/// 
/// Comprehensive platform detection and adaptation utilities for:
/// - Device type identification (mobile, tablet, desktop)
/// - Platform-specific feature detection
/// - Input method optimization
/// - Screen size categorization
/// - Performance optimization hints
class PlatformDetector {
  
  // ============================================================================
  // 🎯 PLATFORM IDENTIFICATION
  // ============================================================================
  
  /// Check if running on mobile platforms
  static bool get isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }
  
  /// Check if running on desktop platforms
  static bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }
  
  /// Check if running on web
  static bool get isWeb => kIsWeb;
  
  /// Check specific platforms
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isLinux => !kIsWeb && Platform.isLinux;
  
  // ============================================================================
  // 📱 DEVICE CATEGORIZATION
  // ============================================================================
  
  /// Get device category based on screen size and platform
  static DeviceCategory getDeviceCategory(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final diagonal = _calculateDiagonal(width, height);
    
    // Web-specific categorization
    if (isWeb) {
      if (width < 600) return DeviceCategory.mobile;
      if (width < 900) return DeviceCategory.tablet;
      return DeviceCategory.desktop;
    }
    
    // Mobile platforms
    if (isMobile) {
      // Phone vs tablet detection for mobile platforms
      if (diagonal < 7.0) return DeviceCategory.mobile;
      return DeviceCategory.tablet;
    }
    
    // Desktop platforms
    return DeviceCategory.desktop;
  }
  
  /// Get screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 360) return ScreenSize.extraSmall;
    if (width < 600) return ScreenSize.small;
    if (width < 900) return ScreenSize.medium;
    if (width < 1200) return ScreenSize.large;
    if (width < 1800) return ScreenSize.extraLarge;
    return ScreenSize.ultraWide;
  }
  
  /// Calculate screen diagonal in inches (approximate)
  static double _calculateDiagonal(double width, double height) {
    final diagonal = (width * width + height * height) / 160.0; // Assuming 160 DPI
    return diagonal;
  }
  
  // ============================================================================
  // 🎮 INPUT METHOD DETECTION
  // ============================================================================
  
  /// Check if device primarily uses touch input
  static bool hasTouchInput(BuildContext context) {
    if (isWeb) {
      // Web: detect touch capability
      return MediaQuery.of(context).size.width < 900;
    }
    return isMobile;
  }
  
  /// Check if device has mouse/trackpad input
  static bool hasPointerInput(BuildContext context) {
    return isDesktop || isWeb;
  }
  
  /// Check if device has keyboard input
  static bool hasKeyboardInput(BuildContext context) {
    return isDesktop || isWeb || getDeviceCategory(context) == DeviceCategory.tablet;
  }
  
  /// Check if device supports hover interactions
  static bool supportsHover(BuildContext context) {
    return hasPointerInput(context);
  }
  
  // ============================================================================
  // 🎨 UI ADAPTATION HELPERS
  // ============================================================================
  
  /// Get appropriate navigation type for current platform
  static NavigationType getNavigationType(BuildContext context) {
    final category = getDeviceCategory(context);
    final width = MediaQuery.of(context).size.width;
    
    switch (category) {
      case DeviceCategory.mobile:
        return NavigationType.bottomNavigation;
      case DeviceCategory.tablet:
        return width > 700 ? NavigationType.navigationRail : NavigationType.drawer;
      case DeviceCategory.desktop:
        return NavigationType.sidebar;
    }
  }
  
  /// Get appropriate list item size
  static double getListItemHeight(BuildContext context) {
    final category = getDeviceCategory(context);
    
    switch (category) {
      case DeviceCategory.mobile:
        return 56.0;
      case DeviceCategory.tablet:
        return 64.0;
      case DeviceCategory.desktop:
        return 48.0;
    }
  }
  
  /// Get appropriate button size
  static ButtonSize getButtonSize(BuildContext context) {
    final category = getDeviceCategory(context);
    
    switch (category) {
      case DeviceCategory.mobile:
        return ButtonSize.large;
      case DeviceCategory.tablet:
        return ButtonSize.medium;
      case DeviceCategory.desktop:
        return ButtonSize.medium;
    }
  }
  
  /// Get appropriate spacing multiplier
  static double getSpacingMultiplier(BuildContext context) {
    final category = getDeviceCategory(context);
    
    switch (category) {
      case DeviceCategory.mobile:
        return 1.0;
      case DeviceCategory.tablet:
        return 1.2;
      case DeviceCategory.desktop:
        return 1.1;
    }
  }
  
  // ============================================================================
  // ⚡ PERFORMANCE HINTS
  // ============================================================================
  
  /// Check if device might have performance constraints
  static bool isLowEndDevice() {
    // This is a simplified check - in real apps you'd want more sophisticated detection
    return isMobile && !isIOS; // Assume Android might have more varied performance
  }
  
  /// Get recommended animation duration based on platform
  static Duration getAnimationDuration(AnimationSpeed speed) {
    final multiplier = isLowEndDevice() ? 0.8 : 1.0;
    
    switch (speed) {
      case AnimationSpeed.fast:
        return Duration(milliseconds: (100 * multiplier).round());
      case AnimationSpeed.normal:
        return Duration(milliseconds: (200 * multiplier).round());
      case AnimationSpeed.slow:
        return Duration(milliseconds: (300 * multiplier).round());
    }
  }
  
  /// Check if complex animations should be enabled
  static bool shouldUseComplexAnimations() {
    return !isLowEndDevice();
  }
  
  // ============================================================================
  // 📊 PLATFORM INFO HELPER
  // ============================================================================
  
  /// Get comprehensive platform information
  static PlatformInfo getPlatformInfo(BuildContext context) {
    return PlatformInfo(
      category: getDeviceCategory(context),
      screenSize: getScreenSize(context),
      navigationType: getNavigationType(context),
      hasTouchInput: hasTouchInput(context),
      hasPointerInput: hasPointerInput(context),
      hasKeyboardInput: hasKeyboardInput(context),
      supportsHover: supportsHover(context),
      isLowEndDevice: isLowEndDevice(),
      spacingMultiplier: getSpacingMultiplier(context),
      platform: _getCurrentPlatform(),
    );
  }
  
  static TargetPlatform _getCurrentPlatform() {
    if (kIsWeb) return TargetPlatform.web;
    if (Platform.isAndroid) return TargetPlatform.android;
    if (Platform.isIOS) return TargetPlatform.iOS;
    if (Platform.isMacOS) return TargetPlatform.macOS;
    if (Platform.isWindows) return TargetPlatform.windows;
    if (Platform.isLinux) return TargetPlatform.linux;
    return TargetPlatform.android; // fallback
  }
}

// ============================================================================
// 📋 ENUMS AND DATA CLASSES
// ============================================================================

/// Device category enumeration
enum DeviceCategory {
  mobile,
  tablet,
  desktop,
}

/// Screen size categorization
enum ScreenSize {
  extraSmall,  // < 360px
  small,       // 360-600px
  medium,      // 600-900px
  large,       // 900-1200px
  extraLarge,  // 1200-1800px
  ultraWide,   // > 1800px
}

/// Navigation type recommendations
enum NavigationType {
  bottomNavigation,
  navigationRail,
  drawer,
  sidebar,
}

/// Button size recommendations
enum ButtonSize {
  small,
  medium,
  large,
}

/// Animation speed categories
enum AnimationSpeed {
  fast,
  normal,
  slow,
}

/// Comprehensive platform information
class PlatformInfo {
  final DeviceCategory category;
  final ScreenSize screenSize;
  final NavigationType navigationType;
  final bool hasTouchInput;
  final bool hasPointerInput;
  final bool hasKeyboardInput;
  final bool supportsHover;
  final bool isLowEndDevice;
  final double spacingMultiplier;
  final TargetPlatform platform;
  
  const PlatformInfo({
    required this.category,
    required this.screenSize,
    required this.navigationType,
    required this.hasTouchInput,
    required this.hasPointerInput,
    required this.hasKeyboardInput,
    required this.supportsHover,
    required this.isLowEndDevice,
    required this.spacingMultiplier,
    required this.platform,
  });
  
  /// Check if current device is mobile
  bool get isMobile => category == DeviceCategory.mobile;
  
  /// Check if current device is tablet
  bool get isTablet => category == DeviceCategory.tablet;
  
  /// Check if current device is desktop
  bool get isDesktop => category == DeviceCategory.desktop;
  
  /// Check if screen is small
  bool get isSmallScreen => screenSize == ScreenSize.extraSmall || 
                           screenSize == ScreenSize.small;
  
  /// Check if screen is large
  bool get isLargeScreen => screenSize == ScreenSize.large || 
                           screenSize == ScreenSize.extraLarge || 
                           screenSize == ScreenSize.ultraWide;
  
  /// Get platform-appropriate icon size
  double get iconSize {
    switch (category) {
      case DeviceCategory.mobile:
        return 24.0;
      case DeviceCategory.tablet:
        return 28.0;
      case DeviceCategory.desktop:
        return 20.0;
    }
  }
  
  /// Get platform-appropriate font scale
  double get fontScale {
    switch (category) {
      case DeviceCategory.mobile:
        return 1.0;
      case DeviceCategory.tablet:
        return 1.1;
      case DeviceCategory.desktop:
        return 0.95;
    }
  }
  
  @override
  String toString() {
    return 'PlatformInfo('
        'category: $category, '
        'screenSize: $screenSize, '
        'navigationType: $navigationType, '
        'platform: $platform'
        ')';
  }
}

// ============================================================================
// 🎨 PLATFORM-AWARE WIDGETS
// ============================================================================

/// Widget that adapts based on platform
class PlatformAdaptiveWidget extends StatelessWidget {
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? fallback;
  
  const PlatformAdaptiveWidget({
    Key? key,
    this.mobile,
    this.tablet,
    this.desktop,
    this.fallback,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final category = PlatformDetector.getDeviceCategory(context);
    
    switch (category) {
      case DeviceCategory.mobile:
        return mobile ?? fallback ?? const SizedBox.shrink();
      case DeviceCategory.tablet:
        return tablet ?? mobile ?? fallback ?? const SizedBox.shrink();
      case DeviceCategory.desktop:
        return desktop ?? tablet ?? fallback ?? const SizedBox.shrink();
    }
  }
}

/// Responsive builder that provides platform information
class PlatformResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, PlatformInfo platformInfo) builder;
  
  const PlatformResponsiveBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final platformInfo = PlatformDetector.getPlatformInfo(context);
    return builder(context, platformInfo);
  }
}
