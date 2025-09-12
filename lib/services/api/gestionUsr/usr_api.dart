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
        final userJson = jsonBody['data']['user'];
        return User.fromJson(userJson);
      }
    } catch (e) {
      return null; // Erreur réponse serveur
    }
    return null; // Non autorisé, utilisateur non connecté ou token manquant (période de session expirée)
  }
}