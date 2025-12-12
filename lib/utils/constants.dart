//const String baseUrl = 'http://XXX.XXX.XXX.XXX:8080'; // U
//const String baseUrl = 'http://XXX.XX.XXX.XXX:8080'; //HOME
/*
Luego en tus servicios deberás reemplazar:
  baseUrl
por:
  await AppConfig.getBaseUrl()
Ejemplo:
  final url = "${await AppConfig.getBaseUrl()}/auth/login";
*/

import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString("server_ip") ?? "";
    return "http://$ip";
  }
}

