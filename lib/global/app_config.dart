// lib/global/app_config.dart
class AppConfig {

  static String editionId = "1133";

  static const String eventId = "1230";

  static const String apiKey = "1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7";

  // ==========================================
  // 🔀 اختار البلاصة اللي بغيت تخدم بيها (حيد الكومنتار من وحدة وفعلها)
  // ==========================================

  // 1. رابط التجربة (Test) - مفعل دابا
  //static const String baseUrl = "https://app-buzz-clone-27072026.de.cloud.africsp.com";

  // 2. الرابط الرسمي (Production) - رد ليه الكومنتار إلا بغيت تخدم بيه
   static const String baseUrl = "https://buzzevents.co";

  // ==========================================

  static const String version = "1.0.4";

  static const String registerUrl = "https://badge.pharmahealthexpo.ma";

  static const String logoBaseUrl = "$baseUrl/uploads/";

  static String get appSettingsUrl => "$baseUrl/api/events/$eventId/app-settings";

  static String get loginUrl => "$baseUrl/api/login";

  static String get notificationsApiUrl => "$baseUrl/api";
}