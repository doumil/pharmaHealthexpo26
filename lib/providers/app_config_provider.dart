// lib/providers/app_config_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pharma_health_expo/global/app_config.dart';
import 'package:pharma_health_expo/model/AppConfigModel.dart';

class AppConfigProvider with ChangeNotifier {
  AppConfigModel? _config;
  Map<String, dynamic>? _rawSettings;

  AppConfigModel? get config => _config;
  Map<String, dynamic>? get rawSettings => _rawSettings;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Getter آمن لاستخراج روابط السلايدات من rawSettings وتحويلها إلى روابط كاملة
  List<String> get slides {
    try {
      if (_rawSettings != null && _rawSettings!['slides'] != null) {
        final slidesObj = _rawSettings!['slides'];
        if (slidesObj is Map) {
          final enabled = slidesObj['enabled'];
          bool isEnabled = enabled == true || enabled.toString().toLowerCase() == 'true';

          if (isEnabled && slidesObj['value'] != null) {
            var val = slidesObj['value'];
            List<dynamic> rawList = [];

            if (val is List) {
              rawList = val;
            } else if (val is String) {
              try {
                final decodedList = json.decode(val);
                if (decodedList is List) {
                  rawList = decodedList;
                }
              } catch (_) {}
            }

            // تحويل المسار النسبي إلى رابط كامل يحتوي على baseUrl
            return rawList.map((e) {
              String path = e.toString().replaceAll(r'\/', '/').trim();
              if (path.startsWith('/')) {
                path = path.substring(1);
              }
              if (!path.startsWith('http://') && !path.startsWith('https://')) {
                return '${AppConfig.baseUrl}/$path';
              }
              return path;
            }).toList();
          }
        }
      }
    } catch (e) {
      debugPrint("⚠️ Error parsing slides in AppConfigProvider: $e");
    }
    return [];
  }

  Future<void> initializeConfig() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('app_settings_cache_${AppConfig.eventId}');

    if (cachedData != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(cachedData);
        _rawSettings = decoded['data'];
        _config = AppConfigModel.fromJson(decoded);
      } catch (e) {
        debugPrint("⚠️ Error parsing Model from cache (ignoring): $e");
      }
    }

    await fetchFromApi();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchFromApi() async {
    try {
      debugPrint("Fetching config from: ${AppConfig.appSettingsUrl}");

      final response = await http.get(
        Uri.parse(AppConfig.appSettingsUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        _rawSettings = jsonData['data'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('app_settings_cache_${AppConfig.eventId}', json.encode(jsonData));

        try {
          _config = AppConfigModel.fromJson(jsonData);
        } catch (modelError) {
          debugPrint("⚠️ [AppConfigModel] Crashed due to server types but bypassed: $modelError");
        }

        debugPrint("✅ Configuration synced. Found ${slides.length} slides.");
        notifyListeners();
      } else {
        debugPrint("Failed to fetch config: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching config from API: $e");
    }
  }
}