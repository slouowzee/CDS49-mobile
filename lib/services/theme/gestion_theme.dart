import 'package:flutter/material.dart';

// Gestionnaire de thème 
// Permet de basculer entre les thèmes clair et sombre

class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.light);

  void toggleTheme() {
    value = value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    
  }
}

final themeController = ThemeController();