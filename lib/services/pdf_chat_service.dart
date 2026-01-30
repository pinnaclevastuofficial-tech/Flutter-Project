import 'dart:convert';
import 'package:http/http.dart' as http;

class PdfChatService {
  static const String baseUrl = "http://10.0.2.2:8000"; // Android emulator

  static Future<String> ask({
    required String userId,
    required String message,
    required String sourceId,
  }) async {
    final uri = Uri.parse("$baseUrl/v1/ai/generic_chat");

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "message": message,
        "source_id": sourceId,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception(res.body);
    }

    final data = jsonDecode(res.body);
    return (data["answer"] ?? "").toString();
  }
}
