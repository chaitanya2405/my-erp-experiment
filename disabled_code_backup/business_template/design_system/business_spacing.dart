import 'package:flutter/material.dart';

/// 📏 **Business Spacing System**
/// 
/// Consistent spacing and sizing system for:
/// - Layout consistency across all screens
/// - Responsive design scaling
/// - Professional visual rhythm
/// - Cross-platform optimization
class BusinessSpacing {
  // ============================================================================
  // 📐 SPACING SCALE
  // ============================================================================
  
  /// Extra small spacing - 4dp
  static const double xs = 4.0;
  
  /// Small spacing - 8dp
  static const double sm = 8.0;
  
  /// Medium spacing - 16dp (Base unit)
  static const double md = 16.0;
  
  /// Large spacing - 24dp
  static const double lg = 24.0;
  
  /// Extra large spacing - 32dp
  static const double xl = 32.0;
  
  /// Double extra large spacing - 48dp
  static const double xxl = 48.0;
  
  /// Triple extra large spacing - 64dp
  static const double xxxl = 64.0;
  
  // ============================================================================
  // 🎯 SEMANTIC SPACING
  // ============================================================================
  
  /// Padding inside components
  static const double paddingXS = xs;    // 4dp - Tight padding
  static const double paddingSM = sm;    // 8dp - Small padding
  static const double paddingMD = md;    // 16dp - Standard padding
  static const double paddingLG = lg;    // 24dp - Comfortable padding
  static const double paddingXL = xl;    // 32dp - Spacious padding
  
  /// Margins between components
  static const double marginXS = xs;     // 4dp - Tight margins
  static const double marginSM = sm;     // 8dp - Small margins
  static const double marginMD = md;     // 16dp - Standard margins
  static const double marginLG = lg;     // 24dp - Section margins
  static const double marginXL = xl;     // 32dp - Page margins
  
  /// Gap between elements in layouts
  static const double gapXS = xs;        // 4dp - Minimal gap
  static const double gapSM = sm;        // 8dp - Small gap
  static const double gapMD = md;        // 16dp - Standard gap
  static const double gapLG = lg;        // 24dp - Section gap
  static const double gapXL = xl;        // 32dp - Major gap
  
  // ============================================================================
  // 📱 COMPONENT SIZING
  // ============================================================================
  
  /// Button dimensions
  static const double buttonHeightSmall = 32.0;
  static const double buttonHeightMedium = 40.0;
  static const double buttonHeightLarge = 48.0;
  static const double buttonMinWidth = 64.0;
  
  /// Input field dimensions
  static const double inputHeight = 48.0;
  static const double inputHeightSmall = 40.0;
  static const double inputHeightLarge = 56.0;
  
  /// Icon sizes
  static const double iconXS = 12.0;
  static const double iconSM = 16.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 48.0;
  
  /// Avatar sizes
  static const double avatarSM = 24.0;
  static const double avatarMD = 40.0;
  static const double avatarLG = 56.0;
  static const double avatarXL = 80.0;
  
  /// Card dimensions
  static const double cardMinHeight = 120.0;
  static const double cardMaxWidth = 400.0;
  static const double kpiCardHeight = 140.0;
  static const double kpiCardMinWidth = 200.0;
  
  /// List item dimensions
  static const double listItemHeight = 56.0;
  static const double listItemHeightSmall = 48.0;
  static const double listItemHeightLarge = 72.0;
  
  /// App bar dimensions
  static const double appBarHeight = 56.0;
  static const double tabBarHeight = 48.0;
  
  /// Navigation dimensions
  static const double bottomNavHeight = 64.0;
  static const double sidebarWidth = 280.0;
  static const double sidebarCollapsedWidth = 64.0;
  static const double drawerWidth = 320.0;
  
  // ============================================================================
  // 🎨 BORDER RADIUS
  // ============================================================================
  
  /// Border radius scale
  static const double radiusXS = 2.0;
  static const double radiusSM = 4.0;
  static const double radiusMD = 8.0;
  static const double radiusLG = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 24.0;
  static const double radiusRound = 1000.0; // Fully rounded
  
  /// Component-specific radius
  static const double buttonRadius = radiusMD;
  static const double cardRadius = radiusLG;
  static const double inputRadius = radiusMD;
  static const double chipRadius = radiusRound;
  static const double modalRadius = radiusXL;
  static const double imageRadius = radiusMD;
  
  // ============================================================================
  // 🎭 ELEVATION & SHADOWS
  // ============================================================================
  
  /// Elevation levels for Material Design
  static const double elevationNone = 0.0;
  static const double elevationXS = 1.0;
  static const double elevationSM = 2.0;
  static const double elevationMD = 4.0;
  static const double elevationLG = 8.0;
  static const double elevationXL = 12.0;
  static const double elevationXXL = 16.0;
  
  /// Component elevations
  static const double cardElevation = elevationSM;
  static const double buttonElevation = elevationXS;
  static const double modalElevation = elevationXL;
  static const double appBarElevation = elevationSM;
  static const double fabElevation = elevationLG;
  
  // ============================================================================
  // 📱 RESPONSIVE BREAKPOINTS
  // ============================================================================
  
  /// Screen size breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;
  static const double largeDesktopBreakpoint = 1800.0;
  
  /// Container max widths
  static const double mobileMaxWidth = 480.0;
  static const double tabletMaxWidth = 768.0;
  static const double desktopMaxWidth = 1200.0;
  static const double contentMaxWidth = 1440.0;
  
  // ============================================================================
  // 🎯 UTILITY METHODS
  // ============================================================================
  
  /// Get responsive spacing based on screen size
  static double responsiveSpacing(BuildContext context, double baseSpacing) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < mobileBreakpoint) {
      return baseSpacing * 0.8; // Tighter spacing on mobile
    } else if (screenWidth > desktopBreakpoint) {
      return baseSpacing * 1.2; // More generous spacing on desktop
    }
    
    return baseSpacing;
  }
  
  /// Get responsive padding
  static EdgeInsets responsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < mobileBreakpoint) {
      return const EdgeInsets.all(paddingMD);
    } else if (screenWidth < tabletBreakpoint) {
      return const EdgeInsets.all(paddingLG);
    } else {
      return const EdgeInsets.all(paddingXL);
    }
  }
  
  /// Get screen-appropriate margin
  static EdgeInsets screenMargin(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < mobileBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: marginMD);
    } else if (screenWidth < desktopBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: marginXL);
    } else {
      return EdgeInsets.symmetric(
        horizontal: (screenWidth - contentMaxWidth) / 2,
      ).clamp(
        const EdgeInsets.symmetric(horizontal: marginXL),
        const EdgeInsets.symmetric(horizontal: 120),
      ) as EdgeInsets;
    }
  }
  
  /// Get device type based on screen size
  static DeviceType getDeviceType(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (screenWidth < desktopBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }
  
  /// Create symmetric padding
  static EdgeInsets symmetric({double? horizontal, double? vertical}) {
    return EdgeInsets.symmetric(
      horizontal: horizontal ?? 0,
      vertical: vertical ?? 0,
    );
  }
  
  /// Create all-sides padding
  static EdgeInsets all(double value) {
    return EdgeInsets.all(value);
  }
  
  /// Create custom padding
  static EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.only(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }
  
  /// Create responsive card padding
  static EdgeInsets cardPadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return all(paddingMD);
      case DeviceType.tablet:
        return all(paddingLG);
      case DeviceType.desktop:
        return all(paddingXL);
    }
  }
  
  /// Get appropriate gap for grid layouts
  static double gridGap(BuildContext context) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return gapMD;
      case DeviceType.tablet:
        return gapLG;
      case DeviceType.desktop:
        return gapXL;
    }
  }
  
  /// Get column count for responsive grids
  static int getColumnCount(BuildContext context, {int? mobile, int? tablet, int? desktop}) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile ?? 1;
      case DeviceType.tablet:
        return tablet ?? 2;
      case DeviceType.desktop:
        return desktop ?? 3;
    }
  }
}

/// Device type enumeration
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// 📐 **Spacing Constants**
/// 
/// Pre-defined spacing combinations for common use cases
class BusinessSpacingConstants {
  /// Page padding for different screen sizes
  static EdgeInsets pagePadding(BuildContext context) {
    return BusinessSpacing.responsivePadding(context);
  }
  
  /// Section spacing between major page sections
  static SizedBox sectionSpacing(BuildContext context) {
    return SizedBox(height: BusinessSpacing.responsiveSpacing(context, BusinessSpacing.xl));
  }
  
  /// Item spacing between related items
  static SizedBox itemSpacing(BuildContext context) {
    return SizedBox(height: BusinessSpacing.responsiveSpacing(context, BusinessSpacing.md));
  }
  
  /// Tight spacing for closely related elements
  static SizedBox tightSpacing() {
    return const SizedBox(height: BusinessSpacing.sm);
  }
  
  /// Wide spacing for separated sections
  static SizedBox wideSpacing(BuildContext context) {
    return SizedBox(height: BusinessSpacing.responsiveSpacing(context, BusinessSpacing.xxl));
  }
  
  /// Horizontal spacing variants
  static SizedBox horizontalSpacingSM() => const SizedBox(width: BusinessSpacing.sm);
  static SizedBox horizontalSpacingMD() => const SizedBox(width: BusinessSpacing.md);
  static SizedBox horizontalSpacingLG() => const SizedBox(width: BusinessSpacing.lg);
  
  /// Common padding combinations
  static EdgeInsets cardContentPadding = const EdgeInsets.all(BusinessSpacing.paddingLG);
  static EdgeInsets formFieldPadding = const EdgeInsets.symmetric(
    horizontal: BusinessSpacing.paddingMD,
    vertical: BusinessSpacing.paddingSM,
  );
  static EdgeInsets listItemPadding = const EdgeInsets.symmetric(
    horizontal: BusinessSpacing.paddingMD,
    vertical: BusinessSpacing.paddingSM,
  );
  
  /// Common margin combinations
  static EdgeInsets cardMargin = const EdgeInsets.all(BusinessSpacing.marginSM);
  static EdgeInsets sectionMargin = const EdgeInsets.symmetric(vertical: BusinessSpacing.marginLG);
  static EdgeInsets itemMargin = const EdgeInsets.symmetric(vertical: BusinessSpacing.marginSM);
}
