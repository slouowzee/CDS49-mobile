import 'package:flutter/material.dart';
import 'package:mobil_cds49/models/usr.dart';
import 'package:mobil_cds49/services/api/gestionUsr/usr_api.dart';
import 'package:mobil_cds49/services/theme/gestion_theme.dart';


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
    final info = await UsrApi.infoUser();
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
                              Text('Prénom : ${userInfo?.prenomeleve ?? "..." }'),
                              Text('Nom : ${userInfo?.nomeleve ?? "..." }'),
                            ],
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