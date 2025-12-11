import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class FilterScreen extends StatefulWidget {
  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  File? _selectedImage;
  Uint8List? _processedImageBytes;

  bool _loading = false;
  String? _serverResponse;

  final picker = ImagePicker();

  // ================================================
  // LISTA DE FILTROS, PARAMETROS, RANGOS Y DEFAULTS
  // ================================================

  final List<String> filtros = [
    "emboss",
    "sobel",
    "gaussiano",
    "sharpen",
    "sombras_epico",
    "resaltado_frio"
  ];

  final Map<String, List<String>> filtrosParametros = {
    "emboss": ["offset", "factor"],
    "sobel": ["factor"],
    "gaussiano": ["sigma"],
    "sharpen": ["sharp_factor"],
    "sombras_epico": ["highlight_boost", "vignette_strength"],
    "resaltado_frio": ["blue_boost", "contrast"],
  };

  final Map<String, Map<String, List<double>>> rangosParametros = {
    "emboss": {
      "offset": [0.0, 255.0],
      "factor": [1.0, 5.0],
    },
    "sobel": {
      "factor": [1.0, 5.0],
    },
    "gaussiano": {
      "sigma": [1.0, 200.0],
    },
    "sharpen": {
      "sharp_factor": [1.0, 50.0],
    },
    "sombras_epico": {
      "highlight_boost": [0.1, 3.0],
      "vignette_strength": [0.0, 1.0],
    },
    "resaltado_frio": {
      "blue_boost": [0.0, 3.0],
      "contrast": [0.5, 3.0],
    },
  };

  final Map<String, Map<String, double>> valoresDefecto = {
    "emboss": {"offset": 128.0, "factor": 2.0},
    "sobel": {"factor": 2.0},
    "gaussiano": {"sigma": 90.0},
    "sharpen": {"sharp_factor": 20.0},
    "sombras_epico": {"highlight_boost": 1.1, "vignette_strength": 0.5},
    "resaltado_frio": {"blue_boost": 1.2, "contrast": 1.3},
  };

  String filtroSeleccionado = "sobel";
  Map<String, double> valoresActuales = {};

  @override
  void initState() {
    super.initState();
    valoresActuales = Map<String, double>.from(valoresDefecto[filtroSeleccionado]!);
  }

  // ================================================
  // PICK IMAGE
  // ================================================
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

  // ================================================
  // SEND IMAGE
  // ================================================
  Future<void> _sendImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _loading = true;
      _processedImageBytes = null;
      _serverResponse = null;
    });

    final uri = Uri.parse("http://192.168.1.102:8080/api/imagen/procesar");

    var request = http.MultipartRequest("POST", uri);

    final mimeType = _selectedImage!.path.endsWith(".png")
        ? MediaType("image", "png")
        : MediaType("image", "jpeg");

    request.files.add(
      await http.MultipartFile.fromPath(
        "imagen",
        _selectedImage!.path,
        contentType: mimeType,
      ),
    );

    // Parámetros dinámicos según el filtro
    request.fields["filtro"] = filtroSeleccionado;
    valoresActuales.forEach((k, v) {
      request.fields[k] = v.toString();
    });

    try {
      final response = await request.send();
      final bytes = await response.stream.toBytes();
      final type = response.headers["content-type"] ?? "";

      if (type.contains("text") || type.contains("json")) {
        setState(() {
          _loading = false;
          _serverResponse = "Respuesta no binaria:\n${String.fromCharCodes(bytes)}";
        });
        return;
      }

      setState(() {
        _loading = false;
        _processedImageBytes = bytes;
        _serverResponse = "Imagen procesada correctamente.";
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _serverResponse = "Error: $e";
      });
    }
  }

  // ================================================
  // UI
  // ================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Filtro de Imágenes"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Imagen original
            _buildCard(
              title: "Imagen Original",
              child: Container(
                height: 200,
                child: _selectedImage == null
                    ? Center(child: Text("No se ha seleccionado imagen"))
                    : Image.file(_selectedImage!, fit: BoxFit.cover),
              ),
            ),

            SizedBox(height: 10),

            // Imagen procesada
            if (_processedImageBytes != null)
              _buildCard(
                title: "Imagen Procesada",
                child: Container(
                  height: 200,
                  child: Image.memory(_processedImageBytes!, fit: BoxFit.cover),
                ),
              ),

            SizedBox(height: 15),

            // Dropdown Filtro
            _buildCard(
              title: "Filtro",
              child: DropdownButton<String>(
                value: filtroSeleccionado,
                isExpanded: true,
                items: filtros.map((String f) {
                  return DropdownMenuItem(value: f, child: Text(f));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    filtroSeleccionado = value!;
                    valoresActuales =
                    Map<String, double>.from(valoresDefecto[filtroSeleccionado]!);
                  });
                },
              ),
            ),

            SizedBox(height: 15),

            // Sliders dinámicos según filtro
            ..._buildDynamicSliders(),

            SizedBox(height: 15),

            // Botones
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickImage,
                    child: Text("Seleccionar"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _sendImage,
                    child: _loading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Procesar"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
              ],
            ),

            SizedBox(height: 15),

            // Respuesta del servidor
            _buildCard(
              title: "Respuesta del Servidor",
              child: Text(_serverResponse ?? "Sin respuesta"),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================
  // SLIDERS DINÁMICOS
  // ================================================
  List<Widget> _buildDynamicSliders() {
    final params = filtrosParametros[filtroSeleccionado]!;

    return params.map((param) {
      final rango = rangosParametros[filtroSeleccionado]![param]!;
      final value = valoresActuales[param]!;

      return _buildCard(
        title: param,
        child: Column(
          children: [
            Slider(
              value: value,
              min: rango[0],
              max: rango[1],
              divisions: 100,
              label: value.toStringAsFixed(2),
              onChanged: (newValue) {
                setState(() {
                  valoresActuales[param] = newValue;
                });
              },
            ),
            Text("Valor: ${value.toStringAsFixed(2)}"),
          ],
        ),
      );
    }).toList();
  }

  // ================================================
  // CARD REUTILIZABLE
  // ================================================
  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          SizedBox(height: 8),
          child
        ],
      ),
    );
  }
}
