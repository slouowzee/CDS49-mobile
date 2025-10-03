import 'package:flutter/material.dart';
import 'package:mobil_cds49/screens/screen_qcm/affichageqcm.dart';
import 'package:mobil_cds49/widgets/categorie_question.dart';

// Ecran permettant de sélectionner le nombre de questions et la catégorie pour un QCM
class CodeQCM extends StatefulWidget {
  final void Function(Widget)? onNavigate;
  const CodeQCM({super.key, this.onNavigate});

  @override
  State<CodeQCM> createState() => _CodeQCMState();
}

class _CodeQCMState extends State<CodeQCM> {
  // Nombre de questions par défaut 
  int selectedNumber = 40;
  
  // Catégorie sélectionnée (par défaut: aléatoire)
  String selectedCategorie = 'random';
  
  // Liste des catégories disponibles
  final List<Map<String, dynamic>> categories = [
    {'nom': 'Aléatoire', 'id': 'random'},
    {'nom': 'Code de la route', 'id': '1'},
    {'nom': 'Signalisation', 'id': '2'},
    {'nom': 'Priorités', 'id': '3'},
    {'nom': 'Stationnement', 'id': '4'},
  ];
  
  // Liste des valeurs pour la dropdown de sélection du nombre de questions
  final dropdownValues = [0, 10, 20, 30, 40];
  late final List<DropdownMenuItem<int>> dropdownItems;

  // Initialise la liste des dropdown items à partir des valeurs définies
  @override
  void initState() {
    super.initState();
    dropdownItems = dropdownValues
        .map((value) => DropdownMenuItem<int>(
              value: value,
              child: Text('$value'),
            ))
        .toList();   
  }
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              'Chevrollier Driving School',
              style: TextStyle(
                fontSize: 22,                  
              ),
            ),
            
            // Gestion du nombre de questions 
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [ 
                    const Text(
                      'Nombre de questions',
                      style: TextStyle(
                        fontSize: 18,                  
                      ),
                    ),
                    DropdownButton<int>(
                      value: selectedNumber,
                      items: dropdownItems,
                      // Affiche la valeur sélectionnée par l'utilisateur
                      onChanged: (value) {
                        setState(() {
                          selectedNumber = value!;
                        });
                      },
                      isExpanded: true,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Titre de la section catégories
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Sélectionnez une catégorie',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Affichage de toutes les catégories avec votre widget
            ...categories.map((cat) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: CategorieQuestion(
                  categorie: cat['nom'],
                  nombreQuestions: selectedNumber,
                  onSelect: () {
                    setState(() {
                      selectedCategorie = cat['id'];
                    });
                    // Message de confirmation
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Catégorie "${cat['nom']}" sélectionnée'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
            
            const SizedBox(height: 24),
            
            // Affichage de la catégorie actuellement sélectionnée
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle),
                  const SizedBox(width: 8),
                  Text(
                    'Catégorie sélectionnée : ${categories.firstWhere((c) => c['id'] == selectedCategorie)['nom']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Bouton pour valider la sélection et naviguer vers l'écran de QCM
            ElevatedButton(
              onPressed: () {
                widget.onNavigate?.call(
                  AffichageQCM(
                    key: UniqueKey(),
                    nbQuestions: selectedNumber,
                    categorieQuestion: selectedCategorie,
                    onNavigate: widget.onNavigate,
                  ),
                );
              },
              child: const Text('Valider'),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}