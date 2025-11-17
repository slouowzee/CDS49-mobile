import 'package:flutter/material.dart';
import 'package:mobil_cds49/models/demande_document.dart';
import 'package:mobil_cds49/services/api/gestionDocument/document_api.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

/// Écran de gestion des documents pour l'élève
class MesDocuments extends StatefulWidget {
  const MesDocuments({super.key});

  @override
  State<MesDocuments> createState() => _MesDocumentsState();
}

class _MesDocumentsState extends State<MesDocuments> {
  final DocumentApi _documentApi = DocumentApi();
  bool _isLoading = true;
  List<DemandeDocument> _demandesDocuments = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _chargerDocuments();
  }

  Future<void> _chargerDocuments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final demandes = await _documentApi.getDemandesDocuments();
      
      setState(() {
        _demandesDocuments = demandes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des documents: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _televerserDocument(DemandeDocument demande) async {
    try {
      // Ouvre le sélecteur de fichiers
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        
        // Affiche un indicateur de chargement
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // Envoie le fichier
        final success = await _documentApi.televerserDocument(demande.id, file);
        
        if (!mounted) return;
        Navigator.pop(context); // Ferme le dialog de chargement

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document téléversé avec succès !'),
              backgroundColor: Colors.green,
            ),
          );
          _chargerDocuments(); // Recharge les documents
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors du téléversement'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getStatutColor(String couleur) {
    switch (couleur) {
      case 'orange':
        return Colors.orange;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _chargerDocuments,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _chargerDocuments,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _chargerDocuments,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Section: Mes documents à fournir
                      _buildSectionTitle('Mes documents à fournir', Icons.upload_file),
                      const SizedBox(height: 8),
                      if (_demandesDocuments.isEmpty)
                        _buildEmptyCard('Aucun document à fournir pour le moment')
                      else
                        ..._demandesDocuments.map((demande) => _buildDemandeCard(demande)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCard(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            message,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ),
    );
  }

  Widget _buildDemandeCard(DemandeDocument demande) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    demande.nomDocument,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatutColor(demande.couleurStatut),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    demande.libelleStatut,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Demandé le: ${_formatDate(demande.dateCreation)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            
            // Affiche le motif de refus si le document est refusé
            if (demande.statut.toLowerCase() == 'refuse' && demande.motifRefus != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Motif du refus:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      demande.motifRefus!,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
            
            // Bouton téléverser si l'élève peut téléverser
            if (demande.peutTeleverser) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _televerserDocument(demande),
                  icon: const Icon(Icons.upload),
                  label: Text(
                    demande.statut.toLowerCase() == 'refuse' 
                        ? 'Téléverser un nouveau document'
                        : 'Téléverser',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
