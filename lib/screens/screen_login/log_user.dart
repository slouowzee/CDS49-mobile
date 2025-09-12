import 'package:flutter/material.dart';
import 'package:mobil_cds49/main.dart';
import 'package:mobil_cds49/services/api/gestionUsr/usr_api.dart';

// Ecran de connexion pour les utilisateurs
class LoginUtilisateur extends StatefulWidget {
  const LoginUtilisateur({super.key});
  @override
  State<LoginUtilisateur> createState() => _LoginUtilisateurState();
}

class _LoginUtilisateurState extends State<LoginUtilisateur> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;

  // Méthode pour gérer la connexion de l'utilisateur
  void _login() async {
    String email = emailController.text;
    String password = passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      final result = await UsrApi().loginUser(email, password);
      // Vérifie que le widget est toujours actif avant d'utiliser context (Bonne pratique pour éviter les erreurs de contexte)
      if (!mounted) return;

      if (result != null && result['user'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Connexion réussie ! Bienvenue ${result['user']['nomeleve']}',
            ),
          ), // Affiche un message de succès
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage(title: 'CDS 49')),
        ); // Réouvre la page d'accueil pour forcer la mise à jour de l'état
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Échec de connexion')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connexion')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Champ de saisie pour l'email
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            // Champ de saisie pour le mot de passe + icone pour afficher/masquer le mot de passe
            TextField(
              controller: passwordController,
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: Text('Se connecter')),
          ],
        ),
      ),
    );
  }
}
