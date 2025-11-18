import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Gestionnaire de thème 
// Permet de basculer entre les thèmes clair et sombre et de sauvegarder la préférence par utilisateur

class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.light);

  // Génère la clé de préférence basée sur l'utilisateur connecté
  Future<String> _getThemeKey() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    // Si connecté, utilise une clé par utilisateur, sinon une clé globale
    return token != null ? 'is_dark_mode_$token' : 'is_dark_mode_guest';
  }

  // Charge le thème sauvegardé au démarrage
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token != null) {
      // Utilisateur connecté : charge son thème personnel
      final themeKey = await _getThemeKey();
      final isDark = prefs.getBool(themeKey) ?? false;
      value = isDark ? ThemeMode.dark : ThemeMode.light;
    } else {
      // Non connecté : thème clair par défaut
      value = ThemeMode.light;
    }
  }

  // Bascule le thème et sauvegarde la préférence pour l'utilisateur connecté
  Future<void> toggleTheme() async {
    value = value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token != null) {
      // Sauvegarde uniquement si l'utilisateur est connecté
      final themeKey = await _getThemeKey();
      await prefs.setBool(themeKey, value == ThemeMode.dark);
    }
  }

  // Réinitialise le thème à clair (appelé lors de la déconnexion)
  Future<void> resetToLight() async {
    value = ThemeMode.light;
  }
}

final themeController = ThemeController();