import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _followSystemTheme = true;
  
  ThemeMode get themeMode => _themeMode;
  bool get followSystemTheme => _followSystemTheme;
  
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
  
  ThemeProvider() {
    _loadThemeMode();
  }
  
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if user has set a preference or wants to follow system
    _followSystemTheme = prefs.getBool('followSystemTheme') ?? true;
    
    if (_followSystemTheme) {
      _themeMode = ThemeMode.system;
    } else {
      final isDark = prefs.getBool('isDarkMode') ?? true;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    }
    
    notifyListeners();
  }
  
  /// Toggle between light and dark mode (disables system theme following)
  Future<void> toggleTheme() async {
    // When toggling manually, stop following system theme
    _followSystemTheme = false;
    
    if (_themeMode == ThemeMode.system) {
      // If currently on system mode, determine current brightness and toggle
      final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
      _themeMode = brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    } else {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('followSystemTheme', false);
    await prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
    
    notifyListeners();
  }
  
  /// Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    _followSystemTheme = mode == ThemeMode.system;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('followSystemTheme', _followSystemTheme);
    
    if (mode != ThemeMode.system) {
      await prefs.setBool('isDarkMode', mode == ThemeMode.dark);
    }
    
    notifyListeners();
  }
  
  /// Enable system theme following
  Future<void> followSystem() async {
    _followSystemTheme = true;
    _themeMode = ThemeMode.system;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('followSystemTheme', true);
    
    notifyListeners();
  }
}
