import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'endpoints.dart';

class AuthAPI {
  static const storage = FlutterSecureStorage();

  static Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse(Endpoints.register),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
        "role": role,
      }),
    );

    return response.statusCode == 201;
  }

  static Future<bool> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(Endpoints.login),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: "access", value: data["access"]);
      await storage.write(key: "refresh", value: data["refresh"]);
      await storage.write(key: "role", value: data["user"]["role"]);
      return true;
    }

    return false;
  }

  static Future<String?> getRole() async {
    return await storage.read(key: "role");
  }

  static Future<void> logout() async {
    await storage.deleteAll();
  }

  static Future<String?> getAccessToken() async {
    return await storage.read(key: "access");
  }
}
