// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ThemeProvider with ChangeNotifier {
//   ThemeMode _themeMode = ThemeMode.system;

//   ThemeMode get themeMode => _themeMode;

//   bool get isDarkMode => _themeMode == ThemeMode.dark;

//   ThemeProvider() {
//     _loadTheme();
//   }

//   Future<void> _loadTheme() async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedTheme = prefs.getString('themeMode');
//     if (savedTheme == 'dark') {
//       _themeMode = ThemeMode.dark;
//     } else if (savedTheme == 'light') {
//       _themeMode = ThemeMode.light;
//     } else {
//       _themeMode = ThemeMode.system;
//     }
//     notifyListeners();
//   }

//   Future<void> toggleTheme(bool isDark) async {
//     _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('themeMode', isDark ? 'dark' : 'light');
//     notifyListeners();
//   }

//   Future<void> setSystemTheme() async {
//     _themeMode = ThemeMode.system;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('themeMode', 'system');
//     notifyListeners();
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme initially
  String? _role;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    // Don't load theme immediately; wait for role to be set
  }

  // Load the theme based on the role
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (_role == null) {
      _role = prefs.getString('role')?.toLowerCase();
    }
    String themeKey = _role == 'doctor' ? 'doctor_theme_mode' : 'user_theme_mode';
    final String? savedTheme = prefs.getString(themeKey);

    if (savedTheme != null) {
      // If a theme is saved, load it
      switch (savedTheme) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        case 'system':
          _themeMode = ThemeMode.system;
          break;
        default:
          _themeMode = ThemeMode.system; // Fallback to system if the saved value is invalid
      }
    } else {
      // If no theme is saved, default to system theme
      _themeMode = ThemeMode.system;
      await prefs.setString(themeKey, 'system'); // Save the default system theme
    }
    print('ThemeProvider: Loaded theme for $_role: $_themeMode');
    notifyListeners();
  }

  // Save the theme based on the role
  Future<void> _saveThemeMode(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    String themeKey = _role == 'doctor' ? 'doctor_theme_mode' : 'user_theme_mode';
    await prefs.setString(themeKey, theme);
    print('ThemeProvider: Saved theme for $_role: $theme');
  }

  // Toggle between Light and Dark Mode
  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await _saveThemeMode(isDark ? 'dark' : 'light');
    notifyListeners();
  }

  // Set the theme to System Default
  Future<void> setSystemTheme() async {
    _themeMode = ThemeMode.system;
    await _saveThemeMode('system');
    notifyListeners();
  }

  // Update the role and load the corresponding theme
  Future<void> updateRole(String? role) async {
    _role = role?.toLowerCase();
    print('ThemeProvider: Updated role to $_role');
    await _loadTheme();
  }
}