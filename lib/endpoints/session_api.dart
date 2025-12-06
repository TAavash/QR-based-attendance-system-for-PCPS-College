import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_api.dart';
import 'endpoints.dart';

class SessionAPI {
  // fetch classes assigned to teacher
  static Future<List<Map<String, dynamic>>> fetchTeacherClasses() async {
    final token = await AuthAPI.getAccessToken();
    final res = await http.get(Uri.parse(Endpoints.teacherClasses), headers: {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    });

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Failed to load teacher classes: ${res.statusCode} ${res.body}");
    }
  }

  // generate QR (teacher) -> backend may return uuid, qr_image (base64), expires_at
  static Future<Map<String, dynamic>> generateQR({required int classId}) async {
    final token = await AuthAPI.getAccessToken();
    final res = await http.post(
      Uri.parse(Endpoints.generateQR),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode({"class_id": classId}),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception("Create session failed: ${res.statusCode} ${res.body}");
    }
  }

  // mark attendance (student). Pass qr_uuid and device lat/lng for geofence check
  static Future<Map<String, dynamic>> markAttendance({
    required String qrUuid,
    required double lat,
    required double lng,
  }) async {
    final token = await AuthAPI.getAccessToken();
    final res = await http.post(
      Uri.parse(Endpoints.markAttendance),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "qr_uuid": qrUuid,
        "lat": lat.toString(),
        "lng": lng.toString(),
      }),
    );

    final Map<String, dynamic> body = (res.body.isNotEmpty) ? jsonDecode(res.body) as Map<String, dynamic> : {};

    if (res.statusCode == 200 || res.statusCode == 201) {
      return body;
    } else {
      return body..putIfAbsent("error", () => "Failed (${res.statusCode})");
    }
  }

  // teacher session list
  static Future<List<Map<String, dynamic>>> getTeacherSessions() async {
    final token = await AuthAPI.getAccessToken();
    final res = await http.get(Uri.parse(Endpoints.teacherSessions), headers: {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    });

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Failed to fetch teacher sessions: ${res.statusCode}");
    }
  }

  // student attendance history
  static Future<List<Map<String, dynamic>>> getStudentHistory() async {
    final token = await AuthAPI.getAccessToken();
    final res = await http.get(Uri.parse(Endpoints.studentHistory), headers: {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    });

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Failed to fetch history: ${res.statusCode}");
    }
  }
}
