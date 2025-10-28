class Score {
  final int idresultat;
  final DateTime dateresultat;
  final int score;
  final int nbquestions;

  Score({
    required this.idresultat,
    required this.dateresultat,
    required this.score,
    required this.nbquestions,
  });

  // Calcul du score en pourcentage
  double get percentage => (score / nbquestions) * 100;

  // Calcul de la note sur 40
  double get scoreSur40 => (score / nbquestions) * 40;

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      idresultat: json['idresultat'] ?? 0,
      dateresultat: DateTime.parse(json['dateresultat']),
      score: json['score'],
      nbquestions: json['nbquestions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idresultat': idresultat,
      'dateresultat': dateresultat.toIso8601String(),
      'score': score,
      'nbquestions': nbquestions,
    };
  }

  // Pour le cache SQLite local
  Map<String, dynamic> toMap() {
    return {
      'idresultat': idresultat,
      'dateresultat': dateresultat.toIso8601String(),
      'score': score,
      'nbquestions': nbquestions,
    };
  }

  factory Score.fromMap(Map<String, dynamic> map) {
    return Score(
      idresultat: map['idresultat'],
      dateresultat: DateTime.parse(map['dateresultat']),
      score: map['score'],
      nbquestions: map['nbquestions'],
    );
  }
}
