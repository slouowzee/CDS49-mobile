import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const LatLng autoEcoleLocation = LatLng(47.4739, -0.5554);


class ContactPage extends StatelessWidget {
  const ContactPage({Key? key}) : super(key: key);

  // Fonction pour afficher la boîte de dialogue de confirmation
  Future<void> _confirmAndCall(BuildContext context, String phoneNumber) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Text('Voulez-vous appeler le $phoneNumber ?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Appeler'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (result ?? false) {
      final Uri launchUri = Uri.parse('tel:$phoneNumber');
      try {
        if (!await launchUrl(launchUri, mode: LaunchMode.externalApplication)) {
          throw Exception('Could not launch $launchUri');
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'À propos de nous',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Nouvelle Card pour la description
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'L\'auto-école Chevrollier Driving School 49 (CDS 49) vous accompagne '
                  'dans l\'apprentissage de la conduite. Nous mettons à votre disposition '
                  'des moniteurs expérimentés et une pédagogie adaptée à chacun pour vous '
                  'mener vers la réussite de votre permis de conduire.\n\n'
                  'Que vous soyez débutant ou que vous souhaitiez perfectionner votre '
                  'conduite, nous avons la formule qu\'il vous faut. Rejoignez-nous et '
                  'prenez la route en toute confiance !',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nos coordonnées',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.email),
                      title: Text('Email'),
                      subtitle: Text('contact@cds49.fr'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone),
                      title: const Text('Téléphone'),
                      subtitle: GestureDetector(
                        onTap: () => _confirmAndCall(context, '0241XXXXXX'),
                        child: Text(
                          '02 41 XX XX XX',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text('Adresse'),
                      subtitle: Text('2 Rue Adrien Recouvreur\n49100 Angers\nFrance'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}