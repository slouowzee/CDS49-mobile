import 'package:flutter/material.dart';
import 'package:mobil_cds49/main.dart';
import 'package:mobil_cds49/services/api/gestionScore/score_api.dart';

// Ecran affichant le score de l'utilisateur après un QCM

class GestionScore extends StatefulWidget {
  final int nbQuestionsTotal;
  final int scoreRealise;
  const GestionScore({super.key, required this.nbQuestionsTotal, required this.scoreRealise});

  @override
  State<GestionScore> createState() => _GestionScoreState();
}

class _GestionScoreState extends State<GestionScore> {

// Apelle l'API pour envoyer le score et navigue vers la page d'accueil
void _envoyerScoreEtNaviguer() async {
  final statusCode = await ScoreApi.envoyerScore(
    widget.scoreRealise,
    widget.nbQuestionsTotal,
  );

 // Vérifie si le widget est monté avant de naviguer 
  if (!mounted) return;

  if (statusCode == 200) {
    // Change le body pour afficher la page d'accueil
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => MyHomePage(title: 'CDS 49'), 
      ),
    );
  } else {
    // Affiche un message d'erreur si l'envoi du score échoue
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Erreur lors de l'envoi du score")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Votre score est de : ${widget.scoreRealise} / ${widget.nbQuestionsTotal}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Appelle la méthode pour envoyer le score et naviguer vers l'accueil
              _envoyerScoreEtNaviguer() ;
            },
            child: const Text('Retour à l\'accueil'),
          ),
        ],
      ),
    );
  }
}