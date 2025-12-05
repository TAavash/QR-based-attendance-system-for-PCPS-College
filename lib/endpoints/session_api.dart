import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_api.dart';
import 'endpoints.dart';

class SessionAPI {
  // Fetch classes assigned to the teacher (or all classes endpoint)
  static Future<List<Map<String, dynamic>>> fetchTeacherClasses() async {
  final token = await AuthAPI.getAccessToken();

  final res = await http.get(
    Uri.parse(Endpoints.teacherClasses),
    headers: {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    },
  );

  if (res.statusCode == 200) {
    final List data = jsonDecode(res.body);
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception("Failed to load teacher classes");
  }
}


  // Create session / generate QR (teacher). Send class_id (PK)
  static Future<Map<String, dynamic>> generateQR({
    required int classId,
  }) async {
    final token = await AuthAPI.getAccessToken();
    final res = await http.post(
      Uri.parse(Endpoints.generateQR),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode({"class_id": classId.toString()}),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception("Create session failed: ${res.statusCode} ${res.body}");
    }
  }

  // Mark attendance by token (student scan)
  static Future<Map<String, dynamic>> markAttendance(String qrToken) async {
    final token = await AuthAPI.getAccessToken();
    final res = await http.post(
      Uri.parse(Endpoints.markAttendance),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode({"qr_uuid": qrToken}),
    );

    final Map<String, dynamic> body = (res.body.isNotEmpty) ? jsonDecode(res.body) as Map<String, dynamic> : {};

    if (res.statusCode == 200 || res.statusCode == 201) {
      return body;
    } else {
      // return body anyway so UI can show message
      return body..putIfAbsent("error", () => "Failed (${res.statusCode})");
    }
  }

  // // Teacher's sessions
  // static Future<List<Map<String, dynamic>>> getTeacherSessions() async {
  //   final token = await AuthAPI.getAccessToken();
  //   final res = await http.get(
  //     Uri.parse(Endpoints.teacherSessions),
  //     headers: {
  //       "Content-Type": "application/json",
  //       if (token != null) "Authorization": "Bearer $token",
  //     },
  //   );

  //   if (res.statusCode == 200) {
  //     final List data = jsonDecode(res.body);
  //     return data.cast<Map<String, dynamic>>();
  //   } else {
  //     throw Exception("Failed to fetch teacher sessions: ${res.statusCode}");
  //   }
  // }

  // Student attendance history
  static Future<List<Map<String, dynamic>>> getStudentHistory() async {
    final token = await AuthAPI.getAccessToken();
    final res = await http.get(
      Uri.parse(Endpoints.studentHistory),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Failed to fetch history: ${res.statusCode}");
    }
  }


}
