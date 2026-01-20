import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color safetyRed = Color(0xFFFF3B30);
  static const Color charcoal = Color(0xFF1A1A1A);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF5F5F7);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: pureWhite,
      primaryColor: safetyRed,
      colorScheme: const ColorScheme.light(
        primary: safetyRed,
        secondary: safetyRed,
        surface: pureWhite,
        onSurface: charcoal,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        headlineMedium: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          color: charcoal,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          color: charcoal,
          letterSpacing: -0.2,
        ),
        bodyLarge: GoogleFonts.inter(
          color: charcoal,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.inter(
          color: charcoal.withOpacity(0.8),
          height: 1.6,
          letterSpacing: 0.1,
        ),
      ),
      cardTheme: CardThemeData(
        color: pureWhite,
        elevation: 2,
        shadowColor: charcoal.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.only(bottom: 24),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: pureWhite,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: charcoal,
        ),
        iconTheme: IconThemeData(color: charcoal),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: pureWhite,
        selectedItemColor: safetyRed,
        unselectedItemColor: Colors.grey[400],
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
