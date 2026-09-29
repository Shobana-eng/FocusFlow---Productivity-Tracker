import 'package:flutter/material.dart';
import 'shared_pref_service.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;

  ThemeProvider() {
    _loadTheme();
  }

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> _loadTheme() async {
    _isDarkMode = await SharedPrefService.instance.isDarkMode();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await SharedPrefService.instance.setDarkMode(_isDarkMode);
    notifyListeners();
  }
}
