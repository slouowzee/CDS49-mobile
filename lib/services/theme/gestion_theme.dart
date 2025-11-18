import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Gestionnaire de thème 
// Permet de basculer entre les thèmes clair et sombre et de sauvegarder la préférence

class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.light);

  // Charge le thème sauvegardé au démarrage
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('is_dark_mode') ?? false;
    value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  // Bascule le thème et sauvegarde la préférence
  Future<void> toggleTheme() async {
    value = value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', value == ThemeMode.dark);
  }
}

final themeController = ThemeController();