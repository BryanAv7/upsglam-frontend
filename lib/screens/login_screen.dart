import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'settings_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _loadingNormal = false;
  bool _loadingGoogle = false;

  String? _savedIp; // Para mostrar advertencias si la IP no está configurada

  @override
  void initState() {
    super.initState();
    _loadSavedIp();
  }

  Future<void> _loadSavedIp() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedIp = prefs.getString("server_ip");
    });
  }

  Future<void> _login() async {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();

    // Verificar IP configurada
    if (_savedIp == null || _savedIp!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Configura la IP del servidor antes de iniciar sesión."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _loadingNormal = true);

    try {
      final result = await AuthService.login(email, pass);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            uid: result["uid"] ?? '',
            displayName: result["displayName"] ?? email,
            photoUrl: result["photoUrl"] ?? '',
            email: result["email"] ?? email,
          ),
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

  Future<void> _loginWithGoogle() async {
    if (_savedIp == null || _savedIp!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Configura la IP del servidor antes de iniciar sesión."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loadingGoogle = true);

    try {
      final result = await AuthService.loginWithGoogle(context);

      if (result != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              uid: result["uid"] ?? '',
              displayName: result["displayName"] ?? 'Usuario',
              photoUrl: result["photoUrl"] ?? '',
              email: result["email"] ?? '',
            ),
          ),
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
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()));
              _loadSavedIp(); // Recargar IP al regresar
            },
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              if (_savedIp == null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "No hay IP configurada. Presiona el botón de configuración.",
                    style: TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ),

              Image.asset('assets/images/logo2f.png',
                  height: 200, width: 200, color: Colors.white),
              const SizedBox(height: 6),
              const Text(
                'UPSGLAM 2.0',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 28),

              const Text('Correo', style: TextStyle(fontSize: 14, color: Colors.grey)),
              TextField(
                controller: emailCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: 'user@gmail.com'),
              ),
              const SizedBox(height: 20),

              const Text('Contraseña', style: TextStyle(fontSize: 14, color: Colors.grey)),
              TextField(
                controller: passCtrl,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  suffixIcon: IconButton(
                    icon: SvgPicture.asset(
                      _obscurePassword ? 'assets/images/eye-blocked.svg'
                          : 'assets/images/eye-icomoon.svg',
                      colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                      width: 24,
                      height: 24,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: _loadingNormal ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _loadingNormal
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text('Ingresar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 14),

              OutlinedButton.icon(
                onPressed: _loadingGoogle ? null : _loginWithGoogle,
                icon: _loadingGoogle
                    ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Image.asset('assets/images/logoGoogle.png',
                    height: 20, width: 20, color: Colors.white, colorBlendMode: BlendMode.srcIn),
                label: Text(
                  _loadingGoogle ? 'Iniciando...' : 'Iniciar sesión con Google',
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF616161)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("¿No tienes una Cuenta? ",
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen())),
                    child: const Text('Registrarte',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
