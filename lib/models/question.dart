// dataclasse permettant de représenter une question

class Question {
  final int id;
  final String libelle;
  final String image;

  Question({required this.id, required this.libelle, required this.image});

  // factory pour créer une instance de Question à partir d'un JSON
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['idquestion'],
      libelle: json['libellequestion'],
      image: json['imagequestion'],
    );
  }
}