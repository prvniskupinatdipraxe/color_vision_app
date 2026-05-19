import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData getTheme({
    required bool isDark,
    required bool isHighContrast,
    required bool isLargeText,
  }) {
    final double fontScale = isLargeText ? 1.2 : 1.0;
    
    if (isDark) {
      final Color primary = isHighContrast ? const Color(0xFF8B85FF) : const Color(0xFF6C63FF);
      final Color surface = isHighContrast ? Colors.black : const Color(0xFF151B2B);
      final Color background = isHighContrast ? Colors.black : const Color(0xFF0B0F19);
      final Color onSurface = Colors.white;

      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: primary,
          secondary: isHighContrast ? Colors.cyanAccent : const Color(0xFF00C9A7),
          tertiary: const Color(0xFFFF6584),
          surface: surface,
          onSurface: onSurface,
          outline: isHighContrast ? Colors.white : Colors.white24,
        ),
        scaffoldBackgroundColor: background,
        textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 32 * fontScale, fontWeight: FontWeight.bold, color: onSurface),
          displayMedium: TextStyle(fontSize: 28 * fontScale, fontWeight: FontWeight.bold, color: onSurface),
          displaySmall: TextStyle(fontSize: 24 * fontScale, fontWeight: FontWeight.bold, color: onSurface),
          headlineMedium: TextStyle(fontSize: 20 * fontScale, fontWeight: FontWeight.w600, color: onSurface),
          titleLarge: TextStyle(fontSize: 18 * fontScale, fontWeight: FontWeight.bold, color: onSurface),
          bodyLarge: TextStyle(fontSize: 16 * fontScale, color: isHighContrast ? Colors.white : Colors.white70),
          bodyMedium: TextStyle(fontSize: 14 * fontScale, color: isHighContrast ? Colors.white : Colors.white70),
          bodySmall: TextStyle(fontSize: 12 * fontScale, color: isHighContrast ? Colors.white : Colors.white60),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: primary,
          inactiveTrackColor: isHighContrast ? Colors.white38 : Colors.white24,
          thumbColor: Colors.white,
          overlayColor: primary.withOpacity(0.2),
          trackHeight: isHighContrast ? 8.0 : 6.0,
        ),
        dividerTheme: DividerThemeData(
          color: isHighContrast ? Colors.white38 : Colors.white10,
          thickness: isHighContrast ? 1.5 : 1.0,
        ),
      );
    } else {
      final Color primary = isHighContrast ? const Color(0xFF4A40FF) : const Color(0xFF6C63FF);
      final Color background = isHighContrast ? Colors.white : const Color(0xFFF8F9FD);
      final Color surface = isHighContrast ? Colors.white : const Color(0xFFF0F2F8);
      final Color onSurface = Colors.black;

      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          primary: primary,
          secondary: isHighContrast ? Colors.teal : const Color(0xFF00C9A7),
          tertiary: const Color(0xFFFF6584),
          surface: surface,
          onSurface: onSurface,
          outline: isHighContrast ? Colors.black : Colors.black12,
        ),
        scaffoldBackgroundColor: background,
        textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 32 * fontScale, fontWeight: FontWeight.bold, color: onSurface),
          displayMedium: TextStyle(fontSize: 28 * fontScale, fontWeight: FontWeight.bold, color: onSurface),
          displaySmall: TextStyle(fontSize: 24 * fontScale, fontWeight: FontWeight.bold, color: onSurface),
          headlineMedium: TextStyle(fontSize: 20 * fontScale, fontWeight: FontWeight.w600, color: onSurface),
          titleLarge: TextStyle(fontSize: 18 * fontScale, fontWeight: FontWeight.bold, color: onSurface),
          bodyLarge: TextStyle(fontSize: 16 * fontScale, color: isHighContrast ? Colors.black : Colors.black54),
          bodyMedium: TextStyle(fontSize: 14 * fontScale, color: isHighContrast ? Colors.black : Colors.black54),
          bodySmall: TextStyle(fontSize: 12 * fontScale, color: isHighContrast ? Colors.black : Colors.black45),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: primary,
          inactiveTrackColor: isHighContrast ? Colors.black38 : Colors.black12,
          thumbColor: primary,
          overlayColor: primary.withOpacity(0.2),
          trackHeight: isHighContrast ? 8.0 : 6.0,
        ),
        dividerTheme: DividerThemeData(
          color: isHighContrast ? Colors.black38 : Colors.black12,
          thickness: isHighContrast ? 1.5 : 1.0,
        ),
      );
    }
  }
}
