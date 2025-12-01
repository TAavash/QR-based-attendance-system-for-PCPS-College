class Endpoints {
  static const String baseURL = "http://192.168.1.144:8000/api/";

  // // AUTH
  static const String register = "${baseURL}users/register/";
  // static const String login = "${baseURL}users/login/";

  // // CLASS & TEACHER
  // static const String teacherClasses = "${baseURL}attendance/teacher/classes/";
  // static const String createClass = "${baseURL}attendance/create-class/";

  // // SESSION
  // static const String createSession = "${baseURL}attendance/create-session/";
  // static const String teacherSessions = "${baseURL}attendance/teacher/sessions/";

  // // STUDENT
  // static const String markAttendance = "${baseURL}attendance/mark-attendance/";
  // static const String studentHistory = "${baseURL}attendance/student/history/";

    // AUTH
  static const String login = "${baseURL}account/login/";

  // CLASS & TEACHER
  static const String teacherClasses = "${baseURL}classes/list/";
  static const String generateQR = "${baseURL}attendance/generate-qr/";

  // SESSION
  static const String createSession = "${baseURL}attendance/create-session/";
  static const String teacherSessions = "${baseURL}attendance/teacher/sessions/";

  // STUDENT
  static const String markAttendance = "${baseURL}attendance/mark/";
  static const String studentHistory = "${baseURL}attendance/student/history/";
}
