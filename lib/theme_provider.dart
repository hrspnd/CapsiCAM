import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// THEME PROVIDER
// Manages light/dark/system theme and persists user preference
// ============================================================

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey  = 'theme_mode'; // default to light
  static const String _localeKey = 'locale';  

  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');        

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;  

  bool isDark(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    // theme
    final saved = prefs.getString(_themeKey);
    if (saved == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (saved == 'system') {
      _themeMode = ThemeMode.system;
    } else {
      _themeMode = ThemeMode.light;
    }

    final savedLocale = prefs.getString(_localeKey);
    if (savedLocale == 'fil') {
      _locale = const Locale('fil');
    } else {
      _locale = const Locale('en');
    }

    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    switch (mode) {
      case ThemeMode.dark:
        await prefs.setString(_themeKey, 'dark');
        break;
      case ThemeMode.system:
        await prefs.setString(_themeKey, 'system');
        break;
      default:
        await prefs.setString(_themeKey, 'light');
    }
  }

  void setLight()  => setTheme(ThemeMode.light);
  void setDark()   => setTheme(ThemeMode.dark);
  void setSystem() => setTheme(ThemeMode.system);
}