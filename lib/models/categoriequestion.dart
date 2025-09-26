class CategorieQuestion {
  final int idcategorie;
  final String nomcategorie;

  CategorieQuestion({required this.idcategorie, required this.nomcategorie});

  factory CategorieQuestion.fromJson(Map<String, dynamic> json) {
    return CategorieQuestion(
      idcategorie: json['id'],
      nomcategorie: json['nom'],
    );
  }
}