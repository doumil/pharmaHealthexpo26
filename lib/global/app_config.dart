class AppConfig {

  static  String editionId = "";

  static const String eventId = "1230";

  static const String apiKey = "1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7";

  static const String baseUrl = "https://buzzevents.co";

  static const String version = "1.0.3";

  static const String registerUrl = "https://badge.pharmahealthexpo.ma";

  static const String logoBaseUrl = "$baseUrl/uploads/";

  static String get appSettingsUrl => "$baseUrl/api/events/$eventId/app-settings";

  static String get loginUrl => "$baseUrl/api/login";
}