import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const primary = Color(0xFF0F172A);
  const secondary = Color(0xFF334155);
  const muted = Color(0xFF64748B);
  const background = Color(0xFFF8FAFC);
  const surface = Color(0xFFFFFFFF);
  const success = Color(0xFF059669);

  final colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: Colors.white,
    secondary: secondary,
    onSecondary: Colors.white,
    error: const Color(0xFFDC2626),
    onError: Colors.white,
    background: background,
    onBackground: primary,
    surface: surface,
    onSurface: primary,
    surfaceContainerHighest: const Color(0xFFE2E8F0),
    onSurfaceVariant: muted,
    outline: muted,
    shadow: const Color(0x14000000),
    inverseSurface: primary,
    onInverseSurface: Colors.white,
    inversePrimary: success,
    tertiary: success,
    onTertiary: Colors.white,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: primary.withOpacity(0.12),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(
          color: secondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: muted.withOpacity(0.25)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: muted.withOpacity(0.25)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: primary, width: 1.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: Color(0xFFDC2626)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: const TextStyle(color: secondary),
      helperStyle: const TextStyle(color: muted),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: primary,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        color: primary,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        color: primary,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: secondary,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: TextStyle(
        color: primary,
      ),
      bodySmall: TextStyle(
        color: muted,
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
    ),
  );
}
