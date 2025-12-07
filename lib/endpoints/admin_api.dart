// lib/endpoints/admin_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_api.dart';
import 'endpoints.dart';

class AdminAPI {
  /// Helper headers with token
  static Future<Map<String, String>> _headers() async {
    final token = await AuthAPI.getAccessToken();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // CREATE USER (Admin only)
  static Future<Map<String, dynamic>> createUser({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String role,
  }) async {
    final res = await http.post(
      Uri.parse(Endpoints.adminCreateUser),
      headers: await _headers(),
      body: jsonEncode({
        "email": email,
        "first_name": firstName,
        "last_name": lastName,
        "password": password,
        "role": role,
      }),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200 || res.statusCode == 201) {
      return {"success": true, "message": "User created", "data": data};
    }

    return {"success": false, "message": data["error"] ?? "Failed"};
  }

  // GET ALL USERS (Admin only)
  // (For assign screen + teacher dropdown)
  static Future<List<Map<String, dynamic>>> getUsers() async {
    // If your backend uses another endpoint, tell me
    final url = "${Endpoints.baseURL}account/admin/users/";

    final res = await http.get(Uri.parse(url), headers: await _headers());

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.cast<Map<String, dynamic>>();
    }

    throw Exception("Failed to load users: ${res.statusCode} ${res.body}");
  }

  // CREATE CLASS
  static Future<Map<String, dynamic>> createClass({
    required String year,
    required String semester,
    required String subject,
    required String section,
    required int teacherId,
  }) async {
    final res = await http.post(
      Uri.parse(Endpoints.createClassSession),
      headers: await _headers(),
      body: jsonEncode({
        "year": year,
        "semester": semester,
        "subject": subject,
        "section": section,
        "teacher_id": teacherId,
      }),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200 || res.statusCode == 201) {
      return {"success": true, "message": "Class created", "data": data};
    }

    return {"success": false, "message": data["error"] ?? "Failed"};
  }

  // ASSIGN STUDENTS TO CLASS
  static Future<Map<String, dynamic>> assignStudents({
    required int classId,
    required List<int> studentIds,
  }) async {
    final res = await http.post(
      Uri.parse(Endpoints.assignUsersToClass),
      headers: await _headers(),
      body: jsonEncode({
        "class_id": classId,
        "student_ids": studentIds,
      }),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200 || res.statusCode == 201) {
      return {"success": true, "message": "Students assigned", "data": data};
    }

    return {"success": false, "message": data["error"] ?? "Failed"};
  }

  // GET CLASS LIST (Admin & Teacher)
  static Future<List<Map<String, dynamic>>> getClasses() async {
    final res =
        await http.get(Uri.parse(Endpoints.teacherClasses), headers: await _headers());

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.cast<Map<String, dynamic>>();
    }

    throw Exception("Failed to load classes: ${res.statusCode} ${res.body}");
  }
}
