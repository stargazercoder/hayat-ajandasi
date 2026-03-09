import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Dark Colors
  static const Color bgDark = Color(0xFF0D0D14);
  static const Color surfaceDark = Color(0xFF15151F);
  static const Color surface2Dark = Color(0xFF1E1E2E);
  static const Color borderDark = Color(0xFF2A2A3E);
  static const Color textDark = Color(0xFFF0F0FA);
  static const Color mutedDark = Color(0xFF6B6B85);

  // Light Colors
  static const Color bgLight = Color(0xFFFAF8F5);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surface2Light = Color(0xFFF0EDE8);
  static const Color borderLight = Color(0xFFE0DBD2);
  static const Color textLight = Color(0xFF1A1A2E);
  static const Color mutedLight = Color(0xFF8A8A9A);

  // Accent Colors
  static const Color accent = Color(0xFFC8F04A);
  static const Color accent2 = Color(0xFFFF6B6B);
  static const Color accent3 = Color(0xFF4AF0C8);
  static const Color accent4 = Color(0xFFF0A84A);
  static const Color gold = Color(0xFFFFD700);
  static const Color purple = Color(0xFFA78BFA);

  static final List<Color> accentOptions = [
    const Color(0xFFC8F04A),
    const Color(0xFFFF6B6B),
    const Color(0xFF4AF0C8),
    const Color(0xFFF0A84A),
    const Color(0xFFA78BFA),
    const Color(0xFFF472B6),
    const Color(0xFF38BDF8),
    const Color(0xFFFFD700),
    const Color(0xFFEF4444),
    const Color(0xFF22C55E),
  ];

  static ThemeData dark(Color accentColor) {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      colorScheme: ColorScheme.dark(
        primary: accentColor,
        surface: surfaceDark,
        onSurface: textDark,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardTheme(
        color: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderDark),
        ),
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2Dark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide(color: accentColor),
        ),
        labelStyle: const TextStyle(color: mutedDark, fontSize: 11),
        hintStyle: const TextStyle(color: mutedDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
    );
  }

  static ThemeData light(Color accentColor) {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgLight,
      colorScheme: ColorScheme.light(
        primary: accentColor,
        surface: surfaceLight,
        onSurface: textLight,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(ThemeData.light().textTheme),
      cardTheme: CardTheme(
        color: surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight),
        ),
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2Light,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide(color: accentColor),
        ),
        labelStyle: const TextStyle(color: mutedLight, fontSize: 11),
        hintStyle: const TextStyle(color: mutedLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
    );
  }
}
