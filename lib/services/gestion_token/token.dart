
import 'package:shared_preferences/shared_preferences.dart';
//classe pour la gestion du token de l'utilisateur stocké dans les préférences partagées de l'appareil android
class GestionToken
{

 //Permet de récupérer le token de l'utilisateur et de le sauver dans les préférences partagées
 static Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_token', token);
  }

//permet de savoir si l'utilisateur est connecté en vérifiant si le token existe 
  static Future<bool> isLogged() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token') != null; // Vérifie si le token existe
  }

//Permet de ce déloger de l'utilisateur en supprimant le token
  static Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('auth_token'); 
  }

//permet de récupérer le token de l'utilisateur
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); 
  }
}