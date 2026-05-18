import 'package:flutter/material.dart';

class AppThemeData {
  final Color primaryColor;
  final Color secondaryColor;
  final Color blackColor;
  final Color whiteColor;
  final Color redColor; // Note: 'red_color' in your model, but 'reed_color' in your API.

  AppThemeData({
    required this.primaryColor,
    required this.secondaryColor,
    required this.blackColor,
    required this.whiteColor,
    required this.redColor,
  });

  factory AppThemeData.fromApi(Map<String, dynamic>? json) {
    if (json == null) {
      debugPrint("⚠️ API 'data' field is null. Returning default theme.");
      return defaultTheme();
    }

    // Helper function to safely extract and parse the color value from a nested map
    Color _parseColorValue(Map<String, dynamic>? colorData, {Color defaultColor = Colors.black}) {
      if (colorData != null && colorData['value'] != null) {
        final String hexString = colorData['value'];
        try {
          // Add transparency and parse the hex string
          final buffer = StringBuffer();
          if (hexString.length == 6) {
            buffer.write('ff'); // Add full opacity if not specified
          } else if (hexString.length == 8) {
            // Handle the '0x' prefix
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

    return AppThemeData(
      primaryColor: _parseColorValue(json['primary_color'] as Map<String, dynamic>?),
      secondaryColor: _parseColorValue(json['secondary_color'] as Map<String, dynamic>?),
      blackColor: _parseColorValue(json['black_color'] as Map<String, dynamic>?),
      whiteColor: _parseColorValue(json['white_color'] as Map<String, dynamic>?),
      redColor: _parseColorValue(json['reed_color'] as Map<String, dynamic>?), // ✅ NOTE: API uses "reed_color"
    );
  }

  static AppThemeData defaultTheme() {
    return AppThemeData(
      primaryColor: const Color(0xff50134f),
      secondaryColor: const Color(0xff00C1C1),
      blackColor: Colors.black,
      whiteColor: Colors.white,
      redColor: Colors.red,
    );
  }
}