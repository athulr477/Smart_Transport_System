import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiClient {
  // Enhanced GET for single objects (Map)
  static Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(
      Uri.parse("${AppConfig.baseUrl}$endpoint"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception("GET $endpoint failed: ${response.body}");
    }
  }

  // FOR LIST RESPONSES (e.g., getting all buses)
  static Future<List<dynamic>> getList(String endpoint) async {
    final response = await http.get(
      Uri.parse("${AppConfig.baseUrl}$endpoint"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception("GET LIST $endpoint failed: ${response.body}");
    }
  }

  // POST FUNCTION (For Login/Add features)
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse("${AppConfig.baseUrl}$endpoint"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception("POST $endpoint failed: ${response.body}");
    }
  }

  // DELETE FUNCTION (Newly Added)
  static Future<void> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse("${AppConfig.baseUrl}$endpoint"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception("DELETE $endpoint failed: ${response.body}");
    }
    // No return needed for void, but ensures success check is done
  }
}