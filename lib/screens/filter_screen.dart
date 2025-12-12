import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../services/filter_service.dart';
import '../models/filter_config_model.dart';
import '../services/post_service.dart';

class FilterScreen extends StatefulWidget {
  final File imageFile;
  final String uid;
  final VoidCallback onComplete;

  const FilterScreen({
    super.key,
    required this.imageFile,
    required this.uid,
    required this.onComplete,
  });

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  Uint8List? _processedImageBytes;
  late FilterService _filterService;

  bool _loading = false;
  String filtroSeleccionado = "sobel";
  Map<String, double> valoresActuales = {};

  @override
  void initState() {
    super.initState();
    _filterService = FilterService();
    valoresActuales =
    Map<String, double>.from(FilterConfig.valoresDefecto[filtroSeleccionado]!);
  }

  void _setMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _sendImage() async {
    setState(() => _loading = true);

    final (bytes, _) = await _filterService.procesarImagen(
      imagen: widget.imageFile,
      filtro: filtroSeleccionado,
      parametros: valoresActuales,
    );

    setState(() {
      _loading = false;
      _processedImageBytes = bytes;
    });
  }

  Future<void> _publishFilter() async {
    try {
      _setMessage("Subiendo imagen...");

      File toUpload;

      if (_processedImageBytes != null) {
        final tempPath = "${Directory.systemTemp.path}/processed_image.png";
        final file = File(tempPath);
        await file.writeAsBytes(_processedImageBytes!);
        toUpload = file;
      } else {
        toUpload = widget.imageFile;
      }

      await PostService.uploadPost(
        filePath: toUpload.path,
        caption: "Mi nueva publicación",
        userUid: widget.uid,
      );

      _setMessage("Imagen publicada con éxito.");
      widget.onComplete();

    } catch (e) {
      _setMessage("Error al publicar: $e");
    }
  }

  Widget _buildParametros() {
    final params = FilterConfig.filtrosParametros[filtroSeleccionado]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Parámetros: $filtroSeleccionado",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        for (var param in params)
          Column(
            children: [
              Text(
                "$param: ${valoresActuales[param]!.toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.white),
              ),
              Slider(
                value: valoresActuales[param]!,
                min: FilterConfig.rangosParametros[filtroSeleccionado]![param]![0],
                max: FilterConfig.rangosParametros[filtroSeleccionado]![param]![1],
                onChanged: (value) {
                  setState(() {
                    valoresActuales[param] = value;
                  });
                },
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildFiltroCarousel() {
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: FilterConfig.filtros.map((f) {
          final activo = f == filtroSeleccionado;

          return GestureDetector(
            onTap: () {
              setState(() {
                filtroSeleccionado = f;
                valoresActuales =
                Map<String, double>.from(FilterConfig.valoresDefecto[f]!);
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: activo ? Colors.blue : Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  f,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: activo ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showResult = _processedImageBytes != null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                const SizedBox(height: 10),

                Container(
                  height: 260,
                  alignment: Alignment.center,
                  child: showResult
                      ? Image.memory(_processedImageBytes!)
                      : Image.file(widget.imageFile),
                ),

                const SizedBox(height: 20),

                _buildFiltroCarousel(),

                const SizedBox(height: 20),

                _buildParametros(),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _loading ? null : _sendImage,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Procesar imagen"),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _publishFilter,
                  child: const Text("Publicar"),
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),

          // BOTÓN FLOTANTE "X" (CANCELAR)
          Positioned(
            top: 20,
            left: 10,
            child: GestureDetector(
              onTap: widget.onComplete,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
