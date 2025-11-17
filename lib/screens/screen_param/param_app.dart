import 'package:flutter/material.dart';
import 'package:mobil_cds49/models/usr.dart';
import 'package:mobil_cds49/services/api/gestionUsr/usr_api.dart';
import 'package:mobil_cds49/services/theme/gestion_theme.dart';
import 'package:mobil_cds49/screens/screen_documents/mes_documents.dart';


// Ecran de paramètres de l'application
class ParamApp extends StatefulWidget {
  const ParamApp({super.key});

  @override
  State<ParamApp> createState() => _ParamAppState();
}

class _ParamAppState extends State<ParamApp> {
  bool light = false; // Variable pour le thème clair
  User? userInfo;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    print('[PARAM_APP] 🔄 Chargement des infos utilisateur...');
    final info = await UsrApi.infoUser();
    print('[PARAM_APP] 📦 Info reçue: $info');
    if (info != null) {
      print('[PARAM_APP] ✅ ID: ${info.ideleve}');
      print('[PARAM_APP] ✅ Nom: ${info.nomeleve}');
      print('[PARAM_APP] ✅ Prénom: ${info.prenomeleve}');
      print('[PARAM_APP] ✅ Email: ${info.emaileleve}');
    } else {
      print('[PARAM_APP] ❌ Info est NULL');
    }
    setState(() {
      userInfo = info;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: <Widget>[          
          Expanded(
            child: ListView(
              children: [ 
                 Card(
                  margin: EdgeInsets.all(12),
                  child: 
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                        Text(light ? 'Passer en mode clair' : 'Passer en mode sombre',
                        style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),),
                        SizedBox(height: 8),
                        Center(
                          child : Switch(
                            value: light, 
                            onChanged: (bool value) {
                              setState(() {
                                light = value;
                              });
                              // Appelle le contrôleur de thème pour changer le thème
                              themeController.toggleTheme();
                            },
                          ),
                        ),
                    ],
                    ),
                  ),
                ),      

                Card(
                  margin: EdgeInsets.all(12),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: isLoading
                        ? Center(child: CircularProgressIndicator())
                        : userInfo == null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_off,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Non connecté',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Connectez-vous pour voir vos informations',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Informations utilisateur',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text('ID : ${userInfo!.ideleve}'),
                                  Text('Prénom : ${userInfo!.prenomeleve ?? "Non renseigné"}'),
                                  Text('Nom : ${userInfo!.nomeleve ?? "Non renseigné"}'),
                                  Text('Email : ${userInfo!.emaileleve ?? "Non renseigné"}'),
                                  Text('Date de naissance : ${userInfo!.datenaissanceeleve ?? "Non renseigné"}'),
                                ],
                              ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.all(12),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MesDocuments(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.folder_open,
                            size: 32,
                            color: Colors.orange,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mes documents',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Gérer mes documents administratifs',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
