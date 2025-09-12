import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobil_cds49/models/questionavecreponse.dart';
import 'package:mobil_cds49/services/api/config.dart';

class QuestionApi {
  
  /// Permet de récupérer les questions d'un QCM
  Future<List<QuestionAvecReponses>> getQuestion(int nbQuestion, String categorieQuestion) async {
      final response = await http.get(Uri.parse('${AppConfig.apiBaseUrl}/api/questions/$nbQuestion?categorie=$categorieQuestion'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> listeQuestions = jsonData['data'];
        return listeQuestions.map((q) => QuestionAvecReponses.fromJson(q)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des questions');
      }
  }

  
}