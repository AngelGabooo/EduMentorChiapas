import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  String _fontSizeSetting = 'Medio';
  bool _isDarkMode = false;

  String get fontSizeSetting => _fontSizeSetting;
  bool get isDarkMode => _isDarkMode;

  void setFontSize(String fontSize) {
    _fontSizeSetting = fontSize;
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }
}