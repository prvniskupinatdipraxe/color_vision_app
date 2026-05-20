import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';
import 'services/theme_provider.dart';
import 'services/camera_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Preload camera asynchronously in the background
  CameraManager().initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const ColorVisionApp(),
    ),
  );
}

class ColorVisionApp extends StatelessWidget {
  const ColorVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    // Determine if we should use dark theme based on ThemeMode and system brightness
    final bool isDarkMode = themeProvider.themeMode == ThemeMode.dark || 
        (themeProvider.themeMode == ThemeMode.system && 
         MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return MaterialApp(
      title: 'Vision Assist Pro',
      theme: AppTheme.getTheme(
        isDark: false,
        isHighContrast: themeProvider.isHighContrast,
        isLargeText: themeProvider.isLargeText,
      ),
      darkTheme: AppTheme.getTheme(
        isDark: true,
        isHighContrast: themeProvider.isHighContrast,
        isLargeText: themeProvider.isLargeText,
      ),
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}
