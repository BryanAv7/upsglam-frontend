import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
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
  bool loading = false;

  // Control para mostrar/ocultar contraseña
  bool _obscurePassword = true;

  Future<void> _register() async {
    setState(() => loading = true);
    try {
      final username = await AuthService.register(
        userCtrl.text.trim(),
        emailCtrl.text.trim(),
        passCtrl.text.trim(),
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
      setState(() => loading = false);
    }
  }

  Future<void> _registerWithGoogle() async {
    setState(() => loading = true);
    try {
      final displayName = await AuthService.loginWithGoogle(context);
      if (displayName != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("¡Bienvenido, $displayName!"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      // El error ya se maneja dentro de AuthService
    } finally {
      setState(() => loading = false);
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
      body: SafeArea(
        child: SingleChildScrollView(
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

              const Text('Nombre de usuario', style: TextStyle(color: Colors.grey, fontSize: 14)),
              TextField(
                controller: userCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'User07',
                  hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                  filled: true,
                  fillColor: Colors.grey[850],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text('Correo', style: TextStyle(color: Colors.grey, fontSize: 14)),
              TextField(
                controller: emailCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'user@gmail.com',
                  hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                  filled: true,
                  fillColor: Colors.grey[850],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text('Contraseña', style: TextStyle(color: Colors.grey, fontSize: 14)),
              TextField(
                controller: passCtrl,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                  filled: true,
                  fillColor: Colors.grey[850],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  suffixIcon: IconButton(
                    icon: SvgPicture.asset(
                      _obscurePassword
                          ? 'assets/images/eye-blocked.svg'
                          : 'assets/images/eye-icomoon.svg',
                      colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                      width: 24,
                      height: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: loading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text("Registrarse", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 18),

              OutlinedButton.icon(
                onPressed: loading ? null : _registerWithGoogle,
                icon: Image.asset(
                  'assets/images/logoGoogle.png',
                  height: 20,
                  width: 20,
                  color: Colors.white,
                  colorBlendMode: BlendMode.srcIn,
                ),
                label: const Text('Registrarse con Google', style: TextStyle(color: Colors.white, fontSize: 15)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF616161)),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
