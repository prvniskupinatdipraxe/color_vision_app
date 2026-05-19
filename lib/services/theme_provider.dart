import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = "theme_mode";
  static const String _highContrastKey = "high_contrast";
  static const String _largeTextKey = "large_text";
  static const String _simplifiedUIKey = "simplified_ui";

  ThemeMode _themeMode = ThemeMode.system;
  bool _isHighContrast = false;
  bool _isLargeText = false;
  bool _isSimplifiedUI = false;

  ThemeMode get themeMode => _themeMode;
  bool get isHighContrast => _isHighContrast;
  bool get isLargeText => _isLargeText;
  bool get isSimplifiedUI => _isSimplifiedUI;

  ThemeProvider() {
    _loadSettings();
  }

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  void setHighContrast(bool value) async {
    _isHighContrast = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_highContrastKey, value);
  }

  void setLargeText(bool value) async {
    _isLargeText = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_largeTextKey, value);
  }

  void setSimplifiedUI(bool value) async {
    _isSimplifiedUI = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_simplifiedUIKey, value);
  }

  void resetToDefaults() async {
    _themeMode = ThemeMode.system;
    _isHighContrast = false;
    _isLargeText = false;
    _isSimplifiedUI = false;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, ThemeMode.system.index);
    await prefs.setBool(_highContrastKey, false);
    await prefs.setBool(_largeTextKey, false);
    await prefs.setBool(_simplifiedUIKey, false);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final int? themeIndex = prefs.getInt(_themeKey);
    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
    }
    
    _isHighContrast = prefs.getBool(_highContrastKey) ?? false;
    _isLargeText = prefs.getBool(_largeTextKey) ?? false;
    _isSimplifiedUI = prefs.getBool(_simplifiedUIKey) ?? false;
    
    notifyListeners();
  }
}
