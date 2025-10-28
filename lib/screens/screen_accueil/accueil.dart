import 'package:flutter/material.dart';
import 'package:mobil_cds49/screens/screen_historique/score_history_screen.dart';
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
            
            // Carte pour accéder à l'historique des scores
            Card(
              elevation: 4,
              child: InkWell(
                onTap: () async {
                  final isLogged = await GestionToken.isLogged();
                  if (!isLogged && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Veuillez vous connecter pour voir votre historique'),
                      ),
                    );
                    return;
                  }
                  
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScoreHistoryScreen(),
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.history, size: 48, color: Colors.blue),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Historique des scores',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Consultez tous vos résultats de QCM',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }
}