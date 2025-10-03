import 'package:flutter/material.dart';
import 'dart:async';

// Widget simple de question avec timer de 20 secondes
class QuestionAvecTimer extends StatefulWidget {
  final String questionTexte;
  final List<String> listeReponses;
  final Function(int?) quandValide; // Appelé quand l'utilisateur valide
  final VoidCallback quandTempsEcoule; // Appelé si le temps est écoulé

  const QuestionAvecTimer({
    required this.questionTexte,
    required this.listeReponses,
    required this.quandValide,
    required this.quandTempsEcoule,
    Key? key,
  }) : super(key: key);

  @override
  State<QuestionAvecTimer> createState() => _QuestionAvecTimerState();
}

class _QuestionAvecTimerState extends State<QuestionAvecTimer> {
  // Variables principales
  int secondes = 20; // Temps restant
  Timer? monTimer; // Le timer
  int? reponseChoisie; // Quelle réponse l'utilisateur a choisie
  bool dejaValide = false; // Pour empêcher de valider 2 fois

  @override
  void initState() {
    super.initState();
    lancerTimer(); // Démarre le timer au démarrage
  }

  // Lance le compte à rebours
  void lancerTimer() {
    monTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (secondes > 0) {
            secondes--; 
          } else {
            tempsEcoule(); 
          }
        });
      }
    });
  }

  // Quand le temps est écoulé
  void tempsEcoule() {
    monTimer?.cancel(); 
    if (!dejaValide) {
      widget.quandTempsEcoule(); // Score = 0
    }
  }

  // Valider une réponse 
  void validerReponse() {
    if (!dejaValide && reponseChoisie != null) {
      dejaValide = true;
      monTimer?.cancel(); 
      widget.quandValide(reponseChoisie); 
    }
  }

  // Couleur qui change selon le temps restant
  Color couleurTimer() {
    if (secondes > 10) return Colors.green;
    if (secondes > 5) return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    monTimer?.cancel(); // Annule le timer au changement de la page 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Question'),
        backgroundColor: Colors.black,
        actions: [
          // Badge du timer en haut à droite
          Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: couleurTimer(),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.timer, color: Colors.white, size: 20),
                SizedBox(width: 6),
                Text(
                  '$secondes s',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de progression colorée
          LinearProgressIndicator(
            value: secondes / 20,
            color: couleurTimer(),
            backgroundColor: Colors.grey[300],
            minHeight: 6,
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 16),

                  // La question
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        widget.questionTexte,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Liste des réponses
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.listeReponses.length,
                      itemBuilder: (context, index) {
                        bool estChoisie = reponseChoisie == index;

                        return Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: dejaValide
                                ? null // Ne peut plus choisir après validation
                                : () {
                                    setState(() {
                                      reponseChoisie = index;
                                    });
                                  },
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: estChoisie
                                    ? Colors.blue.shade100
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: estChoisie
                                      ? Colors.blue
                                      : Colors.grey.shade300,
                                  width: estChoisie ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    estChoisie
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    color: estChoisie
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      widget.listeReponses[index],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: estChoisie
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 16),

                  // Bouton de validation
                  ElevatedButton(
                    onPressed: dejaValide || reponseChoisie == null
                        ? null // Désactivé si déjà validé ou rien de choisi
                        : validerReponse,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(16),
                      backgroundColor: Colors.blue,
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: Text(
                      dejaValide ?  'Valider ma réponse' : 'Valider ma réponse',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

