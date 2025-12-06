class Endpoints {
  static const String baseURL = "http://192.168.1.144:8000/api/";

  // AUTH (account/)
  static const String login = "${baseURL}account/login/";
  static const String adminCreateUser = "${baseURL}account/admin/create-user/";
  static const String profile = "${baseURL}account/profile/";
  static const String updateProfile = "${baseURL}account/profile/update/";
  static const String changePassword = "${baseURL}account/password/change/";

  // CLASSES (classes/)
  static const String teacherClasses = "${baseURL}classes/list/";
  static const String assignUsersToClass = "${baseURL}classes/assign/";
  static const String createClassSession = "${baseURL}classes/create/";

  // Routine APIs
  static const String teacherRoutine = "${baseURL}classes/routine/teacher/";
  static const String studentRoutine = "${baseURL}classes/routine/student/";

  // ATTENDANCE (attendance/)
  static const String generateQR = "${baseURL}attendance/generate-qr/";
  static const String markAttendance = "${baseURL}attendance/mark/";
  static const String viewAttendance = "${baseURL}attendance/view/";
  static const String studentHistory = "${baseURL}attendance/history/";
}
