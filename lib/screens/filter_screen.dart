import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/filter_service.dart';
import '../models/filter_config_model.dart';

class FilterScreen extends StatefulWidget {
  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  File? _selectedImage;
  Uint8List? _processedImageBytes;
  bool _loading = false;
  String? _serverResponse;

  late final FilterService _filterService;
  final picker = ImagePicker();

  String filtroSeleccionado = "sobel";

  /// Parámetros actuales del filtro elegido
  Map<String, double> valoresActuales = {};

  @override
  void initState() {
    super.initState();
    _filterService = FilterService();

    valoresActuales = Map<String, double>.from(
      FilterConfig.valoresDefecto[filtroSeleccionado]!,
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _processedImageBytes = null;
        _serverResponse = null;
      });
    }
  }

  Future<void> _sendImage() async {
    if (_selectedImage == null) return;

    setState(() => _loading = true);

    final (bytes, message) = await _filterService.procesarImagen(
      imagen: _selectedImage!,
      filtro: filtroSeleccionado,
      parametros: valoresActuales,
    );

    setState(() {
      _loading = false;
      _processedImageBytes = bytes;
      _serverResponse = message;
    });
  }

  /// Construye los sliders según el filtro seleccionado
  Widget _buildParametros() {
    final params = FilterConfig.filtrosParametros[filtroSeleccionado]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Parámetros de $filtroSeleccionado",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),

        for (var param in params)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("$param:  ${valoresActuales[param]!.toStringAsFixed(2)}"),
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
              SizedBox(height: 10)
            ],
          ),
      ],
    );
  }

  /// Carrusel de filtros
  Widget _buildFiltroCarousel() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: FilterConfig.filtros.length,
        itemBuilder: (context, index) {
          final filtro = FilterConfig.filtros[index];
          final seleccionado = filtro == filtroSeleccionado;

          return GestureDetector(
            onTap: () {
              setState(() {
                filtroSeleccionado = filtro;
                valoresActuales = Map<String, double>.from(
                  FilterConfig.valoresDefecto[filtro]!,
                );
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: seleccionado ? Colors.blue : Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: seleccionado ? Colors.white : Colors.grey,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  filtro,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                    seleccionado ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hayImagen = _selectedImage != null || _processedImageBytes != null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("Filtro de Imágenes")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // BOTÓN SELECCIONAR IMAGEN
            ElevatedButton(
              onPressed: _pickImage,
              child: Text("Seleccionar imagen"),
            ),

            SizedBox(height: 20),

            // SI NO HAY IMAGEN → SOLO FONDO NEGRO
            if (!hayImagen)
              Container(
                height: 300,
                color: Colors.black,
                alignment: Alignment.center,
                child: Text(
                  "Selecciona una imagen para iniciar",
                  style: TextStyle(color: Colors.white70),
                ),
              ),

            // IMAGEN ORIGINAL O PROCESADA
            if (hayImagen)
              Container(
                height: 300,
                child: _processedImageBytes != null
                    ? Image.memory(_processedImageBytes!)
                    : Image.file(_selectedImage!),
              ),

            SizedBox(height: 20),

            // CARRUSEL DE FILTROS (solo si hay imagen)
            if (hayImagen) _buildFiltroCarousel(),

            SizedBox(height: 20),

            // PARÁMETROS DEL FILTRO SELECCIONADO
            if (hayImagen) _buildParametros(),

            SizedBox(height: 20),

            // BOTÓN PROCESAR
            if (hayImagen)
              ElevatedButton(
                onPressed: _loading ? null : _sendImage,
                child: _loading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Procesar"),
              ),

            SizedBox(height: 20),

            if (_serverResponse != null)
              Text(
                _serverResponse!,
                style: TextStyle(color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
