import 'package:flutter/material.dart';

/// 📝 **Business Typography System**
/// 
/// Professional typography hierarchy designed for:
/// - Excellent readability across all platforms
/// - Consistent visual hierarchy
/// - Cross-platform font optimization
/// - Accessibility compliance
class BusinessTypography {
  // ============================================================================
  // 🔤 FONT FAMILIES
  // ============================================================================
  
  /// Primary font family - Modern, professional, highly readable
  static const String primaryFont = 'Inter';
  
  /// Secondary font family - Fallback for system compatibility
  static const String secondaryFont = 'Roboto';
  
  /// Monospace font for code and data
  static const String monospaceFont = 'JetBrains Mono';
  
  /// System font fallbacks
  static const List<String> systemFontFallbacks = [
    'Inter',
    'Roboto',
    '-apple-system',
    'BlinkMacSystemFont',
    'Segoe UI',
    'Helvetica Neue',
    'Arial',
    'sans-serif',
  ];
  
  // ============================================================================
  // 📏 FONT SIZES
  // ============================================================================
  
  /// Display font sizes - Large headers and hero text
  static const double displayLarge = 57.0;   // Hero sections
  static const double displayMedium = 45.0;  // Page headers
  static const double displaySmall = 36.0;   // Section headers
  
  /// Headline font sizes - Important headers
  static const double headlineLarge = 32.0;  // Major headings
  static const double headlineMedium = 28.0; // Module headers
  static const double headlineSmall = 24.0;  // Card headers
  
  /// Title font sizes - Structured content
  static const double titleLarge = 22.0;     // List item titles
  static const double titleMedium = 16.0;    // Form labels
  static const double titleSmall = 14.0;     // Tab labels
  
  /// Body font sizes - Main content
  static const double bodyLarge = 16.0;      // Primary content
  static const double bodyMedium = 14.0;     // Secondary content
  static const double bodySmall = 12.0;      // Supporting text
  
  /// Label font sizes - UI elements
  static const double labelLarge = 14.0;     // Button text
  static const double labelMedium = 12.0;    // Input labels
  static const double labelSmall = 11.0;     // Captions
  
  // ============================================================================
  // 📐 FONT WEIGHTS
  // ============================================================================
  
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;
  
  // ============================================================================
  // 📏 LINE HEIGHTS
  // ============================================================================
  
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightRelaxed = 1.6;
  static const double lineHeightLoose = 1.8;
  
  // ============================================================================
  // 🔤 LETTER SPACING
  // ============================================================================
  
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.5;
  static const double letterSpacingExtraWide = 1.0;
  
  // ============================================================================
  // 🎨 DISPLAY STYLES
  // ============================================================================
  
  /// Display Large - Hero sections, splash screens
  static TextStyle displayLargeStyle(BuildContext context) {
    return TextStyle(
      fontSize: displayLarge,
      fontWeight: bold,
      fontFamily: primaryFont,
      height: lineHeightTight,
      letterSpacing: letterSpacingTight,
      color: _getTextColor(context, TextColorType.primary),
    );
  }
  
  /// Display Medium - Page headers, main titles
  static TextStyle displayMediumStyle(BuildContext context) {
    return TextStyle(
      fontSize: displayMedium,
      fontWeight: bold,
      fontFamily: primaryFont,
      height: lineHeightTight,
      letterSpacing: letterSpacingTight,
      color: _getTextColor(context, TextColorType.primary),
    );
  }
  
  /// Display Small - Section headers
  static TextStyle displaySmallStyle(BuildContext context) {
    return TextStyle(
      fontSize: displaySmall,
      fontWeight: semiBold,
      fontFamily: primaryFont,
      height: lineHeightNormal,
      letterSpacing: letterSpacingNormal,
      color: _getTextColor(context, TextColorType.primary),
    );
  }
  
  // ============================================================================
  // 📰 HEADLINE STYLES
  // ============================================================================
  
  /// Headline Large - Major headings
  static TextStyle headlineLargeStyle(BuildContext context) {
    return TextStyle(
      fontSize: headlineLarge,
      fontWeight: semiBold,
      fontFamily: primaryFont,
      height: lineHeightNormal,
      letterSpacing: letterSpacingNormal,
      color: _getTextColor(context, TextColorType.primary),
    );
  }
  
  /// Headline Medium - Module headers
  static TextStyle headlineMediumStyle(BuildContext context) {
    return TextStyle(
      fontSize: headlineMedium,
      fontWeight: semiBold,
      fontFamily: primaryFont,
      height: lineHeightNormal,
      letterSpacing: letterSpacingNormal,
      color: _getTextColor(context, TextColorType.primary),
    );
  }
  
  /// Headline Small - Card headers
  static TextStyle headlineSmallStyle(BuildContext context) {
    return TextStyle(
      fontSize: headlineSmall,
      fontWeight: medium,
      fontFamily: primaryFont,
      height: lineHeightNormal,
      letterSpacing: letterSpacingNormal,
      color: _getTextColor(context, TextColorType.primary),
    );
  }
  
  // ============================================================================
  // 🏷️ TITLE STYLES
  // ============================================================================
  
  /// Title Large - List item titles, form sections
  static TextStyle titleLargeStyle(BuildContext context) {
    return TextStyle(
      fontSize: titleLarge,
      fontWeight: medium,
      fontFamily: primaryFont,
      height: lineHeightNormal,
      letterSpacing: letterSpacingNormal,
      color: _getTextColor(context, TextColorType.primary),
    );
  }
  
  /// Title Medium - Form labels, table headers
  static TextStyle titleMediumStyle(BuildContext context) {
    return TextStyle(
      fontSize: titleMedium,
      fontWeight: medium,
      fontFamily: primaryFont,
      height: lineHeightNormal,
      letterSpacing: letterSpacingNormal,
      color: _getTextColor(context, TextColorType.primary),
    );
  }
  
  /// Title Small - Tab labels, small headers
  static TextStyle titleSmallStyle(BuildContext context) {
    return TextStyle(
      fontSize: titleSmall,
      fontWeight: medium,
      fontFamily: primaryFont,
      height: lineHeightNormal,
      letterSpacing: letterSpacingWide,
      color: _getTextColor(context, TextColorType.secondary),
    );
  }
  
  // ============================================================================
  // 📄 BODY STYLES
  // ============================================================================
  
  /// Body Large - Primary content, important descriptions
  static TextStyle bodyLargeStyle(BuildContext context) {
    return TextStyle(
      fontSize: bodyLarge,
      fontWeight: regular,
      fontFamily: primaryFont,
      height: lineHeightRelaxed,
      letterSpacing: letterSpacingNormal,
      color: _getTextColor(context, TextColorType.primary),
    );
  }
  
  /// Body Medium - Secondary content, standard text
  static TextStyle bodyMediumStyle(BuildContext context) {
    return TextStyle(
      fontSize: bodyMedium,
      fontWeight: regular,
      fontFamily: primaryFont,
      height: lineHeightRelaxed,
      letterSpacing: letterSpacingNormal,
      color: _getTextColor(context, TextColorType.secondary),
    );
  }
  
  /// Body Small - Supporting text, captions
  static TextStyle bodySmallStyle(BuildContext context) {
    return TextStyle(
      fontSize: bodySmall,
      fontWeight: regular,
      fontFamily: primaryFont,
      height: lineHeightNormal,
      letterSpacing: letterSpacingNormal,
      color: _getTextColor(context, TextColorType.tertiary),
    );
  }
  
  // ============================================================================
  // 🏷️ LABEL STYLES
  // ============================================================================
  
  /// Label Large - Button text, important labels
  static TextStyle labelLargeStyle(BuildContext context) {
    return TextStyle(
      fontSize: labelLarge,
      fontWeight: medium,
      fontFamily: primaryFont,
      height: lineHeightNormal,
      letterSpacing: letterSpacingWide,
      color: _getTextColor(context, TextColorType.primary),
    );
  }
  
  /// Label Medium - Input labels, form fields
  static TextStyle labelMediumStyle(BuildContext context) {
    return TextStyle(
      fontSize: labelMedium,
      fontWeight: medium,
      fontFamily: primaryFont,
      height: lineHeightNormal,
      letterSpacing: letterSpacingWide,
      color: _getTextColor(context, TextColorType.secondary),
    );
  }
  
  /// Label Small - Captions, metadata
  static TextStyle labelSmallStyle(BuildContext context) {
    return TextStyle(
      fontSize: labelSmall,
      fontWeight: medium,
      fontFamily: primaryFont,
      height: lineHeightNormal,
      letterSpacing: letterSpacingExtraWide,
      color: _getTextColor(context, TextColorType.tertiary),
    );
  }
  
  // ============================================================================
  // 💼 SPECIALIZED STYLES
  // ============================================================================
  
  /// Monospace style for code, data, IDs
  static TextStyle monospaceStyle(BuildContext context, {double? fontSize}) {
    return TextStyle(
      fontSize: fontSize ?? bodyMedium,
      fontWeight: regular,
      fontFamily: monospaceFont,
      height: lineHeightNormal,
      letterSpacing: letterSpacingNormal,
      color: _getTextColor(context, TextColorType.primary),
    );
  }
  
  /// Currency style for financial data
  static TextStyle currencyStyle(BuildContext context, {double? fontSize, Color? color}) {
    return TextStyle(
      fontSize: fontSize ?? bodyLarge,
      fontWeight: semiBold,
      fontFamily: primaryFont,
      height: lineHeightNormal,
      letterSpacing: letterSpacingNormal,
      color: color ?? _getTextColor(context, TextColorType.primary),
    );
  }
  
  /// Error text style
  static TextStyle errorStyle(BuildContext context) {
    return TextStyle(
      fontSize: bodySmall,
      fontWeight: medium,
      fontFamily: primaryFont,
      height: lineHeightNormal,
      letterSpacing: letterSpacingNormal,
      color: Theme.of(context).colorScheme.error,
    );
  }
  
  /// Success text style
  static TextStyle successStyle(BuildContext context) {
    return TextStyle(
      fontSize: bodySmall,
      fontWeight: medium,
      fontFamily: primaryFont,
      height: lineHeightNormal,
      letterSpacing: letterSpacingNormal,
      color: Colors.green[600],
    );
  }
  
  /// Link text style
  static TextStyle linkStyle(BuildContext context) {
    return TextStyle(
      fontSize: bodyMedium,
      fontWeight: medium,
      fontFamily: primaryFont,
      height: lineHeightNormal,
      letterSpacing: letterSpacingNormal,
      color: Theme.of(context).colorScheme.primary,
      decoration: TextDecoration.underline,
    );
  }
  
  // ============================================================================
  // 🎯 UTILITY METHODS
  // ============================================================================
  
  /// Get text color based on theme and type
  static Color _getTextColor(BuildContext context, TextColorType type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    switch (type) {
      case TextColorType.primary:
        return isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
      case TextColorType.secondary:
        return isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);
      case TextColorType.tertiary:
        return isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
      case TextColorType.disabled:
        return isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
      case TextColorType.onPrimary:
        return const Color(0xFFFFFFFF);
    }
  }
  
  /// Create custom text style with business defaults
  static TextStyle customStyle(
    BuildContext context, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    String? fontFamily,
  }) {
    return TextStyle(
      fontSize: fontSize ?? bodyMedium,
      fontWeight: fontWeight ?? regular,
      fontFamily: fontFamily ?? primaryFont,
      height: height ?? lineHeightNormal,
      letterSpacing: letterSpacing ?? letterSpacingNormal,
      color: color ?? _getTextColor(context, TextColorType.primary),
    );
  }
  
  /// Apply responsive font scaling
  static double responsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Scale factor based on screen width
    double scaleFactor = 1.0;
    
    if (screenWidth < 600) {
      // Mobile: slightly smaller text
      scaleFactor = 0.95;
    } else if (screenWidth > 1200) {
      // Desktop: slightly larger text
      scaleFactor = 1.05;
    }
    
    return baseSize * scaleFactor;
  }
}

/// Text color types for theme-aware color selection
enum TextColorType {
  primary,
  secondary,
  tertiary,
  disabled,
  onPrimary,
}

/// 📝 **Typography Constants**
/// 
/// Pre-defined text style combinations for common use cases
class BusinessTypographyConstants {
  /// App bar title style
  static TextStyle appBarTitle(BuildContext context) =>
      BusinessTypography.titleLargeStyle(context);
  
  /// Card title style
  static TextStyle cardTitle(BuildContext context) =>
      BusinessTypography.titleMediumStyle(context);
  
  /// Table header style
  static TextStyle tableHeader(BuildContext context) =>
      BusinessTypography.titleSmallStyle(context);
  
  /// Table cell style
  static TextStyle tableCell(BuildContext context) =>
      BusinessTypography.bodyMediumStyle(context);
  
  /// Button text style
  static TextStyle buttonText(BuildContext context) =>
      BusinessTypography.labelLargeStyle(context);
  
  /// Form input style
  static TextStyle formInput(BuildContext context) =>
      BusinessTypography.bodyMediumStyle(context);
  
  /// Form label style
  static TextStyle formLabel(BuildContext context) =>
      BusinessTypography.labelMediumStyle(context);
  
  /// KPI value style
  static TextStyle kpiValue(BuildContext context) =>
      BusinessTypography.displaySmallStyle(context);
  
  /// KPI label style
  static TextStyle kpiLabel(BuildContext context) =>
      BusinessTypography.labelMediumStyle(context);
  
  /// Status badge style
  static TextStyle statusBadge(BuildContext context) =>
      BusinessTypography.labelSmallStyle(context);
}
