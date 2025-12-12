import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController ipCtrl = TextEditingController();
  final TextEditingController portCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadIp();
  }

  Future<void> _loadIp() async {
    final prefs = await SharedPreferences.getInstance();

    // Leer una sola variable: "server_ip"
    final full = prefs.getString("server_ip") ?? "";

    if (full.contains(":")) {
      final parts = full.split(":");
      ipCtrl.text = parts[0];
      portCtrl.text = parts.length > 1 ? parts[1] : "";
    } else {
      ipCtrl.text = full;
    }
  }

  Future<void> _saveIp() async {
    final prefs = await SharedPreferences.getInstance();

    // Construir "ip:puerto"
    final ip = ipCtrl.text.trim();
    final port = portCtrl.text.trim();
    final combined = "$ip:$port";

    await prefs.setString("server_ip", combined);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Configuración",
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dirección del Servidor",
              style: TextStyle(color: Colors.white, fontSize: 17),
            ),
            const SizedBox(height: 20),

            // Campo de IP
            _buildInputBox(
              label: "Dirección IP",
              controller: ipCtrl,
              hint: "192.168.1.100",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 18),

            // Campo de Puerto
            _buildInputBox(
              label: "Puerto",
              controller: portCtrl,
              hint: "8080",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 35),

            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _saveIp,
                  child: const Text(
                    "Guardar Cambios",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBox({
    required String label,
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}