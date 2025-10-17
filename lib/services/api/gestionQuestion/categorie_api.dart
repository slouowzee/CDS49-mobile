import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobil_cds49/models/categoriequestion.dart';
import 'package:mobil_cds49/services/api/config.dart';

class CategorieApi {
  
  /// Permet de récupérer toutes les catégories de questions
  /// Méthode alignée sur celle de QuestionApi pour la cohérence
  Future<List<CategorieQuestion>> getCategories() async {
    print('\n[DEBUG CATEGORIES] ═══════════════════════════════════════');
    print('[DEBUG CATEGORIES] 📚 Récupération des catégories');
    print('[DEBUG CATEGORIES] 🌐 URL: ${AppConfig.apiBaseUrl}/api/categorie');
    
    final response = await http.get(Uri.parse('${AppConfig.apiBaseUrl}/api/categorie'));
    
    print('[DEBUG CATEGORIES] 📥 Status: ${response.statusCode}');
    print('[DEBUG CATEGORIES] 📄 Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      print('[DEBUG CATEGORIES] 📦 JSON décodé: $jsonData');
      
      final List<dynamic> listeCategories = jsonData['data'];
      print('[DEBUG CATEGORIES] 📋 Liste catégories: $listeCategories');
      print('[DEBUG CATEGORIES] 🔢 Nombre de catégories: ${listeCategories.length}');
      
      final categories = listeCategories.map((c) {
        print('[DEBUG CATEGORIES] 🔍 Parsing catégorie brute: $c');
        final cat = CategorieQuestion.fromJson(c);
        print('[DEBUG CATEGORIES] ✅ Catégorie créée: ID=${cat.idcategorie}, Nom=${cat.nomcategorie}');
        return cat;
      }).toList();
      
      print('[DEBUG CATEGORIES] ✅ ${categories.length} catégories chargées');
      print('[DEBUG CATEGORIES] ═══════════════════════════════════════\n');
      return categories;
    } else {
      print('[DEBUG CATEGORIES] ❌ Erreur HTTP ${response.statusCode}');
      print('[DEBUG CATEGORIES] ═══════════════════════════════════════\n');
      throw Exception('Erreur lors de la récupération des catégories');
    }
  }
}
