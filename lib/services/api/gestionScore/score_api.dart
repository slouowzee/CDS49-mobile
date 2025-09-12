import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobil_cds49/services/api/config.dart';
import 'package:mobil_cds49/services/gestion_token/token.dart';

class ScoreApi {
  // Envoie le score et le nombre de questions à l'API
  static Future<int> envoyerScore(int score, int nbQuestions) async {  
  final token = await GestionToken.getToken(); 
  if (token == null || token.isEmpty) {
    return 401; // Non autorisé, utilisateur non connecté ou token manquant (période de session expirée)
  }
  final url = Uri.parse('${AppConfig.apiBaseUrl}/api/fin-test');  
  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'score': score,
        'nbquestions': nbQuestions,
      }),
    );    
    
    return response.statusCode; 
          
    } catch (e) {
      return 500; // Erreur de connexion ou autre problème
    }  
  }
}