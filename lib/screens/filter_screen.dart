import 'dart:async';
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

  // <<< CAMBIO: filtro por defecto ahora es “ninguno”
  String filtroSeleccionado = "ninguno";

  Map<String, double> valoresActuales = {};
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _filterService = FilterService();

    _cargarValoresIniciales();

    // <<< CAMBIO: solo dispara auto-procesado si NO es “ninguno”
    if (filtroSeleccionado != "ninguno") {
      _triggerProcessing();
    }
  }

  void _cargarValoresIniciales() {
    if (filtroSeleccionado == "ninguno") {
      valoresActuales = {};
      return;
    }

    final defaults = FilterConfig.valoresDefecto[filtroSeleccionado];
    valoresActuales = defaults != null
        ? Map<String, double>.from(defaults)
        : {};
  }

  void _setMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ---------------------------------------------------------
  // DEBOUNCE
  // ---------------------------------------------------------
  void _triggerProcessing() {
    if (filtroSeleccionado == "ninguno") return; // <<< CAMBIO

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _sendImage();
    });
  }

  // ---------------------------------------------------------
  // PROCESAR IMAGEN
  // ---------------------------------------------------------
  Future<void> _sendImage() async {
    if (filtroSeleccionado == "ninguno") return; // <<< CAMBIO

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

  // ---------------------------------------------------------
  // PUBLICAR
  // ---------------------------------------------------------
  Future<void> _publishFilter() async {
    try {
      _setMessage("Subiendo imagen...");

      File toUpload;

      if (filtroSeleccionado == "ninguno") {
        toUpload = widget.imageFile;
      } else if (_processedImageBytes != null) {
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

  // ---------------------------------------------------------
  // PARÁMETROS
  // ---------------------------------------------------------
  Widget _buildParametros() {
    if (filtroSeleccionado == "ninguno") {
      return const Text(
        "Sin filtro seleccionado.",
        style: TextStyle(color: Colors.white70, fontSize: 16),
      );
    }

    final params = FilterConfig.filtrosParametros[filtroSeleccionado] ?? [];

    if (params.isEmpty) {
      return const Text(
        "Este filtro no requiere parámetros.",
        style: TextStyle(color: Colors.white70, fontSize: 16),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Parámetros del filtro: $filtroSeleccionado",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        for (var param in params)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$param: ${valoresActuales[param]?.toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.white),
              ),

              Slider(
                value: valoresActuales[param]!,
                min: FilterConfig.rangosParametros[filtroSeleccionado]![param]![0],
                max: FilterConfig.rangosParametros[filtroSeleccionado]![param]![1],
                onChanged: _loading ? null : (value) {
                  setState(() {
                    valoresActuales[param] = value;
                  });
                  _triggerProcessing();
                },
              ),
            ],
          ),
      ],
    );
  }

  // ---------------------------------------------------------
  // CARRUSEL DE FILTROS
  // ---------------------------------------------------------
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
                _processedImageBytes = null;        // <<< CAMBIO
                _cargarValoresIniciales();
              });

              if (f != "ninguno") {
                _triggerProcessing();              // <<< SOLO si aplica
              }
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

  // ---------------------------------------------------------
  // UI
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final showResult =
        filtroSeleccionado != "ninguno" && _processedImageBytes != null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: _loading ? 0.4 : 1,
            child: AbsorbPointer(
              absorbing: _loading,
              child: SingleChildScrollView(
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

                    Center(
                      child: ElevatedButton(
                        onPressed: _loading ? null : _publishFilter,
                        child: const Text("Publicar"),
                      ),
                    ),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),

          // BOTÓN CERRAR
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

          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
        ],
      ),
    );
  }
}
