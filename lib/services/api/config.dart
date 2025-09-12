//Classe pour la configuration de l'application (adresses de l'API)
// apiBaseUrlC est actuellement non fonctionnelle dans l'application et via API
// Uilisation apiBaseUrlA Fonctionnelle

/*class AppConfig {
  static const String apiBaseUrlA = "http://10.0.2.2:9000"; // Adresse IP de l'API --ici accès localhost depuis un émulateur androïd
  static const String apiBaseUrlC = "http://localhost:9000"; // Adresse IP de l'API --ici accès localhost depuis un navigateur web
}*/

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  static final String apiBaseUrl = _resolveApiUrl();
  static const String appVersion = String.fromEnvironment('APP_VERSION');

  static String _resolveApiUrl() {
    if (kIsWeb) {
      return const String.fromEnvironment('API_URL_WEB');
    } else if (Platform.isAndroid) {
      return const String.fromEnvironment('API_URL_ANDROID');
    } else if (Platform.isIOS) {
      return const String.fromEnvironment('API_URL_IOS');
    } else {
      // Fallback pour d'autres plateformes (Windows, macOS, etc.)
      return const String.fromEnvironment(
        'API_URL_WEB',
        defaultValue: 'https://frontap3.dombtsig.local',
      );
    }
  }
}
