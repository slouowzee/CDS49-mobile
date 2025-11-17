import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mobil_cds49/models/demande_document.dart';
import 'package:mobil_cds49/services/api/config.dart';
import 'package:mobil_cds49/services/gestion_token/token.dart';
import 'package:path/path.dart' as path;

/// Service API pour la gestion des documents
class DocumentApi {
  
  /// Récupère les demandes de documents pour l'élève connecté
  Future<List<DemandeDocument>> getDemandesDocuments() async {
    print('\n[DEBUG DOCUMENTS] ═══════════════════════════════════════');
    print('[DEBUG DOCUMENTS] 📄 Récupération des demandes de documents');
    
    final token = await GestionToken.getToken();
    if (token == null) {
      print('[DEBUG DOCUMENTS] ❌ Pas de token disponible');
      throw Exception('Non authentifié');
    }

    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/api/eleve/demandes-documents'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('[DEBUG DOCUMENTS] 📥 Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> listeDemandes = jsonData['data'] ?? [];
      
      print('[DEBUG DOCUMENTS] ✅ ${listeDemandes.length} demandes récupérées');
      print('[DEBUG DOCUMENTS] ═══════════════════════════════════════\n');
      
      return listeDemandes.map((d) => DemandeDocument.fromJson(d)).toList();
    } else {
      print('[DEBUG DOCUMENTS] ❌ Erreur HTTP ${response.statusCode}');
      print('[DEBUG DOCUMENTS] ═══════════════════════════════════════\n');
      throw Exception('Erreur lors de la récupération des demandes');
    }
  }

  /// Téléverse un document pour une demande
  Future<bool> televerserDocument(int idDemande, File fichier) async {
    print('\n[DEBUG DOCUMENTS] ═══════════════════════════════════════');
    print('[DEBUG DOCUMENTS] 📤 Téléversement d\'un document');
    print('[DEBUG DOCUMENTS] 🆔 ID Demande: $idDemande');
    print('[DEBUG DOCUMENTS] 📁 Fichier: ${path.basename(fichier.path)}');
    
    final token = await GestionToken.getToken();
    if (token == null) {
      print('[DEBUG DOCUMENTS] ❌ Pas de token disponible');
      throw Exception('Non authentifié');
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConfig.apiBaseUrl}/api/eleve/demandes-documents/$idDemande/televerser'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath(
      'document',
      fichier.path,
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('[DEBUG DOCUMENTS] 📥 Status: ${response.statusCode}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('[DEBUG DOCUMENTS] ✅ Document téléversé avec succès');
      print('[DEBUG DOCUMENTS] ═══════════════════════════════════════\n');
      return true;
    } else {
      print('[DEBUG DOCUMENTS] ❌ Erreur HTTP ${response.statusCode}');
      print('[DEBUG DOCUMENTS] Body: ${response.body}');
      print('[DEBUG DOCUMENTS] ═══════════════════════════════════════\n');
      return false;
    }
  }
}
