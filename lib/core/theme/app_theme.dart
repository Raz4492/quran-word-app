import 'package:flutter/material.dart';

/// Design tokens for the app: a calm, premium, restrained Islamic look —
/// deep neutral backgrounds, one elegant green accent, warm off-white text,
/// rounded cards, generous spacing. No gradients, no gaming-app energy.
class AppColors {
  AppColors._();

  static const Color primaryGreen = Color(0xFF1F6E5C);
  static const Color primaryGreenLight = Color(0xFF3D9482);
  static const Color gold = Color(0xFFC9A24B); // used sparingly for mastery/achievements

  // Light theme surfaces
  static const Color lightBackground = Color(0xFFFAF9F6);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1C1C1C);
  static const Color lightTextSecondary = Color(0xFF6B6B6B);

  // Dark theme surfaces
  static const Color darkBackground = Color(0xFF12181A);
  static const Color darkSurface = Color(0xFF1B2426);
  static const Color darkTextPrimary = Color(0xFFF5F1E8); // warm off-white
  static const Color darkTextSecondary = Color(0xFFA8B0AE);

  static const Color danger = Color(0xFFC0563D);
  static const Color success = primaryGreen;
}

class AppTextSizes {
  AppTextSizes._();
  static const double arabicCardLarge = 56;
  static const double arabicInline = 26;
  static const double heading = 22;
  static const double body = 15;
  static const double caption = 12;
}

class AppTheme {
  AppTheme._();

  static const String arabicFontFamily = 'NotoNaskhArabic';

  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryGreen,
      brightness: brightness,
      surface: isDark ? AppColors.darkSurface : AppColors.lightSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      textTheme: (isDark ? ThemeData.dark() : ThemeData.light())
          .textTheme
          .apply(
            bodyColor: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
            displayColor: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
      appBarTheme: AppBarTheme(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        foregroundColor:
            isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        indicatorColor: AppColors.primaryGreen.withOpacity(0.18),
        elevation: 0,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(color: AppColors.primaryGreen.withOpacity(0.5)),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryGreen,
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? Colors.white12 : Colors.black12,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  /// Large, dominant Arabic text style used on flashcards and headers.
  static TextStyle arabicStyle({
    double size = AppTextSizes.arabicCardLarge,
    Color? color,
    FontWeight weight = FontWeight.w600,
  }) {
    return TextStyle(
      fontFamily: arabicFontFamily,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.4,
    );
  }
}
