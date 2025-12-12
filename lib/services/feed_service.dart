import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/feed_post.dart';
import '../utils/constants.dart';

class FeedService {
  static Future<String> _getBaseUrl() async {
    final base = await AppConfig.getBaseUrl();
    return "$base/api/feed";   // SIN https://
  }

  static Future<List<FeedPost>> fetchFeed() async {
    final baseUrl = await _getBaseUrl();
    final url = Uri.parse(baseUrl);

    print("URL FINAL FEED = $url");

    final response = await http.get(url);

    print("STATUS FEED = ${response.statusCode}");
    print("BODY FEED = ${response.body}");
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => FeedPost.fromJson(e)).toList();
    } else {
      throw Exception("Error al cargar feed: ${response.statusCode}");
    }
  }
}
