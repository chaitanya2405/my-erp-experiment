import 'package:flutter/material.dart';

/// 🎨 **Business Color System**
/// 
/// Professional, enterprise-grade color palette designed for:
/// - Cross-platform consistency
/// - Accessibility compliance (WCAG 2.1)
/// - Modern professional aesthetics
/// - Light and dark theme support
class BusinessColors {
  // ============================================================================
  // 🏢 PRIMARY BRAND COLORS
  // ============================================================================
  
  /// Primary brand blue - Executive, trustworthy, professional
  static const Color primaryBlue = Color(0xFF1E40AF);
  static const Color primaryBlueLight = Color(0xFF3B82F6);
  static const Color primaryBlueDark = Color(0xFF1E3A8A);
  
  /// Secondary brand colors
  static const Color secondaryIndigo = Color(0xFF4F46E5);
  static const Color secondaryPurple = Color(0xFF7C3AED);
  static const Color secondaryTeal = Color(0xFF0D9488);
  
  // ============================================================================
  // 🎯 SEMANTIC COLORS
  // ============================================================================
  
  /// Success colors - Confirmations, positive states
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);
  static const Color successSurface = Color(0xFFECFDF5);
  
  /// Warning colors - Cautions, pending states
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);
  static const Color warningSurface = Color(0xFFFEF3C7);
  
  /// Error colors - Errors, destructive actions
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);
  static const Color errorSurface = Color(0xFFFEE2E2);
  
  /// Info colors - Information, neutral states
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);
  static const Color infoSurface = Color(0xFFEFF6FF);
  
  // ============================================================================
  // 🌫️ NEUTRAL PALETTE
  // ============================================================================
  
  /// Gray scale - Professional neutral tones
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);
  
  /// Slate scale - Cool professional tones
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  
  // ============================================================================
  // 🌟 ACCENT COLORS
  // ============================================================================
  
  /// Accent colors for highlights and special elements
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentEmerald = Color(0xFF10B981);
  static const Color accentYellow = Color(0xFFF59E0B);
  static const Color accentRose = Color(0xFFF43F5E);
  static const Color accentViolet = Color(0xFF8B5CF6);
  static const Color accentOrange = Color(0xFFF97316);
  
  // ============================================================================
  // 🏗️ SURFACE COLORS
  // ============================================================================
  
  /// Light theme surfaces
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF8FAFC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightDivider = Color(0xFFE5E7EB);
  
  /// Dark theme surfaces
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF334155);
  static const Color darkBorder = Color(0xFF475569);
  static const Color darkDivider = Color(0xFF374151);
  
  // ============================================================================
  // 📝 TEXT COLORS
  // ============================================================================
  
  /// Light theme text colors
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextTertiary = Color(0xFF64748B);
  static const Color lightTextDisabled = Color(0xFF94A3B8);
  static const Color lightTextOnPrimary = Color(0xFFFFFFFF);
  
  /// Dark theme text colors
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextTertiary = Color(0xFF94A3B8);
  static const Color darkTextDisabled = Color(0xFF64748B);
  static const Color darkTextOnPrimary = Color(0xFFFFFFFF);
  
  // ============================================================================
  // 🎨 GRADIENT DEFINITIONS
  // ============================================================================
  
  /// Primary gradients for premium elements
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryBlueLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [success, successLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient warningGradient = LinearGradient(
    colors: [warning, warningLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient errorGradient = LinearGradient(
    colors: [error, errorLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Glass morphism gradients
  static const LinearGradient glassMorphismLight = LinearGradient(
    colors: [
      Color(0x80FFFFFF),
      Color(0x40FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient glassMorphismDark = LinearGradient(
    colors: [
      Color(0x40FFFFFF),
      Color(0x20FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // ============================================================================
  // 🎯 THEME-SPECIFIC COLOR GETTERS
  // ============================================================================
  
  /// Get theme-appropriate background color
  static Color backgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightBackground
        : darkBackground;
  }
  
  /// Get theme-appropriate surface color
  static Color surfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightSurface
        : darkSurface;
  }
  
  /// Get theme-appropriate card color
  static Color cardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightCard
        : darkCard;
  }
  
  /// Get theme-appropriate primary text color
  static Color textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightTextPrimary
        : darkTextPrimary;
  }
  
  /// Get theme-appropriate secondary text color
  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightTextSecondary
        : darkTextSecondary;
  }
  
  /// Get theme-appropriate tertiary text color
  static Color textTertiary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightTextTertiary
        : darkTextTertiary;
  }
  
  /// Get theme-appropriate border color
  static Color borderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightBorder
        : darkBorder;
  }
  
  /// Get theme-appropriate divider color
  static Color dividerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightDivider
        : darkDivider;
  }
  
  // ============================================================================
  // 🔧 UTILITY METHODS
  // ============================================================================
  
  /// Create color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  /// Create hover color (slightly darker)
  static Color hoverColor(Color color) {
    return Color.fromRGBO(
      (color.red * 0.9).round(),
      (color.green * 0.9).round(),
      (color.blue * 0.9).round(),
      color.opacity,
    );
  }
  
  /// Create pressed color (darker)
  static Color pressedColor(Color color) {
    return Color.fromRGBO(
      (color.red * 0.8).round(),
      (color.green * 0.8).round(),
      (color.blue * 0.8).round(),
      color.opacity,
    );
  }
  
  /// Get semantic color by status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'active':
      case 'approved':
        return success;
      case 'warning':
      case 'pending':
      case 'in_progress':
        return warning;
      case 'error':
      case 'failed':
      case 'rejected':
      case 'cancelled':
        return error;
      case 'info':
      case 'draft':
      case 'new':
        return info;
      default:
        return gray500;
    }
  }
  
  /// Get semantic surface color by status
  static Color getStatusSurface(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'active':
      case 'approved':
        return successSurface;
      case 'warning':
      case 'pending':
      case 'in_progress':
        return warningSurface;
      case 'error':
      case 'failed':
      case 'rejected':
      case 'cancelled':
        return errorSurface;
      case 'info':
      case 'draft':
      case 'new':
        return infoSurface;
      default:
        return gray100;
    }
  }
}

/// 🎨 **Business Color Constants**
/// 
/// Easy access to commonly used color combinations
class BusinessColorConstants {
  /// KPI card colors
  static const List<Color> kpiColors = [
    BusinessColors.primaryBlue,
    BusinessColors.success,
    BusinessColors.warning,
    BusinessColors.accentCyan,
    BusinessColors.secondaryPurple,
    BusinessColors.accentEmerald,
  ];
  
  /// Chart colors for data visualization
  static const List<Color> chartColors = [
    BusinessColors.primaryBlue,
    BusinessColors.accentCyan,
    BusinessColors.success,
    BusinessColors.warning,
    BusinessColors.secondaryPurple,
    BusinessColors.accentRose,
    BusinessColors.accentOrange,
    BusinessColors.accentViolet,
    BusinessColors.accentEmerald,
    BusinessColors.secondaryTeal,
  ];
  
  /// Priority colors
  static const Color highPriority = BusinessColors.error;
  static const Color mediumPriority = BusinessColors.warning;
  static const Color lowPriority = BusinessColors.success;
  
  /// Department colors
  static const Color salesColor = BusinessColors.accentCyan;
  static const Color marketingColor = BusinessColors.accentRose;
  static const Color operationsColor = BusinessColors.success;
  static const Color financeColor = BusinessColors.primaryBlue;
  static const Color hrColor = BusinessColors.secondaryPurple;
  static const Color itColor = BusinessColors.accentViolet;
}
