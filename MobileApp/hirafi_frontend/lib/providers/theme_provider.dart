import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';

enum AppThemeMode { light, dark, ocean, sunset, system }

class ThemeProvider extends ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.light;
  late SharedPreferences _prefs;

  AppThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadFromPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  void _loadFromPrefs() async {
    await _initPrefs();
    final themeStr = _prefs.getString('themeMode') ?? 'light';
    _themeMode = AppThemeMode.values.firstWhere((e) => e.toString() == 'AppThemeMode.$themeStr', orElse: () => AppThemeMode.light);
    notifyListeners();
  }

  Future<void> setTheme(AppThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString('themeMode', mode.toString().split('.').last);
    notifyListeners();
  }

  ThemeData get currentTheme {
    if (_themeMode == AppThemeMode.system) {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark ? AppTheme.darkTheme : AppTheme.lightTheme;
    }
    switch (_themeMode) {
      case AppThemeMode.dark:
        return AppTheme.darkTheme;
      case AppThemeMode.ocean:
        return AppTheme.oceanTheme;
      case AppThemeMode.sunset:
        return AppTheme.sunsetTheme;
      case AppThemeMode.light:
      default:
        return AppTheme.lightTheme;
    }
  }
}
