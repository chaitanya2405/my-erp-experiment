import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🔧 **Safe Integration Wrapper**
/// 
/// This wrapper allows you to safely test business template components
/// with your existing ERP modules without breaking anything.

/// Feature flag provider for controlled rollout
final businessTemplateEnabledProvider = StateProvider<bool>((ref) => false);

/// Theme mode provider
final businessThemeModeProvider = StateProvider<bool>((ref) => false);

/// Business Colors (Safe to use alongside existing themes)
class SafeBusinessColors {
  // Primary palette
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryBlueLight = Color(0xFF3B82F6);
  static const Color primaryBlueDark = Color(0xFF1E40AF);
  
  // Neutral palette
  static const Color neutralGray50 = Color(0xFFF9FAFB);
  static const Color neutralGray100 = Color(0xFFF3F4F6);
  static const Color neutralGray900 = Color(0xFF111827);
  
  // Status colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningYellow = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  
  // Get context-aware colors
  static Color backgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
      ? neutralGray900 
      : neutralGray50;
  }
  
  static Color cardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
      ? neutralGray900 
      : Colors.white;
  }
  
  static Color textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
      ? Colors.white 
      : neutralGray900;
  }
}

/// Safe Business Typography (No conflicts with existing themes)
class SafeBusinessTypography {
  static TextStyle headingLarge(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge?.copyWith(
      fontWeight: FontWeight.bold,
      color: SafeBusinessColors.textPrimary(context),
    ) ?? const TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      height: 1.2,
    );
  }
  
  static TextStyle headingMedium(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: SafeBusinessColors.textPrimary(context),
    ) ?? const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.3,
    );
  }
  
  static TextStyle bodyLarge(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: SafeBusinessColors.textPrimary(context),
    ) ?? const TextStyle(
      fontSize: 16,
      height: 1.5,
    );
  }
  
  static TextStyle bodyMedium(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: SafeBusinessColors.textPrimary(context),
    ) ?? const TextStyle(
      fontSize: 14,
      height: 1.4,
    );
  }
}

/// Safe Business Card Component (No theme conflicts)
class SafeBusinessCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final Color? backgroundColor;
  final bool useBorder;

  const SafeBusinessCard({
    Key? key,
    this.title,
    this.subtitle,
    this.child,
    this.onTap,
    this.padding,
    this.elevation,
    this.backgroundColor,
    this.useBorder = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? 2,
      color: backgroundColor ?? SafeBusinessColors.cardColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: useBorder 
          ? BorderSide(color: SafeBusinessColors.neutralGray100, width: 1)
          : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) ...[
                Text(
                  title!,
                  style: SafeBusinessTypography.headingMedium(context),
                ),
                const SizedBox(height: 8),
              ],
              if (subtitle != null) ...[
                Text(
                  subtitle!,
                  style: SafeBusinessTypography.bodyMedium(context).copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (child != null) child!,
            ],
          ),
        ),
      ),
    );
  }
}

/// KPI Card for business metrics
class SafeBusinessKPICard extends StatelessWidget {
  final String title;
  final String value;
  final String? trend;
  final bool isPositive;
  final IconData? icon;
  final Color? customColor;

  const SafeBusinessKPICard({
    Key? key,
    required this.title,
    required this.value,
    this.trend,
    this.isPositive = true,
    this.icon,
    this.customColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final trendColor = isPositive 
      ? SafeBusinessColors.successGreen 
      : SafeBusinessColors.errorRed;
    
    return SafeBusinessCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: SafeBusinessTypography.bodyMedium(context).copyWith(
                  color: Colors.grey[600],
                ),
              ),
              if (icon != null)
                Icon(
                  icon,
                  color: customColor ?? SafeBusinessColors.primaryBlue,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: SafeBusinessTypography.headingLarge(context),
          ),
          if (trend != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: trendColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  trend!,
                  style: SafeBusinessTypography.bodyMedium(context).copyWith(
                    color: trendColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Safe Module Wrapper (Compatible with your existing Riverpod setup)
class SafeBusinessModuleWrapper extends ConsumerWidget {
  final Widget child;
  final String moduleName;
  final bool enableBusinessStyling;

  const SafeBusinessModuleWrapper({
    Key? key,
    required this.child,
    required this.moduleName,
    this.enableBusinessStyling = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusinessEnabled = ref.watch(businessTemplateEnabledProvider) && enableBusinessStyling;
    
    if (isBusinessEnabled) {
      return Container(
        color: SafeBusinessColors.backgroundColor(context),
        child: child,
      );
    }
    
    return child; // Return original widget if business template is disabled
  }
}

/// Safe Business Button
class SafeBusinessButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const SafeBusinessButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.icon,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary 
            ? SafeBusinessColors.primaryBlue 
            : Colors.transparent,
          foregroundColor: isPrimary 
            ? Colors.white 
            : SafeBusinessColors.primaryBlue,
          elevation: isPrimary ? 2 : 0,
          side: isPrimary 
            ? null 
            : const BorderSide(color: SafeBusinessColors.primaryBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
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
      ),
    );
  }
}

/// Feature Flag Helper
class BusinessTemplateFeatures {
  /// Check if a specific feature is enabled
  static bool isFeatureEnabled(WidgetRef ref, String featureName) {
    final isGlobalEnabled = ref.watch(businessTemplateEnabledProvider);
    // You can add specific feature flags here
    return isGlobalEnabled;
  }
  
  /// Enable business template globally
  static void enableBusinessTemplate(WidgetRef ref) {
    ref.read(businessTemplateEnabledProvider.notifier).state = true;
  }
  
  /// Disable business template globally
  static void disableBusinessTemplate(WidgetRef ref) {
    ref.read(businessTemplateEnabledProvider.notifier).state = false;
  }
}

/// Emergency rollback utility
class EmergencyRollback {
  static void disableAllBusinessFeatures(WidgetRef ref) {
    ref.read(businessTemplateEnabledProvider.notifier).state = false;
    ref.read(businessThemeModeProvider.notifier).state = false;
    
    // Add any additional cleanup here
    debugPrint('🚨 Emergency rollback: All business template features disabled');
  }
}
