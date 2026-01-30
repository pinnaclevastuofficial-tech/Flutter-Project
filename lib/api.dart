import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = "http://127.0.0.1:8000";

  // Health check
  Future<Map<String, dynamic>> health() async {
    final res = await http.get(Uri.parse("$baseUrl/v1/health"));
    return jsonDecode(res.body);
  }

  // Generic Chat (PDF based)
  Future<Map<String, dynamic>> genericChat({
    required String userId,
    required String message,
    required String sourceId,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/v1/ai/generic_chat"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "message": message,
        "source_id": sourceId,
      }),
    );

    return jsonDecode(res.body);
  }
}
