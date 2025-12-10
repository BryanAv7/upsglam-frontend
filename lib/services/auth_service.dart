import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/constants.dart';

class AuthService {
  // ------------------ Registro normal ------------------
  static Future<Map<String, String>> register(
      String username,
      String email,
      String password,
      File? image,
      ) async {
    final uri = Uri.parse('$baseUrl/auth/register');

    var request = http.MultipartRequest('POST', uri);

    // --- Campos ---
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['displayName'] = username;

    print("[register] Enviando registro para email=$email, username=$username");

    // --- Foto ---
    if (image != null) {
      var multipartFile = await http.MultipartFile.fromPath(
        'photo',
        image.path,
      );

      print("[register] Agregando archivo:");
      print("   nombre de archivo: ${multipartFile.filename}");
      print("   content-type: ${multipartFile.contentType}");
      print("   longitud en bytes: ${multipartFile.length}");

      request.files.add(multipartFile);
    } else {
      print("[register] No se envió archivo de foto.");
    }

    // --- Logs ---
    print("[register] Campos enviados:");
    request.fields.forEach((k, v) => print("   $k = $v"));
    print("[register] Cantidad de archivos adjuntos: ${request.files.length}");

    // --- Envío ---
    final response = await request.send();

    print("[register] Status code: ${response.statusCode}");

    final body = await response.stream.bytesToString();
    print("[register] Body recibido: $body");

    if (response.statusCode == 200) {
      final data = jsonDecode(body);
      return {
        "uid": data["uid"]?.toString() ?? '',
        "displayName": data["displayName"] ?? username,
        "photoUrl": data["photoUrl"] ?? '',
      };
    } else {
      throw Exception('Error al registrar: $body');
    }
  }

  // ------------------ Login normal ------------------
  static Future<Map<String, String>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return {
        "uid": data["uid"]?.toString() ?? '',
        "displayName": data["displayName"] ?? email,
        "photoUrl": data["photoUrl"] ?? '',
      };
    } else {
      throw Exception('Error al iniciar sesión: ${response.body}');
    }
  }

  // ------------------ Registro/Login con Google (foto) ------------------
  static Future<Map<String, String>?> loginWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) return null;

      final GoogleSignInAuthentication auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) throw Exception('No se obtuvo el idToken de Google');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      print("[GoogleLogin] Status code: ${response.statusCode}");
      print("[GoogleLogin] Body recibido: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          "uid": data["uid"]?.toString() ?? '',
          "displayName": data["displayName"] ?? account.displayName ?? 'Usuario',
          "photoUrl": data["photoUrl"] ?? '',
        };
      } else {
        throw Exception('Error al iniciar sesión con Google: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
      return null;
    }
  }
}
