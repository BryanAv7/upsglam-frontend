// lib/services/filter_service.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../utils/constants.dart';   // donde está AppConfig

class FilterService {
  FilterService();

  /// Obtiene la URL base configurada por el usuario.
  Future<String> _getBaseUrl() async {
    return await AppConfig.getBaseUrl();   // esto viene de SharedPreferences
  }

  /// Envía imagen + parámetros al backend.
  /// Retorna: (bytesProcesados, mensajeServidor)
  Future<(Uint8List?, String?)> procesarImagen({
    required File imagen,
    required String filtro,
    required Map<String, double> parametros,
  }) async {

    final base = await _getBaseUrl();    // <<< AQUÍ sí puedes usar await
    final uri = Uri.parse("$base/api/imagen/procesar");

    var request = http.MultipartRequest("POST", uri);

    final mimeType = imagen.path.endsWith(".png")
        ? MediaType("image", "png")
        : MediaType("image", "jpeg");

    request.files.add(
      await http.MultipartFile.fromPath(
        "imagen",
        imagen.path,
        contentType: mimeType,
      ),
    );

    request.fields["filtro"] = filtro;

    parametros.forEach((k, v) {
      request.fields[k] = v.toString();
    });

    try {
      final response = await request.send();
      final bytes = await response.stream.toBytes();

      final type = response.headers["content-type"] ?? "";

      if (type.contains("text") || type.contains("json")) {
        return (null, String.fromCharCodes(bytes));
      }

      return (bytes, "Imagen procesada correctamente.");
    } catch (e) {
      return (null, "Error: $e");
    }
  }
}
