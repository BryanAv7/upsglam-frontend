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

  void _setMessage(String text) => setState(() => _message = text);

  Future<void> pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      _setMessage("No seleccionaste ninguna imagen.");
      return;
    }

    _setMessage("Subiendo imagen...");

    try {
      await PostService.uploadPost(
        filePath: image.path,
        caption: "Mi nueva publicación",
        userUid: widget.uid,
      );
      _setMessage("¡Imagen subida con éxito!");
    } catch (e) {
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
                  // CircleAvatar(
                  //   radius: 20,
                  //   backgroundImage: widget.photoUrl.isNotEmpty
                  //       ? NetworkImage(widget.photoUrl)
                  //       : null,
                  //   child: widget.photoUrl.isEmpty
                  //       ? const Icon(Icons.person, color: Colors.white)
                  //       : null,
                  //   backgroundColor: Colors.grey[700],
                  // ),
                  const SizedBox(width: 12),
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    const Text(
                      'Nombre:',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        widget.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Divider(color: Colors.grey, height: 24, thickness: 0.5),
                    const Text(
                      'Correo electrónico:',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        widget.email,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Divider(color: Colors.grey, height: 24, thickness: 0.5),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Publicaciones realizadas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        '(vacío)',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                )
                    : _message.isNotEmpty
                    ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    _message,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                )
                    : const Center(
                  child: Text(
                    'Contenido principal aquí',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
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
                    onPressed: () => setState(() {
                      showProfile = false;
                      _setMessage('');
                    }),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.white, size: 32),
                    onPressed: pickAndUploadImage,
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_outline, color: Colors.white),
                    onPressed: () => setState(() {
                      showProfile = true;
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