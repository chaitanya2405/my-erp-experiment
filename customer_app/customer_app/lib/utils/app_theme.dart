// 🎨 CUSTOMER APP THEME - CROSS-PLATFORM ADAPTIVE
// Platform-optimized theming for Web, Android, iOS

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // 🎨 Brand Colors
  static const Color primaryBlue = Color(0xFF2B5CE6);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentRed = Color(0xFFEF4444);
  
  // 🌍 Platform-adaptive backgrounds
  static Color get platformBackground {
    if (kIsWeb) return const Color(0xFFF8FAFC);
    if (defaultTargetPlatform == TargetPlatform.iOS) return const Color(0xFFF2F2F7);
    return const Color(0xFFFFFFFF);
  }
  
  static Color get platformCard {
    if (kIsWeb) return Colors.white;
    if (defaultTargetPlatform == TargetPlatform.iOS) return const Color(0xFFFFFFFF);
    return const Color(0xFFFFFFFF);
  }
  
  // 📱 Responsive dimensions
  static double get cardRadius {
    if (kIsWeb) return 16;
    if (defaultTargetPlatform == TargetPlatform.iOS) return 12;
    return 20; // Android
  }
  
  static EdgeInsets get screenPadding {
    if (kIsWeb) return const EdgeInsets.all(24);
    if (defaultTargetPlatform == TargetPlatform.iOS) return const EdgeInsets.all(16);
    return const EdgeInsets.all(16); // Android
  }

  // 🌟 Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: platformCard,
        foregroundColor: const Color(0xFF1E293B),
        elevation: kIsWeb ? 0 : 1,
        centerTitle: defaultTargetPlatform == TargetPlatform.iOS,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: _platformHeaderStyle,
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: platformCard,
        shadowColor: Colors.black.withOpacity(0.1),
        elevation: kIsWeb ? 2 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius / 2),
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius / 2),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius / 2),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius / 2),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: platformCard,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        elevation: kIsWeb ? 0 : 8,
      ),
      
      // Text Theme
      textTheme: _buildTextTheme(),
      
      // Scaffold Background
      scaffoldBackgroundColor: platformBackground,
    );
  }

  // 🌙 Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F2937),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      
      cardTheme: CardThemeData(
        color: const Color(0xFF374151),
        shadowColor: Colors.black.withOpacity(0.3),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      
      scaffoldBackgroundColor: const Color(0xFF111827),
      textTheme: _buildTextTheme(isDark: true),
    );
  }

  // 📝 Platform-specific text styles
  static TextStyle get _platformHeaderStyle {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      );
    }
    if (kIsWeb) {
      return const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500,
      );
    }
    return const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
    );
  }

  static TextTheme _buildTextTheme({bool isDark = false}) {
    final Color textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color subtitleColor = isDark ? Colors.grey.shade300 : Colors.grey.shade600;
    
    return TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: subtitleColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: subtitleColor,
      ),
    );
  }

  // 🎯 Platform-specific shadows
  static List<BoxShadow> get platformShadow {
    if (kIsWeb) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
    }
    // Android elevation
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.15),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  // 🎨 Status Chip Colors
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
      case 'success':
        return accentGreen;
      case 'pending':
      case 'processing':
        return accentOrange;
      case 'cancelled':
      case 'failed':
        return accentRed;
      case 'shipped':
      case 'in_transit':
        return accentCyan;
      default:
        return primaryBlue;
    }
  }

  // 📐 Responsive breakpoints
  static bool isDesktop(BuildContext context) => 
      MediaQuery.of(context).size.width > 1024;
  static bool isTablet(BuildContext context) => 
      MediaQuery.of(context).size.width > 768 && 
      MediaQuery.of(context).size.width <= 1024;
  static bool isMobile(BuildContext context) => 
      MediaQuery.of(context).size.width <= 768;

  // 🎭 Platform-specific animations
  static Duration get animationDuration {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const Duration(milliseconds: 300);
    }
    return const Duration(milliseconds: 250);
  }

  static Curve get animationCurve {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Curves.easeInOut;
    }
    return Curves.fastOutSlowIn;
  }
}
