import 'package:flutter/material.dart';
import 'business_colors.dart';
import 'business_typography.dart';
import 'business_spacing.dart';

/// 🎨 **Business Theme System**
/// 
/// Complete theme definitions for:
/// - Light and dark theme support
/// - Material 3 design system integration
/// - Cross-platform consistency
/// - Professional enterprise aesthetics
class BusinessThemes {
  // ============================================================================
  // ☀️ LIGHT THEME
  // ============================================================================
  
  static ThemeData lightTheme = ThemeData(
    // Material 3 configuration
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Color scheme based on business colors
    colorScheme: const ColorScheme.light(
      primary: BusinessColors.primaryBlue,
      onPrimary: BusinessColors.lightTextOnPrimary,
      primaryContainer: BusinessColors.slate100,
      onPrimaryContainer: BusinessColors.primaryBlueDark,
      
      secondary: BusinessColors.secondaryIndigo,
      onSecondary: BusinessColors.lightTextOnPrimary,
      secondaryContainer: BusinessColors.slate50,
      onSecondaryContainer: BusinessColors.secondaryIndigo,
      
      tertiary: BusinessColors.secondaryTeal,
      onTertiary: BusinessColors.lightTextOnPrimary,
      tertiaryContainer: BusinessColors.slate50,
      onTertiaryContainer: BusinessColors.secondaryTeal,
      
      error: BusinessColors.error,
      onError: BusinessColors.lightTextOnPrimary,
      errorContainer: BusinessColors.errorSurface,
      onErrorContainer: BusinessColors.errorDark,
      
      background: BusinessColors.lightBackground,
      onBackground: BusinessColors.lightTextPrimary,
      
      surface: BusinessColors.lightSurface,
      onSurface: BusinessColors.lightTextPrimary,
      surfaceVariant: BusinessColors.gray50,
      onSurfaceVariant: BusinessColors.lightTextSecondary,
      
      outline: BusinessColors.lightBorder,
      outlineVariant: BusinessColors.gray200,
      
      shadow: BusinessColors.gray900,
      scrim: BusinessColors.gray900,
      
      inverseSurface: BusinessColors.gray800,
      onInverseSurface: BusinessColors.gray100,
      inversePrimary: BusinessColors.primaryBlueLight,
    ),
    
    // App bar theme
    appBarTheme: AppBarTheme(
      backgroundColor: BusinessColors.lightCard,
      foregroundColor: BusinessColors.lightTextPrimary,
      elevation: BusinessSpacing.elevationSM,
      shadowColor: BusinessColors.gray900.withOpacity(0.1),
      centerTitle: false,
      titleSpacing: BusinessSpacing.paddingMD,
      toolbarHeight: BusinessSpacing.appBarHeight,
      titleTextStyle: const TextStyle(
        fontSize: BusinessTypography.titleLarge,
        fontWeight: BusinessTypography.semiBold,
        fontFamily: BusinessTypography.primaryFont,
        color: BusinessColors.lightTextPrimary,
      ),
    ),
    
    // Card theme
    cardTheme: CardTheme(
      color: BusinessColors.lightCard,
      shadowColor: BusinessColors.gray900.withOpacity(0.1),
      elevation: BusinessSpacing.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BusinessSpacing.cardRadius),
      ),
      margin: BusinessSpacing.all(BusinessSpacing.marginSM),
    ),
    
    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: BusinessColors.primaryBlue,
        foregroundColor: BusinessColors.lightTextOnPrimary,
        elevation: BusinessSpacing.buttonElevation,
        padding: BusinessSpacing.symmetric(
          horizontal: BusinessSpacing.paddingLG,
          vertical: BusinessSpacing.paddingMD,
        ),
        minimumSize: const Size(BusinessSpacing.buttonMinWidth, BusinessSpacing.buttonHeightMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BusinessSpacing.buttonRadius),
        ),
        textStyle: const TextStyle(
          fontSize: BusinessTypography.labelLarge,
          fontWeight: BusinessTypography.medium,
          fontFamily: BusinessTypography.primaryFont,
        ),
      ),
    ),
    
    // Outlined button theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: BusinessColors.primaryBlue,
        side: const BorderSide(color: BusinessColors.primaryBlue),
        padding: BusinessSpacing.symmetric(
          horizontal: BusinessSpacing.paddingLG,
          vertical: BusinessSpacing.paddingMD,
        ),
        minimumSize: const Size(BusinessSpacing.buttonMinWidth, BusinessSpacing.buttonHeightMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BusinessSpacing.buttonRadius),
        ),
        textStyle: const TextStyle(
          fontSize: BusinessTypography.labelLarge,
          fontWeight: BusinessTypography.medium,
          fontFamily: BusinessTypography.primaryFont,
        ),
      ),
    ),
    
    // Text button theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: BusinessColors.primaryBlue,
        padding: BusinessSpacing.symmetric(
          horizontal: BusinessSpacing.paddingMD,
          vertical: BusinessSpacing.paddingSM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BusinessSpacing.buttonRadius),
        ),
        textStyle: const TextStyle(
          fontSize: BusinessTypography.labelLarge,
          fontWeight: BusinessTypography.medium,
          fontFamily: BusinessTypography.primaryFont,
        ),
      ),
    ),
    
    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: BusinessColors.lightCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(BusinessSpacing.inputRadius),
        borderSide: const BorderSide(color: BusinessColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(BusinessSpacing.inputRadius),
        borderSide: const BorderSide(color: BusinessColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(BusinessSpacing.inputRadius),
        borderSide: const BorderSide(color: BusinessColors.primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(BusinessSpacing.inputRadius),
        borderSide: const BorderSide(color: BusinessColors.error),
      ),
      contentPadding: BusinessSpacing.symmetric(
        horizontal: BusinessSpacing.paddingMD,
        vertical: BusinessSpacing.paddingMD,
      ),
      labelStyle: const TextStyle(
        fontSize: BusinessTypography.labelMedium,
        fontWeight: BusinessTypography.medium,
        fontFamily: BusinessTypography.primaryFont,
        color: BusinessColors.lightTextSecondary,
      ),
      hintStyle: const TextStyle(
        fontSize: BusinessTypography.bodyMedium,
        fontWeight: BusinessTypography.regular,
        fontFamily: BusinessTypography.primaryFont,
        color: BusinessColors.lightTextTertiary,
      ),
    ),
    
    // Chip theme
    chipTheme: ChipThemeData(
      backgroundColor: BusinessColors.gray100,
      deleteIconColor: BusinessColors.lightTextSecondary,
      disabledColor: BusinessColors.gray200,
      selectedColor: BusinessColors.primaryBlue,
      secondarySelectedColor: BusinessColors.secondaryIndigo,
      padding: BusinessSpacing.symmetric(
        horizontal: BusinessSpacing.paddingSM,
        vertical: BusinessSpacing.paddingXS,
      ),
      labelStyle: const TextStyle(
        fontSize: BusinessTypography.labelSmall,
        fontWeight: BusinessTypography.medium,
        fontFamily: BusinessTypography.primaryFont,
      ),
      secondaryLabelStyle: const TextStyle(
        fontSize: BusinessTypography.labelSmall,
        fontWeight: BusinessTypography.medium,
        fontFamily: BusinessTypography.primaryFont,
        color: BusinessColors.lightTextOnPrimary,
      ),
      brightness: Brightness.light,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BusinessSpacing.chipRadius),
      ),
    ),
    
    // List tile theme
    listTileTheme: ListTileThemeData(
      contentPadding: BusinessSpacing.symmetric(
        horizontal: BusinessSpacing.paddingMD,
        vertical: BusinessSpacing.paddingSM,
      ),
      minVerticalPadding: BusinessSpacing.paddingSM,
      iconColor: BusinessColors.lightTextSecondary,
      textColor: BusinessColors.lightTextPrimary,
      titleTextStyle: const TextStyle(
        fontSize: BusinessTypography.titleMedium,
        fontWeight: BusinessTypography.medium,
        fontFamily: BusinessTypography.primaryFont,
        color: BusinessColors.lightTextPrimary,
      ),
      subtitleTextStyle: const TextStyle(
        fontSize: BusinessTypography.bodySmall,
        fontWeight: BusinessTypography.regular,
        fontFamily: BusinessTypography.primaryFont,
        color: BusinessColors.lightTextSecondary,
      ),
    ),
    
    // Tab bar theme
    tabBarTheme: TabBarTheme(
      labelColor: BusinessColors.primaryBlue,
      unselectedLabelColor: BusinessColors.lightTextSecondary,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: BusinessColors.primaryBlue, width: 2),
      ),
      labelStyle: const TextStyle(
        fontSize: BusinessTypography.labelLarge,
        fontWeight: BusinessTypography.semiBold,
        fontFamily: BusinessTypography.primaryFont,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: BusinessTypography.labelLarge,
        fontWeight: BusinessTypography.medium,
        fontFamily: BusinessTypography.primaryFont,
      ),
    ),
    
    // Bottom navigation bar theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: BusinessColors.lightCard,
      selectedItemColor: BusinessColors.primaryBlue,
      unselectedItemColor: BusinessColors.lightTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: BusinessSpacing.elevationSM,
      selectedLabelStyle: const TextStyle(
        fontSize: BusinessTypography.labelSmall,
        fontWeight: BusinessTypography.semiBold,
        fontFamily: BusinessTypography.primaryFont,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: BusinessTypography.labelSmall,
        fontWeight: BusinessTypography.medium,
        fontFamily: BusinessTypography.primaryFont,
      ),
    ),
    
    // Floating action button theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: BusinessColors.primaryBlue,
      foregroundColor: BusinessColors.lightTextOnPrimary,
      elevation: BusinessSpacing.fabElevation,
      shape: CircleBorder(),
    ),
    
    // Navigation rail theme
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: BusinessColors.lightCard,
      selectedIconTheme: const IconThemeData(color: BusinessColors.primaryBlue),
      unselectedIconTheme: const IconThemeData(color: BusinessColors.lightTextSecondary),
      selectedLabelTextStyle: const TextStyle(
        fontSize: BusinessTypography.labelSmall,
        fontWeight: BusinessTypography.semiBold,
        fontFamily: BusinessTypography.primaryFont,
        color: BusinessColors.primaryBlue,
      ),
      unselectedLabelTextStyle: const TextStyle(
        fontSize: BusinessTypography.labelSmall,
        fontWeight: BusinessTypography.medium,
        fontFamily: BusinessTypography.primaryFont,
        color: BusinessColors.lightTextSecondary,
      ),
    ),
    
    // Drawer theme
    drawerTheme: DrawerThemeData(
      backgroundColor: BusinessColors.lightCard,
      width: BusinessSpacing.drawerWidth,
      elevation: BusinessSpacing.elevationMD,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(BusinessSpacing.radiusLG),
          bottomRight: Radius.circular(BusinessSpacing.radiusLG),
        ),
      ),
    ),
    
    // Icon theme
    iconTheme: const IconThemeData(
      color: BusinessColors.lightTextSecondary,
      size: BusinessSpacing.iconMD,
    ),
    
    // Primary icon theme
    primaryIconTheme: const IconThemeData(
      color: BusinessColors.lightTextOnPrimary,
      size: BusinessSpacing.iconMD,
    ),
    
    // Divider theme
    dividerTheme: const DividerThemeData(
      color: BusinessColors.lightDivider,
      thickness: 1,
      space: 1,
    ),
    
    // Font family
    fontFamily: BusinessTypography.primaryFont,
  );
  
  // ============================================================================
  // 🌙 DARK THEME
  // ============================================================================
  
  static ThemeData darkTheme = ThemeData(
    // Material 3 configuration
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // Color scheme based on business colors
    colorScheme: const ColorScheme.dark(
      primary: BusinessColors.primaryBlueLight,
      onPrimary: BusinessColors.darkTextOnPrimary,
      primaryContainer: BusinessColors.primaryBlueDark,
      onPrimaryContainer: BusinessColors.primaryBlueLight,
      
      secondary: BusinessColors.secondaryIndigo,
      onSecondary: BusinessColors.darkTextOnPrimary,
      secondaryContainer: BusinessColors.slate800,
      onSecondaryContainer: BusinessColors.secondaryIndigo,
      
      tertiary: BusinessColors.secondaryTeal,
      onTertiary: BusinessColors.darkTextOnPrimary,
      tertiaryContainer: BusinessColors.slate800,
      onTertiaryContainer: BusinessColors.secondaryTeal,
      
      error: BusinessColors.errorLight,
      onError: BusinessColors.darkTextOnPrimary,
      errorContainer: BusinessColors.errorDark,
      onErrorContainer: BusinessColors.errorLight,
      
      background: BusinessColors.darkBackground,
      onBackground: BusinessColors.darkTextPrimary,
      
      surface: BusinessColors.darkSurface,
      onSurface: BusinessColors.darkTextPrimary,
      surfaceVariant: BusinessColors.slate700,
      onSurfaceVariant: BusinessColors.darkTextSecondary,
      
      outline: BusinessColors.darkBorder,
      outlineVariant: BusinessColors.slate600,
      
      shadow: BusinessColors.slate900,
      scrim: BusinessColors.slate900,
      
      inverseSurface: BusinessColors.gray100,
      onInverseSurface: BusinessColors.gray800,
      inversePrimary: BusinessColors.primaryBlue,
    ),
    
    // App bar theme
    appBarTheme: AppBarTheme(
      backgroundColor: BusinessColors.darkCard,
      foregroundColor: BusinessColors.darkTextPrimary,
      elevation: BusinessSpacing.elevationSM,
      shadowColor: BusinessColors.slate900.withOpacity(0.3),
      centerTitle: false,
      titleSpacing: BusinessSpacing.paddingMD,
      toolbarHeight: BusinessSpacing.appBarHeight,
      titleTextStyle: const TextStyle(
        fontSize: BusinessTypography.titleLarge,
        fontWeight: BusinessTypography.semiBold,
        fontFamily: BusinessTypography.primaryFont,
        color: BusinessColors.darkTextPrimary,
      ),
    ),
    
    // Card theme
    cardTheme: CardTheme(
      color: BusinessColors.darkCard,
      shadowColor: BusinessColors.slate900.withOpacity(0.3),
      elevation: BusinessSpacing.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BusinessSpacing.cardRadius),
      ),
      margin: BusinessSpacing.all(BusinessSpacing.marginSM),
    ),
    
    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: BusinessColors.primaryBlueLight,
        foregroundColor: BusinessColors.darkTextOnPrimary,
        elevation: BusinessSpacing.buttonElevation,
        padding: BusinessSpacing.symmetric(
          horizontal: BusinessSpacing.paddingLG,
          vertical: BusinessSpacing.paddingMD,
        ),
        minimumSize: const Size(BusinessSpacing.buttonMinWidth, BusinessSpacing.buttonHeightMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BusinessSpacing.buttonRadius),
        ),
        textStyle: const TextStyle(
          fontSize: BusinessTypography.labelLarge,
          fontWeight: BusinessTypography.medium,
          fontFamily: BusinessTypography.primaryFont,
        ),
      ),
    ),
    
    // Font family
    fontFamily: BusinessTypography.primaryFont,
  );
  
  // ============================================================================
  // 🎯 THEME UTILITIES
  // ============================================================================
  
  /// Get current theme data
  static ThemeData getCurrentTheme(BuildContext context) {
    return Theme.of(context);
  }
  
  /// Check if current theme is dark
  static bool isDarkTheme(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
  
  /// Get theme-appropriate color
  static Color getThemeColor(BuildContext context, Color lightColor, Color darkColor) {
    return isDarkTheme(context) ? darkColor : lightColor;
  }
  
  /// Create custom theme based on seed color
  static ThemeData createCustomTheme({
    required Color seedColor,
    required Brightness brightness,
  }) {
    final baseTheme = brightness == Brightness.light ? lightTheme : darkTheme;
    
    return baseTheme.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
      ),
    );
  }
}
