// lib/providers/theme_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pharma_health_expo/model/app_theme_data.dart';
import 'package:pharma_health_expo/providers/app_config_provider.dart';

class ThemeProvider with ChangeNotifier {
  AppThemeData _currentTheme = AppThemeData.defaultTheme();

  AppThemeData get currentTheme => _currentTheme;

  ThemeProvider() {
    // ⚠️️ قراءة الكاش بشكل سرييع باش يديمارجي بالثيم الصحيح من أول لقطة
    _loadCachedThemeSync();
  }

  // قراءة SharedPreferences فالبداية (بما أن Constructor لا يقبل async مباشرة، كنستعملو هاد الطريقة)
  void _loadCachedThemeSync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString('cached_theme_data');
      if (cachedString != null) {
        final Map<String, dynamic> data = json.decode(cachedString);
        _currentTheme = AppThemeData.fromApi(data);
        notifyListeners(); // إعلام التطبيق بالثيم المحفوظ فوراً
        debugPrint("✅ [ThemeProvider] Loaded theme from local cache instantly.");
      }
    } catch (e) {
      debugPrint("⚠️ [ThemeProvider] Error loading cached theme: $e");
    }
  }

  /// هاد الميثود كتاخد الـ Data الخام من AppConfigProvider وكتطبق الـ Theme وكتسجلو
  void updateThemeFromConfig(AppConfigProvider configProvider) async {
    final Map<String, dynamic>? data = configProvider.rawSettings;

    if (data != null) {
      _currentTheme = AppThemeData.fromApi(data);
      notifyListeners();
      debugPrint("✅ [ThemeProvider] Theme updated successfully from Config.");

      // حفظ الثيم في SharedPreferences باش يستعملو في المرة القادمة مباشرة
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_theme_data', json.encode(data));
      } catch (e) {
        debugPrint("⚠️ [ThemeProvider] Error saving theme cache: $e");
      }
    }
  }

  /// في حالة بغيتي دير reset للـ theme
  void resetToDefault() async {
    _currentTheme = AppThemeData.defaultTheme();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_theme_data');
  }
}