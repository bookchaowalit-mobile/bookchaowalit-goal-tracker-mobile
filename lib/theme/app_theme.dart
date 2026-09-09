import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const pine = Color(0xFF174936);
  static const trail = Color(0xFFCA542D);
  static const sky = Color(0xFF2C6F8F);
  static const snow = Color(0xFFF7F5EF);
  static const night = Color(0xFF101B17);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: pine,
      brightness: Brightness.light,
      surface: snow,
    ).copyWith(
      primary: pine,
      secondary: trail,
      tertiary: sky,
      outline: const Color(0xFF747B75),
      surfaceContainerHighest: const Color(0xFFE5E9E3),
    );
    return _base(scheme);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF89C7A5),
      brightness: Brightness.dark,
      surface: night,
    ).copyWith(
      primary: const Color(0xFF9AD5B4),
      secondary: const Color(0xFFFFAD8C),
      tertiary: const Color(0xFF9CCFE5),
      outline: const Color(0xFF89948E),
      surfaceContainerHighest: const Color(0xFF26342E),
    );
    return _base(scheme);
  }

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(height: 72),
      visualDensity: VisualDensity.standard,
    );
  }
}
