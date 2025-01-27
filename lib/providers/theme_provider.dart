import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void initialize() {
    final now = DateTime.now();
    var hour = now.hour;
    bool isNight = hour >= 18 || hour < 6; // Night: 6:00 PM to 5:59 AM
    bool isLight = hour >= 6 && hour < 18; // Day: 6:00 AM to 5:59 PM

    if (isNight) {
      _themeMode = ThemeMode.dark;
    } else if (isLight) {
      _themeMode = ThemeMode.light;
    }
  }
}
