// 🎨 SHARED DESIGN SYSTEM
// Unified design components that can be used across all apps
// Ensures consistent UI/UX across customer, supplier, and admin apps

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// ============================================================================
// 🎨 UNIFIED DESIGN SYSTEM
// ============================================================================

class SharedERPDesignSystem {
  // 🎨 Core Brand Colors (consistent across all apps)
  static const Color primaryBlue = Color(0xFF2B5CE6);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentRed = Color(0xFFEF4444);
  
  // 🌈 Semantic Colors
  static const Color successColor = accentGreen;
  static const Color warningColor = accentOrange;
  static const Color errorColor = accentRed;
  static const Color infoColor = accentCyan;
  
  // 🌍 Platform-Adaptive Backgrounds
  static Color get platformBackground {
    if (kIsWeb) return const Color(0xFFF8FAFC);
    if (defaultTargetPlatform == TargetPlatform.macOS) return const Color(0xFFF5F5F7);
    if (defaultTargetPlatform == TargetPlatform.windows) return const Color(0xFFF3F3F3);
    return const Color(0xFFFFFFFF);
  }
  
  static Color get platformCard {
    if (kIsWeb) return Colors.white;
    if (defaultTargetPlatform == TargetPlatform.macOS) return const Color(0xFFFFFFFF);
    if (defaultTargetPlatform == TargetPlatform.windows) return const Color(0xFFFAFAFA);
    return const Color(0xFFFFFFFF);
  }
  
  // 🎯 Platform-Adaptive Shadows
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
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
    }
    if (defaultTargetPlatform == TargetPlatform.windows) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];
    }
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.15),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }
  
  // 📐 Platform-Adaptive Border Radius
  static BorderRadius get platformRadius {
    if (kIsWeb) return BorderRadius.circular(16);
    if (defaultTargetPlatform == TargetPlatform.macOS) return BorderRadius.circular(12);
    if (defaultTargetPlatform == TargetPlatform.windows) return BorderRadius.circular(8);
    return BorderRadius.circular(20);
  }
  
  // 📱 Responsive Breakpoints
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width > 1024;
  static bool isTablet(BuildContext context) => MediaQuery.of(context).size.width > 768 && MediaQuery.of(context).size.width <= 1024;
  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width <= 768;
  
  // 🎨 Typography Scale
  static const TextStyle h1 = TextStyle(fontSize: 32, fontWeight: FontWeight.w700);
  static const TextStyle h2 = TextStyle(fontSize: 28, fontWeight: FontWeight.w600);
  static const TextStyle h3 = TextStyle(fontSize: 24, fontWeight: FontWeight.w600);
  static const TextStyle h4 = TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
  static const TextStyle body1 = TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
  static const TextStyle body2 = TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
  static const TextStyle caption = TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
}

// ============================================================================
// 🧩 SHARED UI COMPONENTS
// ============================================================================

// 📊 Shared Stat Card
class SharedStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final Color color;
  final IconData icon;

  const SharedStatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.change,
    required this.color,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SharedERPDesignSystem.platformCard,
        borderRadius: SharedERPDesignSystem.platformRadius,
        boxShadow: SharedERPDesignSystem.platformShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

// 🎨 Shared Status Chip
class SharedStatusChip extends StatelessWidget {
  final String status;
  final Color? customColor;

  const SharedStatusChip({
    Key? key,
    required this.status,
    this.customColor,
  }) : super(key: key);

  Color get _statusColor {
    if (customColor != null) return customColor!;
    
    switch (status.toLowerCase()) {
      case 'completed':
      case 'active':
      case 'delivered':
        return SharedERPDesignSystem.successColor;
      case 'pending':
      case 'processing':
        return SharedERPDesignSystem.warningColor;
      case 'cancelled':
      case 'failed':
      case 'inactive':
        return SharedERPDesignSystem.errorColor;
      default:
        return SharedERPDesignSystem.infoColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// 🎯 Shared Action Button
class SharedActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;

  const SharedActionButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isDisabled || isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? SharedERPDesignSystem.primaryBlue,
        foregroundColor: textColor ?? Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: SharedERPDesignSystem.platformRadius,
        ),
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(text),
              ],
            ),
    );
  }
}

// 📝 Shared Form Field
class SharedFormField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;

  const SharedFormField({
    Key? key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: SharedERPDesignSystem.platformRadius,
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: SharedERPDesignSystem.platformRadius,
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: SharedERPDesignSystem.platformRadius,
              borderSide: BorderSide(color: SharedERPDesignSystem.primaryBlue),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}

// 📱 Shared Loading Widget
class SharedLoadingWidget extends StatelessWidget {
  final String? message;

  const SharedLoadingWidget({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(SharedERPDesignSystem.primaryBlue),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// 📄 Shared Empty State Widget
class SharedEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;

  const SharedEmptyState({
    Key? key,
    required this.title,
    required this.message,
    required this.icon,
    this.onAction,
    this.actionText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 24),
              SharedActionButton(
                text: actionText!,
                onPressed: onAction!,
                icon: Icons.add,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 🎨 SHARED THEME DATA
// ============================================================================

class SharedERPThemes {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: SharedERPDesignSystem.primaryBlue,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: SharedERPDesignSystem.platformCard,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: SharedERPDesignSystem.platformCard,
        shadowColor: Colors.black.withOpacity(0.1),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: SharedERPDesignSystem.platformRadius,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SharedERPDesignSystem.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: SharedERPDesignSystem.platformRadius,
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: SharedERPDesignSystem.platformRadius,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: SharedERPDesignSystem.primaryBlue,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F2937),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF374151),
        shadowColor: Colors.black.withOpacity(0.3),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: SharedERPDesignSystem.platformRadius,
        ),
      ),
    );
  }
}
