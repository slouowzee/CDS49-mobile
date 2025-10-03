import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobil_cds49/models/usr.dart';
import 'package:mobil_cds49/services/api/config.dart';
import 'package:mobil_cds49/services/gestion_token/token.dart';

class UsrApi 
{
// Permet de se connecter à l'API et de récupérer les informations de l'utilisateur
Future<Map<String, dynamic>?> loginUser(String mail,String paswd) async {
  final response = await http.post(
    Uri.parse('${AppConfig.apiBaseUrl}/api/login'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'email': mail,      
      'password': paswd,   
    }),
    
  );
  // Vérification du statut de la réponse 
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    if (data['status'] == "success") {
  // Enregistrement du token    
      await GestionToken.saveToken(data['data']['token']); 
      return {"message": data['message'], "user": data['data']['user'], "token": data['data']['token']};
    }
  }

  if (response.statusCode == 400) {
    // Si le statut est 400, Données manquantes. Email et mot de passe sont requis.
    return {
      "message": "Email et mot de passe requis",
      "user": null,
      "token": null
    };
  }

  if (response.statusCode == 401) {
    // Si le statut est 401, l'authentification a échoué
    return {
      "message": "Identifiants incorrects",
      "user": null,
      "token": null
    };
  }

  if (response.statusCode == 405) {
    // Si le statut est 405, la méthode n'est pas autorisée
    return {
      "message": "Méthode non autorisée",
      "user": null,
      "token": null
    };
  }

  return null; // Retourne null si la connexion échoue
  }

// Permet de récupérer les informations de l'utilisateur connecté
  static Future<User?> infoUser() async {
     final token = await GestionToken.getToken(); 
    if (token == null || token.isEmpty) {
      return null; // Non autorisé, utilisateur non connecté ou token manquant (période de session expirée)
    }
    final url = Uri.parse('${AppConfig.apiBaseUrl}/api/profile/get');  
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
    );
      if (response.statusCode == 200) {
        // Récupération des données utilisateur
        final jsonBody = json.decode(response.body);
        // Try several locations for the user object
        Map<String, dynamic>? userJson;
        if (jsonBody is Map<String, dynamic>) {
          if (jsonBody.containsKey('data')) {
            final data = jsonBody['data'];
            if (data is Map<String, dynamic>) {
              if (data.containsKey('user')) {
                userJson = (data['user'] as Map<String, dynamic>?) ;
              } else {
                // maybe data itself is the user object
                userJson = (data as Map<String, dynamic>?);
              }
            }
          }
          // fallback: top-level 'user'
          if (userJson == null && jsonBody.containsKey('user')) {
            userJson = (jsonBody['user'] as Map<String, dynamic>?);
          }
          // fallback: if body looks like user directly
          if (userJson == null) {
            // check for keys that look like user fields
            final possibleKeys = ['ideleve', 'nomeleve', 'mail'];
            if (possibleKeys.any((k) => jsonBody.containsKey(k))) {
              userJson = jsonBody.cast<String, dynamic>();
            }
          }
        }

        if (userJson != null) {
          return User.fromJson(userJson);
        } else {
          // Unexpected payload shape - log (for debugging) and return null
          // ignore: avoid_print
          print('[UsrApi.infoUser] Unexpected JSON shape: ' + response.body);
          return null;
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('[UsrApi.infoUser] Exception: $e');
      return null; // Erreur réponse serveur
    }
    return null; // Non autorisé, utilisateur non connecté ou token manquant (période de session expirée)
  }

  /// Debug helper: returns the raw response body and status code from profile/get.
  /// Useful to call during development to inspect the exact JSON returned by the server.
  static Future<Map<String, dynamic>?> debugGetProfileRaw() async {
    final token = await GestionToken.getToken();
    if (token == null || token.isEmpty) return null;
    final url = Uri.parse('${AppConfig.apiBaseUrl}/api/profile/get');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return { 'status': response.statusCode, 'body': response.body };
    } catch (e) {
      // ignore: avoid_print
      print('[UsrApi.debugGetProfileRaw] Exception: $e');
      return null;
    }
  }
}