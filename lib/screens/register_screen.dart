import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final userCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool _obscurePassword = true;
  File? _selectedImage;

  // Botones
  bool _loadingNormal = false;
  bool _loadingGoogle = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _register() async {
    setState(() => _loadingNormal = true);

    try {
      final result = await AuthService.register(
        userCtrl.text.trim(),
        emailCtrl.text.trim(),
        passCtrl.text.trim(),
        _selectedImage,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Usuario registrado: ${result["displayName"]}"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _loadingNormal = false);
    }
  }

  Future<void> _registerWithGoogle() async {
    setState(() => _loadingGoogle = true);

    try {
      final result = await AuthService.loginWithGoogle(context);

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Bienvenido: ${result["displayName"]}"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _loadingGoogle = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Registro'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Regístrate en UPSGLAM 2.0',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            // FOTO DE PERFIL
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.grey[800],
                backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                child: _selectedImage == null
                    ? const Icon(Icons.camera_alt, color: Colors.white, size: 32)
                    : null,
              ),
            ),
            const SizedBox(height: 25),

            const Text("Nombre de usuario", style: TextStyle(color: Colors.grey)),
            TextField(
              controller: userCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'User07',
                filled: true,
                fillColor: Colors.grey[850],
              ),
            ),
            const SizedBox(height: 20),

            const Text("Correo", style: TextStyle(color: Colors.grey)),
            TextField(
              controller: emailCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'user@gmail.com',
                filled: true,
                fillColor: Colors.grey[850],
              ),
            ),
            const SizedBox(height: 20),

            const Text("Contraseña", style: TextStyle(color: Colors.grey)),
            TextField(
              controller: passCtrl,
              obscureText: _obscurePassword,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Contraseña',
                filled: true,
                fillColor: Colors.grey[850],
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Botón registro
            ElevatedButton(
              onPressed: _loadingNormal ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _loadingNormal
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text("Registrarse"),
            ),
            const SizedBox(height: 18),

            // Botón registro con Google
            OutlinedButton.icon(
              onPressed: _loadingGoogle ? null : _registerWithGoogle,
              icon: _loadingGoogle
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Icon(Icons.login, color: Colors.white),
              label: Text(
                _loadingGoogle ? 'Iniciando...' : 'Registrarse con Google',
                style: const TextStyle(color: Colors.white),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
