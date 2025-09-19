import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:json_theme/json_theme.dart';
import 'package:mobil_cds49/screens/screen_login/log_user.dart';
import 'package:mobil_cds49/screens/screen_contact/contact.dart';
import 'package:mobil_cds49/services/api/config.dart';
import 'package:mobil_cds49/services/gestion_token/token.dart';
import 'package:mobil_cds49/services/theme/generer_theme.dart';
import 'package:mobil_cds49/services/theme/gestion_theme.dart';
import 'package:mobil_cds49/screens/screen_accueil/accueil.dart';
import 'package:mobil_cds49/screens/screen_param/param_app.dart';
import 'package:mobil_cds49/screens/screen_qcm/gestionqcm.dart';
import 'package:mobil_cds49/widgets/app_bar.dart';
import 'package:mobil_cds49/widgets/bottom_bar.dart';



void main() async {
  // Lancement de l'application
  WidgetsFlutterBinding.ensureInitialized();  
  // Masquer la barre de statut (Enlève l'heure, la batterie, etc...) 
  // Plein écran
   // Appel pour lire les fichier .env spécifique Android Studio qui ne sais pas les lire directement
  await AppConfig.load();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // Chargement des thèmes avant de lancer l'application  
  // await <Methode pour consulter le thème préféré de l'utilisateur>; 
  // pour éviter les erreurs de thème non chargé
  List<ThemeData> listtheme = await loadDataBeforeRunningApp();
  ThemeData lightTheme = listtheme[0];
  ThemeData darkTheme = listtheme[1];   
  runApp(MyApp(lightTheme: lightTheme, darkTheme: darkTheme));
}

//chargement des thèmes
Future<List<ThemeData>> loadDataBeforeRunningApp() async {
  // Chargement des thèmes à partir des fichiers JSON
  final lightThemeStr =await rootBundle.loadString('assets/theme/cds49_light.json');
  final darkThemeStr = await rootBundle.loadString('assets/theme/cds49_night.json');
  // Vérification que les fichiers JSON sont valides
  final lightThemeJson = jsonDecode(lightThemeStr);
  final darkThemeJson = jsonDecode(darkThemeStr);
  // Utilisation de json_theme KO depuis la denière mise à jour Flutter 
  /*final lightTheme = ThemeDecoder.decodeThemeData(lightThemeJson,validate: true)!;
  final darkTheme = ThemeDecoder.decodeThemeData(darkThemeJson,validate: true)!;*/
  
  // Décodage des thèmes à partir des fichiers JSON en manuel
  final lightTheme = GenererTheme.buildThemeFromJson(lightThemeJson);
  final darkTheme = GenererTheme.buildThemeFromJson(darkThemeJson);

  return [lightTheme, darkTheme];
}

class MyApp extends StatelessWidget {
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  // Constructeur de la classe MyApp
  const MyApp({super.key, required this.lightTheme, required this.darkTheme});

  
  
  @override
  // Méthode de construction de l'application
  Widget build(BuildContext context) {
    // Utilisation de ValueListenableBuilder pour écouter les changements de thème
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController,
      // Construction de MaterialApp avec le thème approprié
      builder: (context, themeMode, _) {
        return MaterialApp(
      title: 'CDS 49',     
      debugShowMaterialGrid: false,
      debugShowCheckedModeBanner: false,
      // Application des thèmes clair et sombre
      theme: lightTheme,
      darkTheme: darkTheme,
      // Application du thème en fonction du mode
      themeMode: themeMode,
      home: const MyHomePage(title: 'CDS 49'),          
        );
    },
   );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  // Création de l'état pour la page d'accueil
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Index de la page actuelle pour la navigation
  int currentPageIndex = 0;    
  Widget? currentBody;

  @override
  void initState() {
    super.initState();
    currentBody = Accueil(onNavigate: afficherNouvellePage);
  }

  void afficherNouvellePage(Widget nouvellePage) {
    setState(() {
      currentBody = nouvellePage;
    });
  }
  // Méthode pour empecher d'aller vers la page QCM si l'utilisateur n'est pas connecté
   Future<void> _onDestinationSelected(int index) async {
    if (index == 1) {
      final autorise = await GestionToken.isLogged();
      if (!autorise && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez vous connecter pour accéder au QCM')),
        );
        return;
      }
    }
  // Mise à jour du corps de la page
    setState(() {
      currentPageIndex = index;
      switch (index) {
        case 0:
          currentBody = Accueil(onNavigate: afficherNouvellePage);
          break;
        case 1:
          currentBody = CodeQCM(onNavigate: afficherNouvellePage);
          break;
        case 2:
          currentBody = const ParamApp();
          break;
        case 3:
          currentBody = const ContactPage();
        default:
          currentBody = const Center(child: Text('Page introuvable'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Construction de la page d'accueil avec une AppBar, un Body et une barre de navbar
    return Scaffold(
      // Appel de l'AppBar personnalisée
      appBar: AppBarPrincipal(
        actions: <Widget>[
          FutureBuilder<bool>(
            future: GestionToken.isLogged(),
            builder: (context, snapshot) {
              // Empêche un affichage temporaire
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(); 
              }
              // Affiche le bouton de déconnexion si l'utilisateur est connecté
              if (snapshot.data == true) {
                return IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    GestionToken.logout();
                    setState(() {});
                  },
                ); 
              }
              // Affiche le bouton de connexion si l'utilisateur n'est pas connecté
              return IconButton(
                icon: const Icon(Icons.perm_identity),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginUtilisateur()),
                  );
                },
              );
            },
          ),
        ],
      ),
      // Affichage du corps de la page
      body:  SafeArea(
                child: currentBody ?? const Center(child: Text('Page introuvable')),
              ),
      // Appel de la barre de navigation en bas personnalisée
      bottomNavigationBar: BottomNavbar(
        currentIndex: currentPageIndex,
        onDestinationSelected: _onDestinationSelected,
      ),       
    );
  }
}
