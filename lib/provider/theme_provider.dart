import 'package:flutter/material.dart';
import 'package:mobile_web/core/persistence/preference_helper.dart';

class ThemeProvider extends ChangeNotifier {
  late bool _isDark;
  late PreferenceHelper _preferences;
  bool get isDark => _isDark;

  ThemeProvider() {
    _isDark = false;
    _preferences = PreferenceHelper();
    getPreferences();
  }

  set isDark(bool value) {
    _isDark = value;
    _preferences.setTheme(value);
    notifyListeners();
  }

  getPreferences() async {
    _isDark = await _preferences.getTheme();
    notifyListeners();
  }
}