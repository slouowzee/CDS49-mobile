import 'package:flutter/material.dart';
import 'package:mobil_cds49/screens/screen_score_qcm/historique_score_qcm.dart';
import 'package:mobil_cds49/services/gestion_token/token.dart';

// Ecran d'accueil de l'application
class Accueil extends StatefulWidget {
  final void Function(Widget)? onNavigate;
  const Accueil({super.key, this.onNavigate});

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {  
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'CDS 49 - Chevrollier Driving School',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 2),
            Image.asset(
              'assets/images/header.jpeg', 
              width: 600,
              height: 550,
            ),
            
            SizedBox(height: 20),
            
            // Bouton visible uniquement si connecté
            FutureBuilder<bool>(
              future: GestionToken.isLogged(),
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoriqueScoreQcm(),
                        ),
                      );
                    },
                    child: const Text('Voir mes scores'),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
    );
  }
}