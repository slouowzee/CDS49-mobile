import 'package:flutter/material.dart';

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
          ],
        ),
    );
  }
}