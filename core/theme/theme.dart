import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF6C5CE7);
  static const Color accent = Color(0xFF00B894);

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.light),
    useMaterial3: true,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    primaryColor: primary,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: accent),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(fontSize: 14),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.dark),
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
