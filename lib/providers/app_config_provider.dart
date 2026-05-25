import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pharma_health_expo/global/app_config.dart';
import '../model/AppConfigModel.dart';

class AppConfigProvider with ChangeNotifier {
  AppConfigModel? _config;
  Map<String, dynamic>? _rawSettings;

  AppConfigModel? get config => _config;
  Map<String, dynamic>? get rawSettings => _rawSettings;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// الميثود الأساسية لبدء التحميل
  Future<void> initializeConfig() async {
    _isLoading = true;
    notifyListeners();

    // 1. محاولة تحميل البيانات من الكاش بناءً على الـ eventId
    final prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('app_settings_cache_${AppConfig.eventId}');

    if (cachedData != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(cachedData);
        _rawSettings = decoded['data'];
        _config = AppConfigModel.fromJson(decoded);
      } catch (e) {
        debugPrint("Error loading from cache: $e");
      }
    }

    // 2. جلب أحدث البيانات من السيرفر
    await fetchFromApi();

    _isLoading = false;
    notifyListeners();
  }

  /// جلب البيانات من الـ API المذكورة في AppConfig
  Future<void> fetchFromApi() async {
    try {
      debugPrint("Fetching config from: ${AppConfig.appSettingsUrl}");

      final response = await http.get(
        Uri.parse(AppConfig.appSettingsUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // إذا كان السيرفر كيحتاج apiKey، فك التعليق تحت:
          // 'X-API-KEY': AppConfig.apiKey,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // حفظ البيانات الخام
        _rawSettings = jsonData['data'];

        // حفظ في الكاش الخاص بهذا الـ eventId
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('app_settings_cache_${AppConfig.eventId}', json.encode(jsonData));

        // تحديث الـ Config
        _config = AppConfigModel.fromJson(jsonData);

        debugPrint("✅ Configuration fetched and updated successfully.");
        notifyListeners();
      } else {
        debugPrint("Failed to fetch config: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching config from API: $e");
    }
  }
}