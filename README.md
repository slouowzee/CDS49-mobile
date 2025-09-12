# mobil_cds49 
Ce dépôt contient le code source de l’application mobile CDS 49, développée pour l’auto-école Chevrollier Driving School.
Il s’agit d’une solution applicative qui permet principalement de s'entrainer via différentes questions au code de la route. 

## Contenu du projet 
- Le code source de l'application mobile

## Quelques conseils 
Une fois le projet cloné via le lien. 
Lancer votre éditeur de code avec flutter et dart à jour puis lancez la commande : 

```bash flutter pub get ``` 

Pour lancer l'application en mode dev vous pouvez utiliser la commande suivante : 

```bash flutter run --dart-define-from-file=env.dev.json ```

En cas d'erreur, vérifier le bon fonctionnement de Flutter sur votre poste vous pouvez executer la commande suivante dans une console :

```bash flutter doctor ``` 

## Technologies 
- [Flutter](https://flutter.dev/)
- [Dart](https://dart.dev/)
  
## Packages utilisés 
- [json_theme](https://pub.dev/packages/json_theme) Thème via fichier Json
- [http](https://pub.dev/packages/http) Requête Http pour l'accès API
- [shared_preferences](https://pub.dev/packages/shared_preferences) Stockage local des préférences
- [font_awesome_flutter](https://pub.dev/packages/font_awesome_flutter) Icônes
- [flutter_map](https://pub.dev/packages/flutter_map) Affichage cartes
- [latlong2](https://pub.dev/packages/latlong2) Gestion des coordonées géographiques

## Note
Ce projet est réalisé à des fins pédagogiques
