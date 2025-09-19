//Classe pour la configuration de l'application (adresses de l'API)
// apiBaseUrlC est actuellement non fonctionnelle dans l'application et via API
// Uilisation apiBaseUrlA Fonctionnelle

/*class AppConfig {
  static const String apiBaseUrlA = "http://10.0.2.2:9000"; // Adresse IP de l'API --ici accès localhost depuis un émulateur androïd
  static const String apiBaseUrlC = "http://localhost:9000"; // Adresse IP de l'API --ici accès localhost depuis un navigateur web
}*/

import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;

class AppConfig {
  static late final String apiBaseUrl;
  static late final String appVersion;

  // Méthode pour lire la configuration depuis le fichier .env.dev.json présent dans assets car Flutter ne sait pas lire les fichiers .env directement
  static Future<void> load() async {
    //CHANGER ICI POUR PASSER EN PRODUCTION
    // final jsonString = await rootBundle.loadString('assets/env.prod.json');
    final jsonString = await rootBundle.loadString('assets/env.dev.json');
    final Map<String, dynamic> config = jsonDecode(jsonString);

    if (kIsWeb) {
      apiBaseUrl = config['API_URL_WEB'];
    } else if (Platform.isAndroid) {
      apiBaseUrl = config['API_URL_ANDROID'];
    } else if (Platform.isIOS) {
      apiBaseUrl = config['API_URL_IOS'];
    } else {
      apiBaseUrl = config['API_URL_WEB'] ?? 'https://frontap3.dombtsig.local';
    }

    appVersion = config['APP_VERSION'] ?? '1.0.0';
  }
}
