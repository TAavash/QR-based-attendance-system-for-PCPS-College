import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'endpoints.dart';

class AuthAPI {
  static const storage = FlutterSecureStorage();

  // helper headers (no token)
  static Map<String, String> _plainHeaders() {
    return {"Content-Type": "application/json"};
  }

  /// Login and persist tokens + role
  static Future<bool> login({
    required String uid,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse(Endpoints.login),
      headers: _plainHeaders(),
      body: jsonEncode({"uid": uid, "password": password}),
    );

    if (res.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(res.body);

      // Save access/refresh tokens if present
      if (data.containsKey("access")) {
        await storage.write(key: "access", value: data["access"]);
      }
      if (data.containsKey("refresh")) {
        await storage.write(key: "refresh", value: data["refresh"]);
      }

      // Role: support both shapes: {"role": "..."} OR {"user": {"role": "..."}}
      String? role;
      if (data.containsKey("role") && data["role"] is String) {
        role = data["role"] as String;
      } else if (data.containsKey("user") && data["user"] is Map && data["user"]["role"] is String) {
        role = data["user"]["role"] as String;
      }

      if (role != null) {
        await storage.write(key: "role", value: role);
      }

      return true;
    }

    return false;
  }

  static Future<String?> getAccessToken() async {
    return await storage.read(key: "access");
  }

  static Future<String?> getRole() async {
    return await storage.read(key: "role");
  }

  static Future<void> logout() async {
    await storage.deleteAll();
  }
}
