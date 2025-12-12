import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../utils/constants.dart';

class PostService {
  static Future<Map<String, dynamic>> uploadPost({
    required String filePath,
    required String caption,
    required String userUid,
  }) async {
    final uri = Uri.parse('${await AppConfig.getBaseUrl()}/posts/upload');
    final request = http.MultipartRequest('POST', uri);

    // envio
    request.files.addAll([
      http.MultipartFile.fromString('uid', userUid, contentType: MediaType('text', 'plain')),
      if (caption.isNotEmpty)
        http.MultipartFile.fromString('caption', caption, contentType: MediaType('text', 'plain')),
      await http.MultipartFile.fromPath(
        'image',
        filePath,
        filename: filePath.split('/').last,
        contentType: _getMediaType(filePath),
      ),
    ]);

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode ~/ 100 != 2) {
      throw Exception('Error ${response.statusCode}: $body');
    }

    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (e) {
      return {'raw': body, 'imageUrl': null};
    }
  }

  static MediaType _getMediaType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'png': return MediaType('image', 'png');
      case 'jpg':
      case 'jpeg': return MediaType('image', 'jpeg');
      case 'webp': return MediaType('image', 'webp');
      default: return MediaType('image', 'jpeg');
    }
  }
}