import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // New import for SocketException

import '../model/app_theme_data.dart';
// Note: You have two imports for the same file. You should remove one.
// import '../model/app_theme_data.dart';

class ThemeProvider with ChangeNotifier {
  // Set the default theme to ensure the app has colors even if the API fails.
  AppThemeData _currentTheme = AppThemeData(
    primaryColor: const Color(0xff261350),
    secondaryColor: const Color(0xff00C1C1),
    blackColor: Colors.black,
    whiteColor: Colors.white,
    redColor: Colors.red,
  );

  AppThemeData get currentTheme => _currentTheme;

  Future<void> fetchThemeFromApi() async {
    const url = 'https://buzzevents.co/api/events/10/app-settings';
    debugPrint("🔍 Attempting to fetch theme from API: $url");

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        debugPrint("✅ API request successful (Status 200). Parsing data...");
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData.containsKey('data')) {
          _currentTheme = AppThemeData.fromApi(jsonData['data']);
          notifyListeners();
          debugPrint("🚀 Theme updated successfully.");
        } else {
          // If "data" key is missing, throw a specific exception.
          throw const FormatException("API response is missing the 'data' key.");
        }
      } else {
        // If the server returns an error status code.
        debugPrint("⚠️ API request failed with status code: ${response.statusCode}");
        throw HttpException('Failed to load theme data from API. Status Code: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      // ❌ Catches network-related errors (no internet, host unreachable).
      debugPrint("❌ Network error: Could not connect to host. Exception: $e");
      // App will use the default theme.
    } on FormatException catch (e) {
      // ❌ Catches JSON parsing errors (malformed JSON).
      debugPrint("❌ JSON parsing error: API response is not a valid JSON. Exception: $e");
      // App will use the default theme.
    } on HttpException catch (e) {
      // ❌ Catches HTTP errors (non-200 status codes).
      debugPrint("❌ HTTP Error: $e");
      // App will use the default theme.
    } catch (e) {
      // ❌ Catches all other unexpected errors.
      debugPrint("❌ An unexpected error occurred: $e");
      // App will use the default theme.
    }
  }
}