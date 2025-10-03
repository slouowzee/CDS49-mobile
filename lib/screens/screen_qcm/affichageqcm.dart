import 'package:flutter/material.dart';
import 'package:mobil_cds49/models/questionavecreponse.dart';
import 'package:mobil_cds49/models/reponse.dart';
import 'package:mobil_cds49/screens/screen_qcm/gestionscore.dart';
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
  
  // Variables pour le timer
  Timer? _timer;
  int _secondesRestantes = 20; // RÈGLE 2 & 3: 20 secondes par question
  bool _reponseValidee = false;
  
  @override
  void initState() {
    super.initState();    
    _futureQuestions = QuestionApi().getQuestion(
      widget.nbQuestions, 
      widget.categorieQuestion
    );
  }

  // Démarre le timer quand les questions sont chargées
  void _demarrerTimer() {
    _timer?.cancel(); // Annule le timer précédent si existant
    _secondesRestantes = 20; // RÈGLE 3: Timer démarre à 20 secondes
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
          content: Text(' Temps écoulé ! Aucun point pour cette question.'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      // Passe à la question suivante sans incrémenter le score
      _passerQuestionSuivante();
    }
  }

  // Charge la prochaine question et vérifie les réponses sélectionnées
  void _chargerProchaineQuestion(List<Reponse> reponsesCochees) {
    // RÈGLE 4: Seules les réponses VALIDÉES sont prises en compte
    if (_reponseValidee) return; // Empêche la double validation
    
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

    // SI toutes les réponses sélectionnées sont correctes, on incrémente le score
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

  Color _getCouleurTimer() {
    if (_secondesRestantes > 10) {
      return Colors.green;
    } else if (_secondesRestantes > 5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
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
              color: _getCouleurTimer().withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                      color: _getCouleurTimer(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.alarm, 
                          color: Colors.white, 
                          size: 20
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$_secondesRestantes s',
                          style: const TextStyle(
                            color: Colors.white,
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
              backgroundColor: Colors.grey[300],
              color: _getCouleurTimer(),
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