// Modèle pour une demande de document faite par l'administration à un élève

class DemandeDocument {
  final int id;
  final String nomDocument;
  final String statut; // "demande", "en_attente_validation", "valide", "refuse"
  final String? motifRefus;
  final String? cheminFichier;
  final DateTime dateCreation;
  final DateTime? dateTelechargement;
  final DateTime? dateValidation;

  DemandeDocument({
    required this.id,
    required this.nomDocument,
    required this.statut,
    this.motifRefus,
    this.cheminFichier,
    required this.dateCreation,
    this.dateTelechargement,
    this.dateValidation,
  });

  // Factory pour créer une instance depuis JSON
  factory DemandeDocument.fromJson(Map<String, dynamic> json) {
    return DemandeDocument(
      id: json['id'] ?? json['iddemandedocument'] ?? 0,
      nomDocument: json['nomdocument'] ?? json['nom_document'] ?? '',
      statut: json['statut'] ?? 'demande',
      motifRefus: json['motifrefus'] ?? json['motif_refus'],
      cheminFichier: json['cheminfichier'] ?? json['chemin_fichier'],
      dateCreation: json['datecreation'] != null
          ? DateTime.parse(json['datecreation'])
          : DateTime.now(),
      dateTelechargement: json['datetelechargement'] != null
          ? DateTime.parse(json['datetelechargement'])
          : null,
      dateValidation: json['datevalidation'] != null
          ? DateTime.parse(json['datevalidation'])
          : null,
    );
  }

  // Méthode pour obtenir le libellé du statut
  String get libelleStatut {
    switch (statut.toLowerCase()) {
      case 'demande':
        return 'Demandé';
      case 'en_attente_validation':
        return 'En attente de validation';
      case 'valide':
        return 'Validé';
      case 'refuse':
        return 'Refusé';
      default:
        return statut;
    }
  }

  // Méthode pour obtenir la couleur du statut
  String get couleurStatut {
    switch (statut.toLowerCase()) {
      case 'demande':
        return 'orange';
      case 'en_attente_validation':
        return 'blue';
      case 'valide':
        return 'green';
      case 'refuse':
        return 'red';
      default:
        return 'grey';
    }
  }

  // Vérifie si l'élève peut téléverser un document
  bool get peutTeleverser {
    return statut.toLowerCase() == 'demande' || 
           statut.toLowerCase() == 'refuse';
  }
}
