import 'package:flutter/material.dart';
import 'package:mobil_cds49/screens/screen_login/log_user.dart';
import 'package:mobil_cds49/services/api/gestionUsr/usr_api.dart';


class PageInscription extends StatefulWidget {
  const PageInscription({super.key});

  @override
  State<PageInscription> createState() => _PageInscriptionState();
}

class _PageInscriptionState extends State<PageInscription> {
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telephoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController dateNaissanceController = TextEditingController();
  
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isLoading = false;

  // Méthode pour sélectionner la date de naissance
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        // Format: YYYY-MM-DD pour la base de données
        dateNaissanceController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // Méthode pour valider l'email
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Méthode pour inscrire l'utilisateur
  Future<void> _register() async {
    final nom = nomController.text.trim();
    final prenom = prenomController.text.trim();
    final email = emailController.text.trim();
    final telephone = telephoneController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    final dateNaissance = dateNaissanceController.text;

    // Validations
    if (nom.isEmpty || prenom.isEmpty || email.isEmpty || telephone.isEmpty || password.isEmpty || dateNaissance.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email invalide')),
      );
      return;
    }

    if (password.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le mot de passe doit contenir au moins 10 caractères')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Appel à l'API d'inscription (le hash bcrypt sera fait côté serveur)
    final result = await UsrApi().registerUser(
      nom: nom,
      prenom: prenom,
      email: email,
      telephone: telephone,
      password: password,
      dateNaissance: dateNaissance,
    );

    setState(() {
      isLoading = false;
    });

    if (!mounted) return;

    if (result != null && result['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inscription réussie ! Bienvenue $prenom $nom'),
          backgroundColor: Colors.green,
        ),
      );
      // Redirection vers la page de connexion
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginUtilisateur()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result?['message'] ?? 'Échec de l\'inscription'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    emailController.dispose();
    telephoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    dateNaissanceController.dispose();
    super.dispose();
  }

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
              controller: nomController,
              decoration: InputDecoration(
                labelText: 'Nom ',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField (
              controller: prenomController,
              decoration: InputDecoration(
                labelText: 'Prénom ',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
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
            // Champ de saisie pour le numéro de téléphone
            TextField(
              controller: telephoneController,
              decoration: InputDecoration(
                labelText: 'Numéro de téléphone',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            // Champ de saisie pour le mot de passe
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

            TextField(
              controller: confirmPasswordController,
              obscureText: !isConfirmPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Confirmer le mot de passe',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      isConfirmPasswordVisible = !isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
            ),

            SizedBox(height: 20),
            TextField( 
              controller: dateNaissanceController,
              decoration: InputDecoration(
                labelText: 'Date de naissance',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
            )
            ,
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _register,
              child: isLoading 
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('S\'inscrire'),
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