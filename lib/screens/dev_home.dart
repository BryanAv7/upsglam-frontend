import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'filter_screen.dart'; // Ajusta la ruta según tu estructura real

class DevHome extends StatelessWidget {
  const DevHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pantalla de desarrollo")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text("Ir a LoginScreen"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FilterScreen()),
                );
              },
              child: const Text("Ir a FilterScreen"),
            ),
          ],
        ),
      ),
    );
  }
}
