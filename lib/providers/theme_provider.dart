// lib/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

import 'package:pharma_health_expo/global/app_config.dart';
import '../model/app_theme_data.dart';

class ThemeProvider with ChangeNotifier {
  // Always initialize with secure default system properties
  AppThemeData _currentTheme = AppThemeData.defaultTheme();

  AppThemeData get currentTheme => _currentTheme;

  /// Loads locally stored theme preferences from SharedPreferences if cache integrity checks pass.
  Future<void> loadCachedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedTheme = prefs.getString('cached_theme_data');

      if (cachedTheme != null) {
        final Map<String, dynamic> jsonData = json.decode(cachedTheme);

        if (jsonData.containsKey('primary_color') || jsonData.containsKey('badge')) {
          _currentTheme = AppThemeData.fromApi(jsonData);
          notifyListeners();
          debugPrint("📦 [ThemeProvider] Fallback: Cached theme loaded successfully into memory.");
        } else {
          debugPrint("ℹ️ [ThemeProvider] Outdated cache structure detected. Keeping default values.");
        }
      }
    } catch (e) {
      debugPrint("⚠️ [ThemeProvider] Error loading cached theme: $e");
    }
  }

  /// Fetches layout parameters from remote endpoint. Falls back to local cache or defaults on failure.
  Future<void> fetchThemeFromApi() async {
    final String url = '${AppConfig.baseUrl}/api/events/${AppConfig.eventId}/app-settings';
    debugPrint("🔍 [ThemeProvider] Fetching theme configurations from: $url");

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData.containsKey('data') && jsonData['data'] != null) {
          _currentTheme = AppThemeData.fromApi(jsonData['data']);
          notifyListeners();
          debugPrint("🚀 [ThemeProvider] Theme updated successfully from live API configuration.");

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('cached_theme_data', json.encode(jsonData['data']));
        } else {
          throw const FormatException("API missing target structure 'data' key.");
        }
      } else {
        throw HttpException('Remote status host issue: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("⚠️ [ThemeProvider] API Fetch failed ($e). Redirecting to client cache records...");
      // 💡 Strict Fallback Sequence: If the API breaks down, read from disk immediately
      await loadCachedTheme();
    }
  }
}