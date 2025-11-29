// lib/endpoints/session_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'endpoints.dart';

class SessionAPI {
  static const _storage = FlutterSecureStorage();

  /// Create a session (teacher only).
  /// Expects backend response: { "qr_token": "...", "expires_at": "2025-11-25T12:00:00Z" }
  static Future<Map<String, dynamic>> createSession({
    required int classId,
    required DateTime date,
  }) async {
    final access = await _storage.read(key: "access");
    final url = Uri.parse(Endpoints.createSession);

    final res = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        if (access != null) "Authorization": "Bearer $access",
      },
      body: jsonEncode({
        "class_id": classId,
        "date": date.toIso8601String().split('T').first, // send YYYY-MM-DD
      }),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      String msg = res.body;
      try {
        final body = jsonDecode(res.body);
        msg = body['error'] ?? body['detail'] ?? res.body;
      } catch (_) {}
      throw Exception("Create session failed: ${res.statusCode} - $msg");
    }
  }

  /// Optional: fetch classes (simple endpoint). Adjust if you have a different endpoint.
  static Future<List<Map<String, dynamic>>> fetchClasses() async {
    final access = await _storage.read(key: "access");
    final url = Uri.parse(Endpoints.classes);
    final res = await http.get(url, headers: {
      if (access != null) "Authorization": "Bearer $access",
    });

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Failed to fetch classes");
    }
  }
}
