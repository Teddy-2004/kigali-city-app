import 'package:flutter/material.dart';

class AppColors {
  // Deep navy backgrounds
  static const Color background   = Color(0xFF080D17);
  static const Color surface      = Color(0xFF0F1623);
  static const Color surfaceHigh  = Color(0xFF161E2E);
  static const Color surfaceBorder= Color(0xFF1E2A3E);

  // Accent — electric teal
  static const Color primary      = Color(0xFF00E5A0);
  static const Color primaryDim   = Color(0xFF00B87D);
  static const Color secondary    = Color(0xFF4D9EFF);

  // Text
  static const Color textPrimary  = Color(0xFFEAF0FF);
  static const Color textSecondary= Color(0xFF6B7FA3);
  static const Color textMuted    = Color(0xFF3A4A63);

  // Semantic
  static const Color success      = Color(0xFF00E5A0);
  static const Color error        = Color(0xFFFF4D6A);
  static const Color warning      = Color(0xFFFFBD59);
  static const Color starColor    = Color(0xFFFFBD59);

  // Category badge colours
  static Color categoryColor(String cat) {
    switch (cat) {
      case 'Hospital':         return const Color(0xFFFF4D6A);
      case 'Pharmacy':         return const Color(0xFFFF4D6A);
      case 'Police Station':   return const Color(0xFF4D9EFF);
      case 'Library':          return const Color(0xFFFFBD59);
      case 'School':           return const Color(0xFFFFBD59);
      case 'Restaurant':       return const Color(0xFF00E5A0);
      case 'Café':             return const Color(0xFF00E5A0);
      case 'Park':             return const Color(0xFF5EE87A);
      case 'Tourist Attraction': return const Color(0xFFD97BFF);
      case 'Bank':             return const Color(0xFF4D9EFF);
      default:                 return const Color(0xFF6B7FA3);
    }
  }

  static IconData categoryIcon(String cat) {
    switch (cat) {
      case 'Hospital':           return Icons.local_hospital_rounded;
      case 'Police Station':     return Icons.local_police_rounded;
      case 'Library':            return Icons.local_library_rounded;
      case 'Restaurant':         return Icons.restaurant_rounded;
      case 'Café':               return Icons.coffee_rounded;
      case 'Park':               return Icons.park_rounded;
      case 'Tourist Attraction': return Icons.photo_camera_rounded;
      case 'Pharmacy':           return Icons.medication_rounded;
      case 'School':             return Icons.school_rounded;
      case 'Bank':               return Icons.account_balance_rounded;
      default:                   return Icons.place_rounded;
    }
  }
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      background: AppColors.background,
      surface: AppColors.surface,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      onBackground: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
      onPrimary: AppColors.background,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.surfaceBorder),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.surfaceBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.surfaceBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 11),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceHigh,
      selectedColor: AppColors.primary.withOpacity(0.12),
      checkmarkColor: AppColors.primary,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
      secondaryLabelStyle: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
      side: const BorderSide(color: AppColors.surfaceBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, letterSpacing: -0.8),
      headlineMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: AppColors.textPrimary, height: 1.5),
      bodyMedium: TextStyle(color: AppColors.textSecondary, height: 1.5),
      bodySmall: TextStyle(color: AppColors.textMuted, height: 1.4),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.surfaceBorder, space: 1, thickness: 1,
    ),
    iconTheme: const IconThemeData(color: AppColors.textSecondary),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceHigh,
      contentTextStyle: const TextStyle(color: AppColors.textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.background,
      elevation: 0,
      extendedTextStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
    ),
  );
}
