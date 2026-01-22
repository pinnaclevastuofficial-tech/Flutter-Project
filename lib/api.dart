import 'dart:convert';
// import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClient {
 static String get baseUrl {
  return 'http://127.0.0.1:8000';
}


  Future<Map<String, dynamic>> health() async {
    final res = await http.get(Uri.parse('$baseUrl/v1/health'));
    if (res.statusCode != 200) {
      throw Exception('Health failed: ${res.body}');
    }
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> genericChat({
    required String userId,
    required String message,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/v1/ai/generic_chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'message': message,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Chat failed: ${res.body}');
    }
    return jsonDecode(res.body);
  }
}
