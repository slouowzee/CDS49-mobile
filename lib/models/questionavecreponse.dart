import 'package:mobil_cds49/models/question.dart';
import 'package:mobil_cds49/models/reponse.dart';

// dataclasse permettant de représenter une question avec ses réponses
class QuestionAvecReponses {
  final Question question;
  final List<Reponse> reponses;

  QuestionAvecReponses({required this.question, required this.reponses});

// factory pour créer une instance de QuestionAvecReponses à partir d'un JSON
    factory QuestionAvecReponses.fromJson(Map<String, dynamic> json) {
    final rawReponses = json['reponses'];       
    return QuestionAvecReponses(
      question: Question.fromJson(json['question']),
      reponses: rawReponses != null
          ? List<Reponse>.from(rawReponses.map((x) => Reponse.fromJson(x)))
          : [],
    );
  }
}