import 'package:flutter/material.dart';

abstract final class AppColors {
  static const blue = Color(0xFF0666F2);
  static const navy = Color(0xFF10285B);
  static const paleBlue = Color(0xFFF3F8FF);
  static const surface = Color(0xFFFFFFFF);
  static const success = Color(0xFF168E5A);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFDF334C);
}

abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const page = EdgeInsets.symmetric(horizontal: 20, vertical: 16);
}

abstract final class AppRadii {
  static const small = Radius.circular(12);
  static const medium = Radius.circular(16);
  static const large = Radius.circular(22);
}

abstract final class AppTheme {
  static final light = _create(Brightness.light);
  static final dark = _create(Brightness.dark);

  static ThemeData _create(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      brightness: brightness,
      surface: isDark ? const Color(0xFF111A2E) : AppColors.surface,
    );
    final text = ThemeData(brightness: brightness).textTheme.apply(
      fontFamily: 'Noto Sans Bengali',
      bodyColor: isDark ? Colors.white : AppColors.navy,
      displayColor: isDark ? Colors.white : AppColors.navy,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme.copyWith(primary: AppColors.blue),
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF0D1526)
          : AppColors.paleBlue,
      textTheme: text.copyWith(
        displaySmall: text.displaySmall?.copyWith(
          fontSize: 30,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: text.titleLarge?.copyWith(
          fontSize: 23,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: text.titleMedium?.copyWith(
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: text.bodyLarge?.copyWith(fontSize: 16),
        bodyMedium: text.bodyMedium?.copyWith(fontSize: 14),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : AppColors.navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: text.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppRadii.medium),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(AppRadii.small),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(AppRadii.small),
          ),
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(AppRadii.small),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide.none,
        labelStyle: text.labelMedium,
      ),
    );
  }
}
