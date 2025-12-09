import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/constants.dart';

class AuthService {
  // ------------------ Registro normal ------------------
  static Future<String> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'displayName': username,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['displayName'] ?? email;
    } else {
      throw Exception('Error al registrar: ${response.body}');
    }
  }

  // ------------------ Login normal ------------------
  static Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['displayName'] ?? email;
    } else {
      throw Exception('Error al iniciar sesión: ${response.body}');
    }
  }

  // ------------------ Login/Registro con Google ------------------
  static Future<String?> loginWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) return null; // Usuario canceló

      final GoogleSignInAuthentication auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) throw Exception('No se obtuvo el idToken de Google');

      // Enviar idToken al backend
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['displayName'] ?? account.email;
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
