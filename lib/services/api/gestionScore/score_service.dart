import 'dart:convert';
import 'package:mobil_cds49/services/api/config.dart';
import 'package:http/http.dart' as http;
import 'package:mobil_cds49/models/score_response.dart';
import 'package:mobil_cds49/services/gestion_token/token.dart';

class ScoreService {
  static String get baseUrl => '${AppConfig.apiBaseUrl}/api';

  // Récupérer le token depuis le stockage local
  static Future<String?> _getToken() async {
    return await GestionToken.getToken();
  }

  // Récupérer tous les scores avec statistiques
  static Future<ScoreResponse> getScores({
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    print('[SCORE_SERVICE] 🔄 Récupération des scores...');
    final token = await _getToken();
    if (token == null) {
      print('[SCORE_SERVICE] ❌ Token non disponible');
      throw Exception('Token non disponible');
    }

    String url = '$baseUrl/scores';
    
    // Ajouter les paramètres de filtre si fournis
    if (dateDebut != null && dateFin != null) {
      final debut = dateDebut.toIso8601String().split('T').join(' ').substring(0, 19);
      final fin = dateFin.toIso8601String().split('T').join(' ').substring(0, 19);
      url += '?date_debut=$debut&date_fin=$fin';
      print('[SCORE_SERVICE] 📅 Filtre: $debut → $fin');
    }

    print('[SCORE_SERVICE] 🌐 URL: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('[SCORE_SERVICE] 📡 Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print('[SCORE_SERVICE] 📦 Response: ${jsonData['status']}');
      
      if (jsonData['status'] == 'success') {
        print('[SCORE_SERVICE] ✅ ${jsonData['data']['scores'].length} scores récupérés');
        return ScoreResponse.fromJson(jsonData['data']);
      } else {
        print('[SCORE_SERVICE] ❌ Erreur: ${jsonData['message']}');
        throw Exception(jsonData['message'] ?? 'Erreur inconnue');
      }
    } else {
      print('[SCORE_SERVICE] ❌ Erreur serveur: ${response.statusCode}');
      throw Exception('Erreur serveur: ${response.statusCode}');
    }
  }

  // Sauvegarder un score
  static Future<bool> saveScore(int score, int nbquestions) async {
    print('[SCORE_SERVICE] 💾 Sauvegarde du score: $score/$nbquestions');
    final token = await _getToken();
    if (token == null) {
      print('[SCORE_SERVICE] ❌ Token non disponible');
      throw Exception('Token non disponible');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/fin-test'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'score': score,
        'nbquestions': nbquestions,
      }),
    );

    print('[SCORE_SERVICE] 📡 Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print('[SCORE_SERVICE] ✅ Sauvegarde: ${jsonData['status']}');
      return jsonData['status'] == 'success';
    }
    
    print('[SCORE_SERVICE] ❌ Échec de la sauvegarde');
    return false;
  }
}
