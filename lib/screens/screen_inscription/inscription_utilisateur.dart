import 'package:flutter/material.dart';
import 'package:mobil_cds49/screens/screen_login/log_user.dart';


class PageInscription extends StatelessWidget {
  const PageInscription({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription Utilisateur'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField (
              decoration: InputDecoration(
                labelText: 'Nom ',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField (
              decoration: InputDecoration(
                labelText: 'Prénom ',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20), 
            // Champ de saisie pour l'email
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            // Champ de saisie pour le mot de passe
            TextField(
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Confirmer le mot de passe',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),

            SizedBox(height: 20),
            TextField( 
              decoration: InputDecoration(
                labelText: 'Date de naissance',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
            )
            ,
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () { // méthode pour inscrire
                
              },
              child: Text('S\'inscrire'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigue vers l'écran de connexion si l'utilisateur est déjà inscrit
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginUtilisateur()),
                );
              },
              child: Text('Déjà inscrit ? Connectez-vous'),
              ),
            ],
        ),
      ),
    );
  }
}

