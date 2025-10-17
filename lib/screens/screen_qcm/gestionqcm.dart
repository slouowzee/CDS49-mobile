import 'package:flutter/material.dart';
import 'package:mobil_cds49/screens/screen_qcm/affichageqcm.dart';
import 'package:mobil_cds49/models/categoriequestion.dart';
import 'package:mobil_cds49/services/api/gestionQuestion/categorie_api.dart';

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
  
  // Liste des catégories récupérées depuis la BDD
  List<CategorieQuestion> categories = [];
  
  // Instance de l'API pour récupérer les catégories
  final CategorieApi _categorieApi = CategorieApi();
  
  // État de chargement
  bool isLoading = true;
  
  // Message d'erreur
  String? errorMessage;
  
  // Liste des valeurs pour la dropdown de sélection du nombre de questions
  final dropdownValues = [0, 10, 20, 30, 40];
  late final List<DropdownMenuItem<int>> dropdownItems;
  late List<DropdownMenuItem<String>> dropdownCategorieItems;

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
    
    // Initialiser avec une catégorie par défaut
    dropdownCategorieItems = [
      const DropdownMenuItem<String>(
        value: 'random',
        child: Text('Aléatoire'),
      ),
    ];
    
    // Charger les catégories depuis la BDD
    _loadCategories();
  }
  
  // Méthode pour charger les catégories depuis la BDD
  Future<void> _loadCategories() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      
      final loadedCategories = await _categorieApi.getCategories();
      
      setState(() {
        categories = loadedCategories;
        // Créer les items du dropdown avec la catégorie "Aléatoire" + les catégories de la BDD
        dropdownCategorieItems = [
          const DropdownMenuItem<String>(
            value: 'random',
            child: Text('Aléatoire'),
          ),
          ...loadedCategories.map((cat) => DropdownMenuItem<String>(
                value: cat.idcategorie.toString(),
                child: Text(cat.nomcategorie),
              )),
        ];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur lors du chargement des catégories: $e';
      });
    }
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
            
            // Gestion de la catégorie
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Catégorie de questions',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Afficher un indicateur de chargement si les catégories sont en cours de chargement
                    if (isLoading)
                      const CircularProgressIndicator()
                    // Afficher un message d'erreur si une erreur est survenue
                    else if (errorMessage != null)
                      Column(
                        children: [
                          Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _loadCategories,
                            child: const Text('Réessayer'),
                          ),
                        ],
                      )
                    // Afficher le dropdown des catégories
                    else
                      DropdownButton<String>(
                        value: selectedCategorie,
                        items: dropdownCategorieItems,
                        onChanged: (value) {
                          setState(() {
                            selectedCategorie = value!;
                          });
                        },
                        isExpanded: true,
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Bouton pour valider la sélection et naviguer vers l'écran de QCM
            ElevatedButton(
              onPressed: isLoading ? null : () {
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