import 'package:flutter/material.dart';
import 'package:mobil_cds49/main.dart';
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
  
  // Variables pour les messages d'erreur
  String? nomError;
  String? prenomError;
  String? emailError;
  String? telephoneError;
  String? passwordError;
  String? confirmPasswordError;
  String? dateNaissanceError;

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

  // Méthode pour valider le téléphone français
  bool _isValidPhoneFR(String phone) {
    // Format accepté: 0123456789 ou 01 23 45 67 89 ou 01.23.45.67.89 ou +33123456789
    final phoneClean = phone.replaceAll(RegExp(r'[\s\.\-]'), '');
    return RegExp(r'^(0[1-9]\d{8}|(\+33|0033)[1-9]\d{8})$').hasMatch(phoneClean);
  }

  // Méthode pour inscrire l'utilisateur
  Future<void> _register() async {
    // Réinitialiser les erreurs
    setState(() {
      nomError = null;
      prenomError = null;
      emailError = null;
      telephoneError = null;
      passwordError = null;
      confirmPasswordError = null;
      dateNaissanceError = null;
    });

    final nom = nomController.text.trim();
    final prenom = prenomController.text.trim();
    final email = emailController.text.trim();
    final telephone = telephoneController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    final dateNaissance = dateNaissanceController.text;

    bool hasError = false;

    // Validations avec messages d'erreur
    if (nom.isEmpty) {
      setState(() => nomError = 'Le nom est obligatoire');
      hasError = true;
    }

    if (prenom.isEmpty) {
      setState(() => prenomError = 'Le prénom est obligatoire');
      hasError = true;
    }

    if (email.isEmpty) {
      setState(() => emailError = 'L\'email est obligatoire');
      hasError = true;
    } else if (!_isValidEmail(email)) {
      setState(() => emailError = 'Email invalide');
      hasError = true;
    }

    // Validation du téléphone (facultatif mais si renseigné doit être valide)
    if (telephone.isNotEmpty && !_isValidPhoneFR(telephone)) {
      setState(() => telephoneError = 'Format de téléphone invalide (ex: 0612345678)');
      hasError = true;
    }

    // Nettoyer le téléphone (enlever espaces, points, tirets) avant envoi
    // Envoyer chaîne vide si non renseigné (pour compatibilité PHP strict)
    final telephoneToSend = telephone.isEmpty 
        ? "" 
        : telephone.replaceAll(RegExp(r'[\s\.\-]'), '');

    if (password.isEmpty) {
      setState(() => passwordError = 'Le mot de passe est obligatoire');
      hasError = true;
    } else if (password.length < 12) {
      setState(() => passwordError = 'Le mot de passe doit contenir au moins 12 caractères');
      hasError = true;
    }

    if (confirmPassword.isEmpty) {
      setState(() => confirmPasswordError = 'Confirmez votre mot de passe');
      hasError = true;
    } else if (password != confirmPassword) {
      setState(() => confirmPasswordError = 'Les mots de passe ne correspondent pas');
      hasError = true;
    }

    if (dateNaissance.isEmpty) {
      setState(() => dateNaissanceError = 'La date de naissance est obligatoire');
      hasError = true;
    }

    if (hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez corriger les erreurs dans le formulaire'),
          backgroundColor: Colors.red,
        ),
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
      telephone: telephoneToSend,
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
      // Redirection vers la page principale
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage(title: 'CDS 49')),
        (route) => false,
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
            TextField(
              controller: nomController,
              decoration: InputDecoration(
                labelText: 'Nom *',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
                errorText: nomError,
                errorStyle: TextStyle(color: Colors.red),
              ),
              onChanged: (value) {
                if (nomError != null) {
                  setState(() => nomError = value.isEmpty ? 'Le nom est obligatoire' : null);
                }
              },
            ),
            SizedBox(height: 20),
            TextField(
              controller: prenomController,
              decoration: InputDecoration(
                labelText: 'Prénom *',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
                errorText: prenomError,
                errorStyle: TextStyle(color: Colors.red),
              ),
              onChanged: (value) {
                if (prenomError != null) {
                  setState(() => prenomError = value.isEmpty ? 'Le prénom est obligatoire' : null);
                }
              },
            ),
            SizedBox(height: 20),
            // Champ de saisie pour l'email
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email *',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
                errorText: emailError,
                errorStyle: TextStyle(color: Colors.red),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                if (emailError != null) {
                  if (value.isEmpty) {
                    setState(() => emailError = 'L\'email est obligatoire');
                  } else if (!_isValidEmail(value)) {
                    setState(() => emailError = 'Email invalide');
                  } else {
                    setState(() => emailError = null);
                  }
                }
              },
            ),
            SizedBox(height: 20),
            // Champ de saisie pour le numéro de téléphone (FACULTATIF)
            TextField(
              controller: telephoneController,
              decoration: InputDecoration(
                labelText: 'Numéro de téléphone (facultatif)',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
                helperText: 'Ce champ est facultatif',
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            // Champ de saisie pour le mot de passe
            TextField(
              controller: passwordController,
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Mot de passe *',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
                errorText: passwordError,
                errorStyle: TextStyle(color: Colors.red),
                helperText: 'Minimum 12 caractères',
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
              onChanged: (value) {
                if (passwordError != null) {
                  if (value.isEmpty) {
                    setState(() => passwordError = 'Le mot de passe est obligatoire');
                  } else if (value.length < 12) {
                    setState(() => passwordError = 'Le mot de passe doit contenir au moins 12 caractères');
                  } else {
                    setState(() => passwordError = null);
                  }
                }
              },
            ),
            SizedBox(height: 20),

            TextField(
              controller: confirmPasswordController,
              obscureText: !isConfirmPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Confirmer le mot de passe *',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
                errorText: confirmPasswordError,
                errorStyle: TextStyle(color: Colors.red),
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
              onChanged: (value) {
                if (confirmPasswordError != null) {
                  if (value.isEmpty) {
                    setState(() => confirmPasswordError = 'Confirmez votre mot de passe');
                  } else if (value != passwordController.text) {
                    setState(() => confirmPasswordError = 'Les mots de passe ne correspondent pas');
                  } else {
                    setState(() => confirmPasswordError = null);
                  }
                }
              },
            ),

            SizedBox(height: 20),
            TextField(
              controller: dateNaissanceController,
              decoration: InputDecoration(
                labelText: 'Date de naissance *',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
                errorText: dateNaissanceError,
                errorStyle: TextStyle(color: Colors.red),
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
            SizedBox(height: 10),
            Text(
              '* Champs obligatoires',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
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
            SizedBox(height: 10),
            TextButton.icon(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage(title: 'CDS 49')),
                  (route) => false,
                );
              },
              icon: Icon(Icons.home),
              label: Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }
}