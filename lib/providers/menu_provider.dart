// lib/providers/menu_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharma_health_expo/global/app_config.dart';

class MenuConfig {
  final bool floorPlan;
  final bool exhibitors;
  final bool speakers;
  final bool program;
  final bool sponsors;
  final bool partners;
  final bool badge;
  final bool products;
  final bool networking;
  final bool congresses;

  MenuConfig({
    this.floorPlan = true,
    this.exhibitors = true,
    this.speakers = true,
    this.program = true,
    this.sponsors = true,
    this.partners = true,
    this.badge = true,
    this.products = true,
    this.networking = true,
    this.congresses = true,
  });

  factory MenuConfig.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    // Guard fallback function: defaults to true if the feature key is missing or null
    bool getValue(String key) {
      if (!data.containsKey(key) || data[key] == null) {
        return true;
      }

      final value = data[key];
      if (value is bool) {
        return value;
      }
      if (value is Map && value.containsKey('enabled')) {
        return value['enabled'] == true;
      }
      return value == '1' || value == 1 || value.toString().toLowerCase() == 'true';
    }

    return MenuConfig(
      floorPlan: getValue('floor_plan'),
      exhibitors: getValue('exhibitors'),
      speakers: getValue('speakers'),
      program: getValue('program'),
      sponsors: getValue('sponsors'),
      partners: getValue('partners'),
      badge: getValue('badge'),
      products: getValue('products'),
      networking: getValue('networking'),
      congresses: getValue('congresses') || data.containsKey('conferences') ? getValue('conferences') : true,
    );
  }
}

class MenuProvider with ChangeNotifier {
  // Pre-populated with default configurations to eliminate secondary visual layout shifts
  MenuConfig _menuConfig = MenuConfig();
  MenuConfig get menuConfig => _menuConfig;

  /// Fetches and updates dynamic menu visibility rules from global configuration settings
  Future<void> fetchMenuConfig() async {
    // 🔗 Centralized dynamic endpoint path configuration
    final String apiUrl = '${AppConfig.baseUrl}/api/events/${AppConfig.eventId}/app-settings';
    debugPrint("🔍 [MenuProvider] Fetching layout settings from: $apiUrl");

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        _menuConfig = MenuConfig.fromJson(jsonResponse);
        debugPrint("✅ [MenuProvider] MenuConfig unified with Fallback logic successfully!");
      } else {
        debugPrint('⚠️ [MenuProvider] Server Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [MenuProvider] Connection Error: $e');
    }
    notifyListeners();
  }
}