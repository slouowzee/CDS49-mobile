import 'package:flutter/material.dart';
import 'package:mobil_cds49/services/gestion_token/token.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onDestinationSelected;

  const BottomNavbar({
    required this.currentIndex,
    required this.onDestinationSelected,
    Key? key,
  }) : super(key: key);
  // Empeche l'utilisateur de naviguer vers le QCM s'il n'est pas connecté
  Future<void> _verifQCM(BuildContext context, int index) async {
    if (index == 1) {
      final autorise = await GestionToken.isLogged();
      if (!autorise && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez vous connecter pour accéder au QCM')),
        );
        return;
      }
    }
    onDestinationSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    // Construction de la barre de navigation 
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => _verifQCM(context, index),
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home),
          label: 'Accueil',
        ),
        NavigationDestination(
          icon: Icon(Icons.quiz),
          label: 'QCM',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings),
          label: 'Paramètres',
        ),
        NavigationDestination(
          icon: Icon(Icons.contact_page), 
          label: 'Nous contacter',
        ),

        NavigationDestination (
          icon: Icon(Icons.app_registration), 
          label: 'Inscription', 
        ),
      ],
    );
  }
}