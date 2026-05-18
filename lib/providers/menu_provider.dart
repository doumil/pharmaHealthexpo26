// [lib/providers/menu_provider.dart]

import 'dart:convert'; // For using json.decode
import 'package:flutter/material.dart'; // For using ChangeNotifier
import 'package:http/http.dart' as http; // For API calls

// Data model for the API configuration
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
  final bool title;
  final bool description;
  final bool venue;
  final bool dates;
  final bool logo;
  final bool organizer;

  MenuConfig({
    required this.floorPlan,
    required this.exhibitors,
    required this.speakers,
    required this.program,
    required this.sponsors,
    required this.partners,
    required this.badge,
    this.products = false,
    this.networking = false,
    this.congresses = false,
    this.title = false,
    this.description = false,
    this.venue = false,
    this.dates = false,
    this.logo = false,
    this.organizer = false,
  });

  factory MenuConfig.fromJson(Map<String, dynamic> json) {
    // Safely extract boolean values from the 'data' field
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return MenuConfig(
      floorPlan: data['floor_plan'] == true,
      exhibitors: data['exhibitors'] == true,
      speakers: data['speakers'] == true,
      program: data['program'] == true,
      sponsors: data['sponsors'] == true,
      partners: data['partners'] == true,
      badge: data['badge'] == true,
      // Assuming these keys might exist in other API versions or need defaults
      products: data['products'] == true,
      networking: data['networking'] == true,
      congresses: data['congresses'] == true,

      title: data['title'] == true,
      description: data['description'] == true,
      venue: data['venue'] == true,
      dates: data['dates'] == true,
      logo: data['logo'] == true,
      organizer: data['organizer'] == true,
    );
  }
}

// FIX: Change MenuProvider to extend ChangeNotifier to define notifyListeners.
class MenuProvider extends ChangeNotifier {
  MenuConfig? _menuConfig;
  MenuConfig? get menuConfig => _menuConfig;

  // FIX: Use the actual API URL provided
  final String _apiUrl = 'https://buzzevents.co/api/events/10/app-settings';

  Future<void> fetchMenuConfig() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        _menuConfig = MenuConfig.fromJson(jsonResponse);
      } else {
        print('Failed to load menu config. Status code: ${response.statusCode}');
        _menuConfig = _getDefaultMenuConfig();
      }
    } catch (e) {
      print('Error fetching menu config: $e');
      _menuConfig = _getDefaultMenuConfig();
    }
    // FIX: notifyListeners is now defined and called
    notifyListeners();
  }

  MenuConfig _getDefaultMenuConfig() {
    // Provide a safe default configuration if API fails
    return MenuConfig(
      floorPlan: true, exhibitors: true, speakers: true, program: true,
      sponsors: true, partners: true, badge: true, products: true,
      networking: true, congresses: true,
    );
  }
}