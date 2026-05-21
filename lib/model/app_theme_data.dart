// lib/model/app_theme_data.dart
import 'package:flutter/material.dart';
import 'package:pharma_health_expo/global/app_config.dart';

class AppThemeData {
  final Color primaryColor;
  final Color secondaryColor;
  final Color blackColor;
  final Color whiteColor;
  final Color redColor;
  final String appTitle;
  final String bannerUrl; // 💡 New field to hold the banner image URL

  AppThemeData({
    required this.primaryColor,
    required this.secondaryColor,
    required this.blackColor,
    required this.whiteColor,
    required this.redColor,
    required this.appTitle,
    required this.bannerUrl, // 💡 Added to constructor
  });

  factory AppThemeData.fromApi(Map<String, dynamic>? json) {
    if (json == null) {
      debugPrint("⚠️ API 'data' field is null. Returning default theme.");
      return defaultTheme();
    }

    // Helper to safely parse hex color values from the API map structure
    Color _parseColorValue(Map<String, dynamic>? colorData, {Color defaultColor = Colors.black}) {
      if (colorData != null && colorData['value'] != null) {
        final String hexString = colorData['value'];
        try {
          final buffer = StringBuffer();
          if (hexString.length == 6) {
            buffer.write('ff');
          } else if (hexString.length == 8) {
            return Color(int.parse(hexString, radix: 16));
          }
          buffer.write(hexString.replaceFirst('0x', ''));
          return Color(int.parse(buffer.toString(), radix: 16));
        } catch (e) {
          debugPrint("Error parsing hex color value: $e, using default color.");
          return defaultColor;
        }
      }
      return defaultColor;
    }

    // Helper to safely extract string values like titles or URLs
    String _parseStringValue(Map<String, dynamic>? data, {required String defaultValue}) {
      if (data != null && data['value'] != null) {
        return data['value'].toString();
      }
      return defaultValue;
    }

    return AppThemeData(
      primaryColor: _parseColorValue(json['primary_color'] as Map<String, dynamic>?),
      secondaryColor: _parseColorValue(json['secondary_color'] as Map<String, dynamic>?),
      blackColor: _parseColorValue(json['black_color'] as Map<String, dynamic>?),
      whiteColor: _parseColorValue(json['white_color'] as Map<String, dynamic>?),
      redColor: _parseColorValue(json['reed_color'] as Map<String, dynamic>?),
      appTitle: _parseStringValue(json['app_title'] as Map<String, dynamic>?, defaultValue: "EMEC EXPO"),
      // 💡 Parsing the banner URL from API. Replace 'banner_url' with the actual key from your JSON.
      bannerUrl: _parseStringValue(json['banner_url'] as Map<String, dynamic>?,
          defaultValue: '${AppConfig.baseUrl}/uploads/800x400-EMECEXPO-2025.jpg'),
    );
  }

  // Fallback values used if the API is unreachable
  static AppThemeData defaultTheme() {
    return AppThemeData(
      primaryColor: const Color(0xff50134f),
      secondaryColor: const Color(0xff00C1C1),
      blackColor: Colors.black,
      whiteColor: Colors.white,
      redColor: Colors.red,
      appTitle: "EMEC EXPO",
      bannerUrl: '${AppConfig.baseUrl}/uploads/800x400-EMECEXPO-2025.jpg',
    );
  }
}