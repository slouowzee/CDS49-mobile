import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobil_cds49/services/api/config.dart';
import 'package:mobil_cds49/services/gestion_token/token.dart';

class ScoreApi {
  // Envoie le score et le nombre de questions à l'API
  static Future<int> envoyerScore(int score, int nbQuestions) async {  
  print('[SCORE_API] 💾 Envoi du score: $score/$nbQuestions');
  final token = await GestionToken.getToken();
  print('[SCORE_API] 🔑 Token récupéré: ${token != null ? "✅ (${token.length} caractères)" : "❌ NULL"}');
  
  if (token == null || token.isEmpty) {
    print('[SCORE_API] ❌ Token manquant');
    return 401; // Non autorisé, utilisateur non connecté ou token manquant (période de session expirée)
  }
  final url = Uri.parse('${AppConfig.apiBaseUrl}/api/scores/set');
  print('[SCORE_API] 🌐 URL: $url');
  print('[SCORE_API] 📤 Headers: Authorization: Bearer ${token.substring(0, 8)}...');
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
    
    print('[SCORE_API] 📡 Status: ${response.statusCode}');
    print('[SCORE_API] 📦 Body: ${response.body}');
    return response.statusCode; 
          
    } catch (e) {
      print('[SCORE_API] ❌ Erreur: $e');
      return 500; // Erreur de connexion ou autre problème
    }  
  }
}