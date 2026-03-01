import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Tema otimizado para TVs e Tablets com fontes maiores
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.blueAccent,
      brightness: Brightness.light,
      textTheme: GoogleFonts.robotoTextTheme().copyWith(
        displayLarge: GoogleFonts.roboto(fontSize: 48, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.roboto(fontSize: 28, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.roboto(fontSize: 20),
        bodyMedium: GoogleFonts.roboto(fontSize: 18),
        labelLarge: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w500),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.blueAccent,
      brightness: Brightness.dark,
      textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.roboto(fontSize: 48, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.roboto(fontSize: 28, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.roboto(fontSize: 20),
        bodyMedium: GoogleFonts.roboto(fontSize: 18),
        labelLarge: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w500),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
