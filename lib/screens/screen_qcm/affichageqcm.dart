import 'package:flutter/material.dart';
import 'package:mobil_cds49/models/questionavecreponse.dart';
import 'package:mobil_cds49/models/reponse.dart';
import 'package:mobil_cds49/screens/screen_qcm/gestionscore.dart';
import 'package:mobil_cds49/screens/screen_qcm/modelaffichagequestion.dart';
import 'package:mobil_cds49/services/api/gestionQuestion/question_api.dart';

//Gestion de l'affichage du QCM

class AffichageQCM extends StatefulWidget {
  final void Function(Widget)? onNavigate;
  final int nbQuestions;
  final String categorieQuestion;
  const AffichageQCM({super.key, required this.nbQuestions, required this.categorieQuestion,this.onNavigate });

  @override
  State<AffichageQCM> createState() => _AffichageQCM();
}

class _AffichageQCM extends State<AffichageQCM> {
  late Future<List<QuestionAvecReponses>> _futureQuestions;
  List<QuestionAvecReponses> _questions = [];
  int _currentIndex = 0;
  int score = 0;
  
  // Initialise la liste des questions à partir de l'API
  @override
  void initState() {
    super.initState();    
    _futureQuestions = QuestionApi().getQuestion(widget.nbQuestions, widget.categorieQuestion); 
  }

  // Charge la prochaine question et vérifie les réponses sélectionnées
  void _chargerProchaineQuestion(List<Reponse> reponsesCochees) {
    final bonnesReponses = _questions[_currentIndex]
      .reponses
      .where((r) => r.valide == 1)
      .toSet();

    final selectionsUtilisateur = reponsesCochees.toSet();
  // Vérifie si toutes les réponses sélectionnées par l'utilisateur sont correctes
    bool toutesBonnes =
        selectionsUtilisateur.length == bonnesReponses.length &&
        selectionsUtilisateur.containsAll(bonnesReponses);

  //SI toutes les réponses sélectionnées sont correctes, on incrémente le score
    if (toutesBonnes) {
      score++;
    }
      
   // Passe à la question suivante ou affiche le score final si c'est la dernière question 
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      widget.onNavigate?.call(
                    GestionScore(
                      key: UniqueKey(),
                      nbQuestionsTotal: widget.nbQuestions,
                      scoreRealise: score,
                    ),
                  );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Affiche un indicateur de chargement pendant que les questions sont récupérées
    return FutureBuilder<List<QuestionAvecReponses>>(
        future: _futureQuestions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucune question disponible"));
          }
     // Si les questions sont chargées, on les stocke dans la variable _questions
          _questions = snapshot.data!;
      // Affiche la question actuelle avec les réponses possibles
          return QuestionWidget(
            questionData: _questions[_currentIndex],            
            onNext: () => _chargerProchaineQuestion([]),
            onNextWithReponses: _chargerProchaineQuestion,
          );
        },
      );
  }
}