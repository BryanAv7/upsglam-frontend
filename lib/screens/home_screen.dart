import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/post_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String uid;
  final String displayName;
  final String photoUrl;
  final String email;

  const HomeScreen({
    super.key,
    required this.uid,
    required this.displayName,
    required this.photoUrl,
    required this.email,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _message = '';
  final ImagePicker _picker = ImagePicker();
  bool showProfile = false;

  File? _selectedImage;
  bool showFilterButtons = false;

  void _setMessage(String text) => setState(() => _message = text);

  void _navigateToHome() {
    setState(() {
      showProfile = false;
      showFilterButtons = false;
      _selectedImage = null;
      _message = '';
    });
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        showFilterButtons = true;
      });
    }
  }

  void _cancelImageSelection() {
    setState(() {
      _selectedImage = null;
      showFilterButtons = false;
      _message = '';
    });
  }

  Future<void> _publishFilter() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay imagen seleccionada.'), backgroundColor: Colors.red),
      );
      return;
    }

    _setMessage("Subiendo imagen...");

    try {
      await PostService.uploadPost(
        filePath: _selectedImage!.path,
        caption: "Mi nueva publicación",
        userUid: widget.uid,
      );

      // Notificación
      final successMessage = "¡Imagen subida con éxito!";
      print(successMessage); // 👈 en consola
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage), backgroundColor: Colors.green),
      );

      // Limpiar y volver al home
      setState(() {
        _selectedImage = null;
        showFilterButtons = false;
        _message = '';
      });
      Future.delayed(const Duration(milliseconds: 800), _navigateToHome);

    } catch (e) {
      final errorMessage = "Error al subir: $e";
      print(errorMessage); // Prueba de consola
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
      _setMessage("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                border: Border(bottom: BorderSide(color: Colors.grey.shade800)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      '➥ Bienvenido, ${widget.displayName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: showProfile
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: widget.photoUrl.isNotEmpty
                            ? NetworkImage(widget.photoUrl)
                            : null,
                        child: widget.photoUrl.isEmpty
                            ? const Icon(Icons.person, size: 50, color: Colors.white)
                            : null,
                        backgroundColor: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Información Personal',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Nombre:', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Center(child: Text(widget.displayName, style: const TextStyle(color: Colors.white, fontSize: 16))),
                    const Divider(color: Colors.grey, height: 24, thickness: 0.5),
                    const Text('Correo electrónico:', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Center(child: Text(widget.email, style: const TextStyle(color: Colors.white, fontSize: 16))),
                    const Divider(color: Colors.grey, height: 24, thickness: 0.5),
                    const SizedBox(height: 16),
                    const Center(child: Text('Publicaciones realizadas', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                    const SizedBox(height: 8),
                    const Center(child: Text('(vacío)', style: TextStyle(color: Colors.grey, fontSize: 16))),
                  ],
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_selectedImage != null)
                      Image.file(_selectedImage!, height: 200),
                    if (showFilterButtons) ...[
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Aplicar filtro
                            },
                            child: const Text('Aplicar Filtro'),
                          ),
                          ElevatedButton(
                            onPressed: _publishFilter,
                            child: const Text('Publicar Filtro'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _cancelImageSelection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                          minimumSize: const Size(180, 40),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ] else if (_message.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          _message,
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      const Center(
                        child: Text(
                          'Contenido principal aquí',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              height: 60,
              color: Colors.grey[900],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home, color: Colors.white),
                    onPressed: _navigateToHome,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.white, size: 32),
                    onPressed: pickImage,
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_outline, color: Colors.white),
                    onPressed: () => setState(() {
                      showProfile = true;
                      showFilterButtons = false;
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}