import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Typography
class AppTypography {
  AppTypography._();
  
  static const fontFamily = 'Poppins';
  
  // Light Theme Text Styles
  static TextStyle heading = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    letterSpacing: -0.5,
  );
  
  static TextStyle subheading = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    letterSpacing: -0.25,
  );
  
  static TextStyle body = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
    height: 1.5,
  );
  
  static TextStyle caption = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textDarkSecondary,
    height: 1.4,
  );
  
  static TextStyle button = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );
  
  static TextStyle error = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: AppColors.error,
    height: 1.4,
  );
  
  static TextStyle titleLarge = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 22.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    letterSpacing: -0.5,
  );
  
  static TextStyle titleMedium = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    letterSpacing: -0.1,
  );
  
  static TextStyle titleSmall = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    letterSpacing: -0.05,
  );
  
  static TextStyle labelLarge = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    letterSpacing: 0.1,
  );
  
  static TextStyle labelMedium = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    letterSpacing: 0.05,
  );
  
  static TextStyle labelSmall = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    letterSpacing: 0.05,
  );
  
  static TextStyle bodyLarge = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
    height: 1.5,
  );
  
  static TextStyle bodyMedium = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
    height: 1.5,
  );
  
  static TextStyle bodySmall = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
    height: 1.5,
  );
  
  // Dark Theme Text Styles
  static TextStyle headingDark = heading.copyWith(color: AppColors.textLight);
  static TextStyle subheadingDark = subheading.copyWith(color: AppColors.textLight);
  static TextStyle bodyDark = body.copyWith(color: AppColors.textLight);
  static TextStyle captionDark = caption.copyWith(color: AppColors.textLightSecondary);
  static TextStyle titleLargeDark = titleLarge.copyWith(color: AppColors.textLight);
  static TextStyle titleMediumDark = titleMedium.copyWith(color: AppColors.textLight);
  static TextStyle titleSmallDark = titleSmall.copyWith(color: AppColors.textLight);
  static TextStyle labelLargeDark = labelLarge.copyWith(color: AppColors.textLight);
  static TextStyle labelMediumDark = labelMedium.copyWith(color: AppColors.textLight);
  static TextStyle labelSmallDark = labelSmall.copyWith(color: AppColors.textLight);
  static TextStyle bodyLargeDark = bodyLarge.copyWith(color: AppColors.textLight);
  static TextStyle bodyMediumDark = bodyMedium.copyWith(color: AppColors.textLight);
  static TextStyle bodySmallDark = bodySmall.copyWith(color: AppColors.textLight);
}

/// Colors for the application
class AppColors {
  AppColors._();
  
  // Brand Colors - Updated to green theme with blue accent
  static const Color primary = Color(0xFF4CAF50); // Green as main color
  static const Color primaryLight = Color(0xFF81C784); // Light green
  static const Color primaryDark = Color(0xFF388E3C); // Dark green
  static const Color secondary = Color(0xFF2196F3); // Blue as secondary color
  static const Color secondaryLight = Color(0xFF64B5F6); // Light blue
  static const Color secondaryDark = Color(0xFF1976D2); // Dark blue
  static const Color accent = Color(0xFF03A9F4); // Light blue accent
  
  // UI Colors
  static const Color background = Colors.white; // White background
  static const Color backgroundDark = Color(0xFF1B5E20); // Dark green for dark mode
  static const Color card = Colors.white;
  static const Color cardDark = Color(0xFF2E7D32); // Dark green for cards in dark mode
  static const Color divider = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF388E3C);
  
  // Text Colors
  static const Color textDark = Color(0xFF212121);
  static const Color textDarkSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFAFAFA);
  static const Color textLightSecondary = Color(0xFFBDBDBD);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50); // Green for success
  static const Color error = Color(0xFFF44336); // Red for error
  static const Color warning = Color(0xFFFF9800); // Orange for warning
  static const Color info = Color(0xFF2196F3); // Blue for info
}

/// Paddings and margins for the application
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  
  static const EdgeInsets screenPadding = EdgeInsets.all(m);
  static const EdgeInsets cardPadding = EdgeInsets.all(m);
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(vertical: m, horizontal: m);
}

/// Border radius values
class AppRadius {
  AppRadius._();
  
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 12.0;
  static const double l = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  
  static BorderRadius get buttonRadius => BorderRadius.circular(s);
  static BorderRadius get cardRadius => BorderRadius.circular(m);
  static BorderRadius get inputRadius => BorderRadius.circular(s);
}

/// Shadow styles
class AppShadows {
  AppShadows._();
  
  static BoxShadow get small => BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 2,
    offset: const Offset(0, 1),
  );
  
  static BoxShadow get medium => BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 10,
    offset: const Offset(0, 4),
  );
  
  static BoxShadow get large => BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 16,
    offset: const Offset(0, 8),
  );
}

/// Theme configurations
class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      background: AppColors.background,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.heading,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.secondaryDark,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    cardTheme: CardTheme(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardRadius,
        side: BorderSide(color: AppColors.divider.withOpacity(0.5), width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: AppSpacing.inputPadding,
      border: OutlineInputBorder(
        borderRadius: AppRadius.inputRadius,
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.inputRadius,
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.inputRadius,
        borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.inputRadius,
        borderSide: BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppRadius.inputRadius,
        borderSide: BorderSide(color: AppColors.error, width: 2.0),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.buttonRadius,
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.buttonRadius,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
      ),
    ),
    fontFamily: AppTypography.fontFamily,
    textTheme: TextTheme(
      displayLarge: AppTypography.heading,
      bodyLarge: AppTypography.body,
      labelLarge: AppTypography.button,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      background: AppColors.backgroundDark,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: AppColors.textLight,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.headingDark,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.backgroundDark,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.secondaryDark,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    cardTheme: CardTheme(
      color: AppColors.cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardRadius,
        side: BorderSide(color: AppColors.dividerDark.withOpacity(0.2), width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[900],
      contentPadding: AppSpacing.inputPadding,
      border: OutlineInputBorder(
        borderRadius: AppRadius.inputRadius,
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.inputRadius,
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.inputRadius,
        borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.inputRadius,
        borderSide: BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppRadius.inputRadius,
        borderSide: BorderSide(color: AppColors.error, width: 2.0),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.buttonRadius,
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.buttonRadius,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
      ),
    ),
    fontFamily: AppTypography.fontFamily,
    textTheme: TextTheme(
      displayLarge: AppTypography.headingDark,
      bodyLarge: AppTypography.bodyDark,
      labelLarge: AppTypography.button,
    ),
  );

  /// Initialize theme settings
  static void initialize() {
    Get.changeThemeMode(ThemeMode.system);
  }

  /// Toggle between light and dark themes
  static void toggleTheme() {
    Get.changeThemeMode(
      Get.isDarkMode ? ThemeMode.light : ThemeMode.dark
    );
  }
}
