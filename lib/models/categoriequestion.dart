class CategorieQuestion {
  final int idcategorie;
  final String nomcategorie;

  CategorieQuestion({required this.idcategorie, required this.nomcategorie});

  factory CategorieQuestion.fromJson(Map<String, dynamic> json) {
    // Support de plusieurs formats de noms de champs
    final id = json['IDCatQuestion'] ?? 
               json['idcategorie'] ?? 
               json['id'] ?? 
               json['idCatQuestion'] ?? 
               0;
               
    final nom = json['LibCatQuestion'] ?? 
                json['nomcategorie'] ?? 
                json['nom'] ?? 
                json['libelle'] ?? 
                json['libCatQuestion'] ??
                'Catégorie inconnue';
    
    return CategorieQuestion(
      idcategorie: id is int ? id : int.tryParse(id.toString()) ?? 0,
      nomcategorie: nom.toString(),
    );
  }
  
  @override
  String toString() {
    return 'CategorieQuestion(id: $idcategorie, nom: $nomcategorie)';
  }
}