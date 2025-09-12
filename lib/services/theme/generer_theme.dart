import 'package:flutter/material.dart';

class GenererTheme {
  static ThemeData buildThemeFromJson(Map<String, dynamic> json) {
    // Couleurs principales du thème
    final primary = parseColor(json['primary']);
    final secondary = parseColor(json['secondary']);
    final tertiary = parseColor(json['tertiary']);
    final error = parseColor(json['error']);

    // Couleurs de contraste
    final onPrimary = parseColor(json['onPrimary']);
    final onSecondary = parseColor(json['onSecondary']);
    final onTertiary = parseColor(json['onTertiary']);
    final onError = parseColor(json['onError']);
    final onSurface = parseColor(json['onSurface']);

    // Couleurs de surface
    final surface = parseColor(json['surface']);
    final surfaceContainerHighest = parseColor(json['surfaceContainerHighest']);
    final outline = parseColor(json['outline']);
    final shadow = parseColor(json['shadow']);
    final scrim = parseColor(json['scrim']);

    // Couleurs spécifiques à certains composants
    final appBarColor = parseColor(json['appBarColor'] ?? json['primary']);
    final navBarColor = parseColor(json['bottomNavColor'] ?? json['primary']);
    final selectedItemColor = parseColor(
      json['selectedItemColor'] ?? json['primary'],
    );
    final unselectedItemColor = parseColor(
      json['unselectedItemColor'] ?? '#888888',
    );

    // Paramètres de texte
    final textColor = parseColor(json['textColor']);
    final fontFamily = json['fontFamily'];
    final bodyFontSize = double.tryParse(json['bodyFontSize'] ?? '14') ?? 14;
    final titleFontSize = double.tryParse(json['titleFontSize'] ?? '20') ?? 20;

    // Construction du ColorScheme à partir du JSON
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      tertiary: tertiary,
      onTertiary: onTertiary,
      error: error,
      onError: onError,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: surfaceContainerHighest,
      outline: outline,
      shadow: shadow,
      scrim: scrim,
    );

    // Construction du ThemeData principal
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primaryColor: primary,
      scaffoldBackgroundColor: parseColor(json['scaffoldBackgroundColor']),
      cardColor: parseColor(json['cardColor']),
      dividerColor: parseColor(json['dividerColor']),
      iconTheme: IconThemeData(color: parseColor(json['iconColor'])),

      // Thème de l'AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: appBarColor,
        foregroundColor: parseColor(json['appBarTextColor']),
      ),

      // Thème de la BottomNavigationBar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: navBarColor,
        selectedItemColor: selectedItemColor,
        unselectedItemColor: unselectedItemColor,
      ),

      // Thème de la NavigationBar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: parseColor(json['bottomNavColor']),
        indicatorColor: Colors.transparent,
        // Couleur des icônes selon leur état
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: parseColor(json['onPrimary']));
          }
          return IconThemeData(color: parseColor(json['iconColor']));
        }),

        // Couleur du texte sous les icônes
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected)
              ? parseColor(json['onPrimary'])
              : parseColor(json['textColor']);
          return TextStyle(
            color: color,
            fontFamily: json['fontFamily'],
            fontSize: double.tryParse(json['bodyFontSize'] ?? '14') ?? 14,
          );
        }),
      ),

      // Thème de texte global
      textTheme: TextTheme(
        bodyMedium: TextStyle(
          color: textColor,
          fontSize: bodyFontSize,
          fontFamily: fontFamily,
        ),
        titleLarge: TextStyle(
          color: textColor,
          fontSize: titleFontSize,
          fontFamily: fontFamily,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Thème des boutons classiques
      buttonTheme: ButtonThemeData(
        buttonColor: parseColor(json['buttonColor']),
      ),

      // Autres effets visuels
      shadowColor: shadow,
      splashColor: parseColor(json['splashColor']),
      hintColor: parseColor(json['hintColor']),
    );
  }

  // Fonction pour convertir une couleur hex en Color Flutter
  static Color parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return Colors.black;
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6)
      hexColor = 'FF$hexColor'; // Ajoute l’opacité si absente
    return Color(int.parse(hexColor, radix: 16));
  }
}
