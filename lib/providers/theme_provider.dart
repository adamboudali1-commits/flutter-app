import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _useMaterial3 = true;

  bool get isDarkMode => _isDarkMode;
  bool get useMaterial3 => _useMaterial3;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _useMaterial3 = prefs.getBool('useMaterial3') ?? true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> toggleMaterial3() async {
    _useMaterial3 = !_useMaterial3;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useMaterial3', _useMaterial3);
    notifyListeners();
  }

  ThemeData getTheme() {
    final colorScheme = _isDarkMode
        ? ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
            surface: const Color(0xFF1E1E1E),
            surfaceContainerHighest: const Color(0xFF2D2D2D),
          )
        : ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
            surface: Colors.white,
            surfaceContainerHighest: const Color(0xFFF5F5F5),
          );

    return ThemeData(
      useMaterial3: _useMaterial3,
      colorScheme: colorScheme,

      /// --- AppBar ---
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 0,
      ),

      /// --- Boutons ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      /// --- Inputs (TextField) ---
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
      ),

      /// --- Correction CardThemeData (IMPORTANT) ---
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
