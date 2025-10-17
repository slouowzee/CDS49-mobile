import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobil_cds49/models/questionavecreponse.dart';
import 'package:mobil_cds49/services/api/config.dart';

class QuestionApi {
  
  /// Permet de récupérer les questions d'un QCM
  Future<List<QuestionAvecReponses>> getQuestion(int nbQuestion, String categorieQuestion) async {
      print('\n[DEBUG QUESTIONS] ═══════════════════════════════════════');
      print('[DEBUG QUESTIONS] 📝 Récupération des questions');
      print('[DEBUG QUESTIONS] 🔢 Nombre demandé: $nbQuestion');
      print('[DEBUG QUESTIONS] 🏷️ Catégorie: $categorieQuestion');
      print('[DEBUG QUESTIONS] 🌐 URL: ${AppConfig.apiBaseUrl}/api/questions/$nbQuestion?categorie=$categorieQuestion');
      
      final response = await http.get(Uri.parse('${AppConfig.apiBaseUrl}/api/questions/$nbQuestion?categorie=$categorieQuestion'));
      
      print('[DEBUG QUESTIONS] 📥 Status: ${response.statusCode}');
      print('[DEBUG QUESTIONS] 📄 Body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> listeQuestions = jsonData['data'];
        
        print('[DEBUG QUESTIONS] ✅ ${listeQuestions.length} questions récupérées');
        
        if (listeQuestions.isNotEmpty) {
          print('[DEBUG QUESTIONS] 📋 Première question:');
          print('[DEBUG QUESTIONS]    - Question: ${listeQuestions[0]['question']}');
          print('[DEBUG QUESTIONS]    - Nombre de réponses: ${listeQuestions[0]['reponses']?.length ?? 0}');
        }
        
        print('[DEBUG QUESTIONS] ═══════════════════════════════════════\n');
        
        return listeQuestions.map((q) => QuestionAvecReponses.fromJson(q)).toList();
      } else {
        print('[DEBUG QUESTIONS] ❌ Erreur HTTP ${response.statusCode}');
        print('[DEBUG QUESTIONS] ═══════════════════════════════════════\n');
        throw Exception('Erreur lors de la récupération des questions');
      }
  }

  
}