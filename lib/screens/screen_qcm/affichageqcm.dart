import 'package:flutter/material.dart';
import 'package:mobil_cds49/models/questionavecreponse.dart';
import 'package:mobil_cds49/models/reponse.dart';
import 'package:mobil_cds49/screens/screen_qcm/gestionscore.dart';
import 'package:mobil_cds49/screens/screen_qcm/gestionqcm.dart';
import 'package:mobil_cds49/screens/screen_qcm/modelaffichagequestion.dart';
import 'package:mobil_cds49/services/api/gestionQuestion/question_api.dart';
import 'dart:async';

//Gestion de l'affichage du QCM avec timer

class AffichageQCM extends StatefulWidget {
  final void Function(Widget)? onNavigate;
  final int nbQuestions;
  final String categorieQuestion;
  const AffichageQCM({
    super.key, 
    required this.nbQuestions, 
    required this.categorieQuestion,
    this.onNavigate 
  });

  @override
  State<AffichageQCM> createState() => _AffichageQCM();
}

class _AffichageQCM extends State<AffichageQCM> {
  late Future<List<QuestionAvecReponses>> _futureQuestions;
  List<QuestionAvecReponses> _questions = [];
  int _currentIndex = 0;
  int score = 0;
  

  Timer? _timer;
  int _secondesRestantes = 20; 
  bool _reponseValidee = false;
  
  @override
  void initState() {
    super.initState();    
    _futureQuestions = QuestionApi().getQuestion( 
      widget.nbQuestions, 
      widget.categorieQuestion
    ); // recupere les questions depuis l'API
  }

 
  void _demarrerTimer() {
    _timer?.cancel(); // enleve un timer s'il yen a un
    _secondesRestantes = 20; 
    _reponseValidee = false;
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondesRestantes > 0) {
            _secondesRestantes--;
          } else {
            _gererTimeout();
          }
        });
      }
    });
  }

  // RÈGLE 1: Timeout = score 0 pour cette question
  void _gererTimeout() {
    _timer?.cancel();
    if (!_reponseValidee) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('  Aucun point pour cette question.'),
          duration: Duration(seconds: 2),
        ),
      );
      // Passe à la question suivante sans incrémenter le score
      _passerQuestionSuivante();
    }
  }

  // Gere la validation d'une reponse et de passer à celle d'apres
  void _chargerProchaineQuestion(List<Reponse> reponsesCochees) {
    // Prend en compte les réponses cochées par l'utilisateur
    if (_reponseValidee) return;

    _reponseValidee = true;
    _timer?.cancel(); // Arrête le timer après validation

    final bonnesReponses = _questions[_currentIndex]
      .reponses
      .where((r) => r.valide == 1)
      .toSet();

    final selectionsUtilisateur = reponsesCochees.toSet();
    
    // Vérifie si toutes les réponses sélectionnées par l'utilisateur sont correctes
    bool toutesBonnes =
        selectionsUtilisateur.length == bonnesReponses.length &&
        selectionsUtilisateur.containsAll(bonnesReponses);

    if (toutesBonnes) {
      score++;
    }
    
    _passerQuestionSuivante();
  }

  void _passerQuestionSuivante() {
    // Passe à la question suivante ou affiche le score final si c'est la dernière question 
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _demarrerTimer(); // Redémarre le timer pour la nouvelle question
      });
    } else {
      _timer?.cancel();
      widget.onNavigate?.call(
        GestionScore(
          key: UniqueKey(),
          nbQuestionsTotal: widget.nbQuestions,
          scoreRealise: score,
        ),
      );
    }
  }



  // Méthode pour annuler le quiz et revenir à la sélection
  void _annulerQuiz() {
    _timer?.cancel();
    
    // Afficher une boîte de dialogue de confirmation
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Annuler le quiz'),
          content: const Text('Êtes-vous sûr de vouloir abandonner ce quiz ?\nVotre progression sera perdue.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la dialogue
              },
              child: const Text('Non'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la dialogue
                // Retour à l'écran de sélection du QCM
                widget.onNavigate?.call(
                  CodeQCM(onNavigate: widget.onNavigate),
                );
              },
              child: const Text(
                'Oui, annuler',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        if (_questions.isEmpty) {
          _questions = snapshot.data!;
          // Démarre le timer pour la première question
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _demarrerTimer();
          });
        }
        
        // Affiche la question actuelle avec le timer
        return Column(
          children: [
            // TIMER WIDGET - Affichage du temps restant
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Bouton d'annulation
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: _annulerQuiz,
                    tooltip: 'Annuler le quiz',
                  ),
                  
                  Text(
                    'Question ${_currentIndex + 1} / ${_questions.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, 
                      vertical: 8
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.alarm, 
                          color: Colors.black, 
                          size: 20
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$_secondesRestantes s',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Barre de progression du timer
            LinearProgressIndicator(
              value: _secondesRestantes / 20,
              backgroundColor: Colors.black,
              minHeight: 4,
            ),
            
            // Question actuelle
            Expanded(
              child: QuestionWidget(
                key: ValueKey(_currentIndex), // Important pour réinitialiser l'état
                questionData: _questions[_currentIndex],            
                onNext: () => _chargerProchaineQuestion([]),
                onNextWithReponses: _chargerProchaineQuestion,
              ),
            ),
          ],
        );
      },
    );
  }
} 