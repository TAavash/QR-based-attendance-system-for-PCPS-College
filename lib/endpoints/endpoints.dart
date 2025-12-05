class Endpoints {
  static const String baseURL = "http://192.168.1.144:8000/api/";

    // AUTH
  static const String login = "${baseURL}account/login/";

  // CLASS & TEACHER
  static const String teacherClasses = "${baseURL}classes/list/";
  static const String generateQR = "${baseURL}attendance/generate-qr/";

  // STUDENT
  static const String markAttendance = "${baseURL}attendance/mark/";
  static const String studentHistory = "${baseURL}attendance/view/";
}
