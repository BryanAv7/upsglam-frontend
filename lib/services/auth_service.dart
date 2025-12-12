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
    final uri = Uri.parse('${await AppConfig.getBaseUrl()}/auth/register');
    var request = http.MultipartRequest('POST', uri);

    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['displayName'] = username;

    if (image != null) {
      var multipartFile = await http.MultipartFile.fromPath(
        'photo',
        image.path,
      );
      request.files.add(multipartFile);
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(body);
      return {
        "uid": data["uid"]?.toString() ?? '',
        "displayName": data["displayName"] ?? username,
        "photoUrl": data["photoUrl"] ?? '',
        "email": data["email"] ?? email,
      };
    } else {
      throw Exception('Error al registrar: $body');
    }
  }

  // ------------------ Login normal ------------------
  static Future<Map<String, String>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${await AppConfig.getBaseUrl()}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        "uid": data["uid"]?.toString() ?? '',
        "displayName": data["displayName"] ?? email,
        "photoUrl": data["photoUrl"] ?? '',
        "email": data["email"] ?? email,
      };
    } else {
      throw Exception('Error al iniciar sesión: ${response.body}');
    }
  }

  // ------------------ Login con Google ------------------
  static Future<Map<String, String>?> loginWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) return null;

      final GoogleSignInAuthentication auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) throw Exception('No se obtuvo el idToken de Google');

      final response = await http.post(
        Uri.parse('${await AppConfig.getBaseUrl()}/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "uid": data["uid"]?.toString() ?? '',
          "displayName": data["displayName"] ?? account.displayName ?? 'Usuario',
          "photoUrl": data["photoUrl"] ?? '',
          "email": data["email"] ?? account.email,
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
