import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'login_screen.dart';
import 'filter_screen.dart';  // <<< IMPORTANTE

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
  final ImagePicker _picker = ImagePicker();

  // Vista actual: "home" | "perfil" | "filter"
  String currentView = "home";

  // Imagen seleccionada que se enviará a FilterScreen
  File? selectedImage;

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
        currentView = "filter";    // Abre FilterScreen en el área central
      });
    }
  }

  Widget _buildMainView() {
    switch (currentView) {
      case "perfil":
        return _buildProfileView();
      case "filter":
        return FilterScreen(
          imageFile: selectedImage!,
          uid: widget.uid,
          onComplete: () {
            setState(() {
              currentView = "home";
              selectedImage = null;
            });
          },
        );

      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return const Center(
      child: Text(
        'Contenido principal aquí',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  Widget _buildProfileView() {
    return Column(
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
        const Center(
          child: Text(
            'Información Personal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Nombre:',
            style: TextStyle(color: Colors.grey, fontSize: 16)),
        const SizedBox(height: 8),
        Center(
            child: Text(widget.displayName,
                style: const TextStyle(color: Colors.white, fontSize: 16))),
        const Divider(color: Colors.grey, height: 24),
        const Text('Correo electrónico:',
            style: TextStyle(color: Colors.grey, fontSize: 16)),
        const SizedBox(height: 8),
        Center(
            child: Text(widget.email,
                style: const TextStyle(color: Colors.white, fontSize: 16))),
        const Divider(color: Colors.grey, height: 24),
        const SizedBox(height: 16),
        const Center(
            child: Text('Publicaciones realizadas',
                style: TextStyle(color: Colors.white, fontSize: 18))),
        const SizedBox(height: 8),
        const Center(
            child: Text('(vacío)',
                style: TextStyle(color: Colors.grey, fontSize: 16))),
      ],
    );
  }

  void _goHome() {
    setState(() {
      currentView = "home";
      selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Barra superior
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                border:
                Border(bottom: BorderSide(color: Colors.grey.shade800)),
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

            // Vista dinámica
            Expanded(
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: _buildMainView(),
              ),
            ),

            // Barra inferior
            Container(
              height: 60,
              color: Colors.grey[900],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home, color: Colors.white),
                    onPressed: _goHome,
                  ),
                  IconButton(
                    icon:
                    const Icon(Icons.add_circle, color: Colors.white, size: 32),
                    onPressed: pickImage,
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_outline, color: Colors.white),
                    onPressed: () => setState(() {
                      currentView = "perfil";
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
