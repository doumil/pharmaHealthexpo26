// lib/providers/home_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharma_health_expo/global/app_config.dart';

class CardItem {
  final String title;
  final String iconName;
  final String dataValue; // '1' means enabled, '0' means disabled
  final bool isCustomCard;
  final String apiKey;

  CardItem({
    required this.title,
    required this.iconName,
    required this.dataValue,
    this.isCustomCard = false,
    required this.apiKey,
  });

  factory CardItem.fromJson(Map<String, dynamic> json) {
    return CardItem(
      title: json['title'] ?? '',
      iconName: json['iconName'] ?? '',
      dataValue: json['dataValue'] ?? '1',
      isCustomCard: json['isCustomCard'] == true,
      apiKey: json['apiKey'] ?? '',
    );
  }

  /// Creates a copy of the CardItem with updated parameters
  CardItem copyWith({String? dataValue}) {
    return CardItem(
      title: this.title,
      iconName: this.iconName,
      dataValue: dataValue ?? this.dataValue,
      isCustomCard: this.isCustomCard,
      apiKey: this.apiKey,
    );
  }
}

class HomeProvider with ChangeNotifier {
  List<CardItem> _cards = [];
  bool _isLoading = false;

  HomeProvider() {
    // Populate with immediate default cards to prevent UI blank screens
    _cards = _getDefaultCards();
  }

  List<CardItem> get cards => _cards;
  bool get isLoading => _isLoading;

  /// Fetches application configuration and feature flags dynamically from the API
  Future<void> fetchCards() async {
    // 🔗 Centralized dynamic URL construction using global configuration
    final String url = '${AppConfig.baseUrl}/api/events/${AppConfig.eventId}/app-settings';
    debugPrint("🔍 [HomeProvider] Fetching dashboard cards from: $url");

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final data = jsonResponse['data'] as Map<String, dynamic>? ?? {};

        // Fallback guard logic: defaults to '1' (enabled) unless API explicitly restricts it
        String checkState(String apiKey, String dataKey) {
          if (!data.containsKey(dataKey) || data[dataKey] == null) {
            return '1';
          }
          final val = data[dataKey];
          if (val == false || val == 0 || val == '0') return '0';
          return '1';
        }

        final List<CardItem> baseCards = _getDefaultCards();
        _cards = baseCards.map((card) {
          if (card.apiKey == 'badge') {
            return card.copyWith(dataValue: checkState('badge', 'badge'));
          } else if (card.apiKey == 'floorPlan') {
            return card.copyWith(dataValue: checkState('floorPlan', 'floor_plan'));
          } else if (card.apiKey == 'program') {
            return card.copyWith(dataValue: checkState('program', 'program'));
          } else if (card.apiKey == 'exhibitors') {
            return card.copyWith(dataValue: checkState('exhibitors', 'exhibitors'));
          } else if (card.apiKey == 'speakers') {
            return card.copyWith(dataValue: checkState('speakers', 'speakers'));
          } else if (card.apiKey == 'partners') {
            return card.copyWith(dataValue: checkState('partners', 'partners'));
          } else if (card.apiKey == 'sponsors') {
            return card.copyWith(dataValue: checkState('sponsors', 'sponsors'));
          }
          // Default fallback state for offline or unmapped keys
          return card.copyWith(dataValue: '1');
        }).toList();

        debugPrint("✅ [HomeProvider] Cards updated with API States and Fallbacks.");
      } else {
        debugPrint("⚠️ [HomeProvider] Failed: ${response.statusCode}");
        _cards = _getDefaultCards();
      }
    } catch (e) {
      debugPrint('❌ [HomeProvider] Error: $e');
      _cards = _getDefaultCards();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Returns the system default configuration for static app cards
  List<CardItem> _getDefaultCards() {
    return [
      CardItem(title: 'My Badge', iconName: 'qr_code_scanner', dataValue: '1', isCustomCard: true, apiKey: 'badge'),
      CardItem(title: 'Floor Plan', iconName: 'location_on_outlined', dataValue: '1', apiKey: 'floorPlan'),
      CardItem(title: 'Networking', iconName: 'people_outline', dataValue: '1', apiKey: 'networking'),
      CardItem(title: 'Exhibitors', iconName: 'store_mall_directory_outlined', dataValue: '1', apiKey: 'exhibitors'),
      CardItem(title: 'Products', iconName: 'category_outlined', dataValue: '1', apiKey: 'products'),
      CardItem(title: 'Conferences', iconName: 'speaker_notes_outlined', dataValue: '1', apiKey: 'speakers'),
      CardItem(title: 'My Agenda', iconName: 'calendar_today_outlined', dataValue: '1', apiKey: 'program'),
      CardItem(title: 'Institutional\nPartners', iconName: 'handshake_outlined', dataValue: '1', apiKey: 'partners'),
      CardItem(title: 'Sponsors', iconName: 'favorite_outline', dataValue: '1', apiKey: 'sponsors'),
    ];
  }
}

/// Helper mapping to retrieve Material Icon Data from dynamic string identifiers
IconData getIconDataFromString(String iconName) {
  switch (iconName) {
    case 'qr_code_scanner': return Icons.qr_code_scanner;
    case 'location_on_outlined': return Icons.location_on_outlined;
    case 'people_outline': return Icons.people_outline;
    case 'store_mall_directory_outlined': return Icons.store_mall_directory_outlined;
    case 'category_outlined': return Icons.category_outlined;
    case 'speaker_notes_outlined': return Icons.speaker_notes_outlined;
    case 'calendar_today_outlined': return Icons.calendar_today_outlined;
    case 'handshake_outlined': return Icons.handshake_outlined;
    case 'favorite_outline': return Icons.favorite_outline;
    default: return Icons.error;
  }
}