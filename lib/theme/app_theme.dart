import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF6C63FF),
        secondary: const Color(0xFF00C9A7),
        tertiary: const Color(0xFFFF6584),
        surface: const Color(0xFF151B2B),
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF0B0F19),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: const Color(0xFF6C63FF),
        inactiveTrackColor: Colors.white24,
        thumbColor: Colors.white,
        overlayColor: const Color(0xFF6C63FF).withOpacity(0.2),
        trackHeight: 6.0,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF6C63FF),
        secondary: const Color(0xFF00C9A7),
        tertiary: const Color(0xFFFF6584),
        surface: const Color(0xFFF0F2F8),
        onSurface: Colors.black87,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FD),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.black54),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: const Color(0xFF6C63FF),
        inactiveTrackColor: Colors.black12,
        thumbColor: const Color(0xFF6C63FF),
        overlayColor: const Color(0xFF6C63FF).withOpacity(0.2),
        trackHeight: 6.0,
      ),
    );
  }
}
