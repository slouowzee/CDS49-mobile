import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobil_cds49/models/usr.dart';
import 'package:mobil_cds49/services/api/config.dart';
import 'package:mobil_cds49/services/gestion_token/token.dart';

class UsrApi 
{
// Permet de se connecter à l'API et de récupérer les informations de l'utilisateur
Future<Map<String, dynamic>?> loginUser(String mail,String paswd) async {
  print('\n[DEBUG] ═══════════════════════════════════════');
  print('[DEBUG] 🔐 Tentative de connexion');
  print('[DEBUG] ═══════════════════════════════════════');
  print('[DEBUG] 📧 Email: $mail');
  print('[DEBUG] 🌐 URL: ${AppConfig.apiBaseUrl}/api/login');
  
  try {
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
    
    print('[DEBUG] 📥 Réponse reçue - Status: ${response.statusCode}');
    print('[DEBUG] 📄 Body: ${response.body}');
    
    // Vérification du statut de la réponse 
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == "success") {
        print('[DEBUG] ✅ Connexion réussie !');
        print('[DEBUG] ═══════════════════════════════════════\n');
        // Enregistrement du token    
        await GestionToken.saveToken(data['data']['token']); 
        return {"message": data['message'], "user": data['data']['user'], "token": data['data']['token']};
      }
    }

    if (response.statusCode == 400) {
      print('[DEBUG] ❌ Erreur 400 - Données manquantes');
      print('[DEBUG] ═══════════════════════════════════════\n');
      return {
        "message": "Email et mot de passe requis",
        "user": null,
        "token": null
      };
    }

    if (response.statusCode == 401) {
      print('[DEBUG] ❌ Erreur 401 - Authentification refusée');
      print('[DEBUG] 💡 Le serveur a répondu MAIS refuse les identifiants');
      print('[DEBUG] 💡 Cela peut signifier:');
      print('[DEBUG]    - Email ou mot de passe incorrect');
      print('[DEBUG]    - Mot de passe hashé avec une config différente');
      print('[DEBUG] ═══════════════════════════════════════\n');
      return {
        "message": "Identifiants incorrects",
        "user": null,
        "token": null
      };
    }

    if (response.statusCode == 405) {
      print('[DEBUG] ❌ Erreur 405 - Méthode non autorisée');
      print('[DEBUG] ═══════════════════════════════════════\n');
      return {
        "message": "Méthode non autorisée",
        "user": null,
        "token": null
      };
    }

    print('[DEBUG] ❌ Erreur ${response.statusCode} - Non gérée');
    print('[DEBUG] ═══════════════════════════════════════\n');
    return {
      "message": "Erreur serveur (${response.statusCode})",
      "user": null,
      "token": null
    };
    
  } catch (e) {
    print('[DEBUG] 💥 EXCEPTION - Connexion impossible !');
    print('[DEBUG] 🔴 Type: ${e.runtimeType}');
    print('[DEBUG] 🔴 Message: $e');
    print('[DEBUG] 💡 Le serveur est probablement:');
    print('[DEBUG]    - Hors ligne');
    print('[DEBUG]    - Inaccessible depuis votre appareil');
    print('[DEBUG]    - Bloqué par un firewall');
    print('[DEBUG] ═══════════════════════════════════════\n');
    return {
      "message": "❌ SERVEUR INACCESSIBLE - Vérifiez qu'il est démarré",
      "user": null,
      "token": null
    };
  }
}

// Permet de récupérer les informations de l'utilisateur connecté
  static Future<User?> infoUser() async {
    print('\n[DEBUG PROFILE] ═══════════════════════════════════════');
    print('[DEBUG PROFILE] 👤 Récupération du profil utilisateur');
    print('[DEBUG PROFILE] ═══════════════════════════════════════');
    
    final token = await GestionToken.getToken(); 
    if (token == null || token.isEmpty) {
      print('[DEBUG PROFILE] ❌ Pas de token - Utilisateur non connecté');
      print('[DEBUG PROFILE] ═══════════════════════════════════════\n');
      return null;
    }
    
    print('[DEBUG PROFILE] ✅ Token trouvé: ${token.substring(0, 20)}...');
    
    final url = Uri.parse('${AppConfig.apiBaseUrl}/api/profile/get');
    print('[DEBUG PROFILE] 🌐 URL: $url');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('[DEBUG PROFILE] 📥 Réponse reçue - Status: ${response.statusCode}');
      print('[DEBUG PROFILE] 📄 Body: ${response.body}');
      
      if (response.statusCode == 200) {
        // Récupération des données utilisateur
        final jsonBody = json.decode(response.body);
        print('[DEBUG PROFILE] 📦 JSON décodé: $jsonBody');
        
        // Try several locations for the user object
        Map<String, dynamic>? userJson;
        if (jsonBody is Map<String, dynamic>) {
          if (jsonBody.containsKey('data')) {
            print('[DEBUG PROFILE] 🔍 Clé "data" trouvée');
            final data = jsonBody['data'];
            if (data is Map<String, dynamic>) {
              if (data.containsKey('user')) {
                print('[DEBUG PROFILE] 🔍 Clé "data.user" trouvée');
                userJson = (data['user'] as Map<String, dynamic>?) ;
              } else {
                print('[DEBUG PROFILE] 🔍 Pas de clé "user", data est peut-être l\'utilisateur');
                userJson = (data as Map<String, dynamic>?);
              }
            }
          }
          // fallback: top-level 'user'
          if (userJson == null && jsonBody.containsKey('user')) {
            print('[DEBUG PROFILE] 🔍 Clé "user" trouvée au niveau racine');
            userJson = (jsonBody['user'] as Map<String, dynamic>?);
          }
          // fallback: if body looks like user directly
          if (userJson == null) {
            print('[DEBUG PROFILE] 🔍 Recherche de champs utilisateur directement');
            final possibleKeys = ['ideleve', 'nomeleve', 'mail'];
            if (possibleKeys.any((k) => jsonBody.containsKey(k))) {
              print('[DEBUG PROFILE] 🔍 Champs utilisateur trouvés directement');
              userJson = jsonBody.cast<String, dynamic>();
            }
          }
        }

        if (userJson != null) {
          print('[DEBUG PROFILE] ✅ UserJson trouvé: $userJson');
          print('[DEBUG PROFILE] 🔄 Création de l\'objet User...');
          try {
            final user = User.fromJson(userJson);
            print('[DEBUG PROFILE] ✅ Utilisateur créé avec succès !');
            print('[DEBUG PROFILE]    ID: ${user.ideleve}');
            print('[DEBUG PROFILE]    Nom: ${user.nomeleve}');
            print('[DEBUG PROFILE]    Prénom: ${user.prenomeleve}');
            print('[DEBUG PROFILE]    Email: ${user.mail}');
            print('[DEBUG PROFILE] ═══════════════════════════════════════\n');
            return user;
          } catch (e) {
            print('[DEBUG PROFILE] ❌ Erreur lors de la création User: $e');
            print('[DEBUG PROFILE] ═══════════════════════════════════════\n');
            return null;
          }
        } else {
          print('[DEBUG PROFILE] ❌ UserJson est null - Structure JSON inattendue');
          print('[DEBUG PROFILE] ═══════════════════════════════════════\n');
          return null;
        }
      } else {
        print('[DEBUG PROFILE] ❌ Erreur HTTP ${response.statusCode}');
        print('[DEBUG PROFILE] ═══════════════════════════════════════\n');
      }
    } catch (e) {
      print('[DEBUG PROFILE] 💥 EXCEPTION: $e');
      print('[DEBUG PROFILE] ═══════════════════════════════════════\n');
      return null;
    }
    return null;
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