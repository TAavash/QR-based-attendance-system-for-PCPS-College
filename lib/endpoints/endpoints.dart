class Endpoints {
  // ---------- BASE URL ----------
  // Change this ONE place only
  static const String baseURL = "http://192.168.137.1:8000/api/";

  // ---------- AUTH ----------
  static const String register = "${baseURL}users/register/";
  static const String login = "${baseURL}users/login/";

  // ---------- TEACHER ----------
  static const String createSession = "${baseURL}attendance/create-session/";

  // ---------- STUDENT ----------
  static const String markAttendance = "${baseURL}attendance/mark/";

  // ---------- CLASSES ----------
  static const String classes = "${baseURL}classes/";

  // ---------- SESSIONS ----------
  static const String sessions = "${baseURL}sessions/";
}
