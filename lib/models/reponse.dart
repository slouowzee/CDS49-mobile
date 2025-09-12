// dataclasse permettant de représenter une réponse 

class Reponse {
  final int idQuestion;
  final int numReponse;
  final String libelle;
  final int valide;

  Reponse({required this.idQuestion, required this.numReponse, required this.libelle, required this.valide});

// factory pour créer une instance de Reponse à partir d'un JSON
  factory Reponse.fromJson(Map<String, dynamic> json) {
    return Reponse(
      idQuestion: json['idquestion'],
      numReponse: json['numreponse'],
      libelle: json['libellereponse'],
      valide: json['valide'],
    );
  }
}