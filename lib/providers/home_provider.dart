import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Data model for a single card
class CardItem {
  final String title;
  final String iconName;
  final String dataValue;
  final bool isCustomCard;

  CardItem({
    required this.title,
    required this.iconName,
    required this.dataValue,
    this.isCustomCard = false,
  });

  // Factory constructor to create a CardItem from a JSON map
  factory CardItem.fromJson(Map<String, dynamic> json) {
    return CardItem(
      title: json['title'] ?? '',
      iconName: json['iconName'] ?? '',
      dataValue: json['dataValue'] ?? '',
      isCustomCard: json['isCustomCard'] ?? false,
    );
  }
}

// Provider to manage the list of cards
class HomeProvider with ChangeNotifier {
  List<CardItem> _cards = [];
  bool _isLoading = false;

  List<CardItem> get cards => _cards;
  bool get isLoading => _isLoading;

  // Placeholder for fetching data from an API
  Future<void> fetchCards() async {
    _isLoading = true;
    notifyListeners();

    // Replace with your actual API call
    try {
      final response = await http.get(Uri.parse('YOUR_API_ENDPOINT_FOR_CARDS_HERE'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        _cards = jsonList.map((json) => CardItem.fromJson(json)).toList();
      } else {
        // Fallback to a default list of cards if API call fails
        _cards = _getDefaultCards();
      }
    } catch (e) {
      print('Error fetching cards from API: $e');
      _cards = _getDefaultCards();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fallback data if the API is not available
  List<CardItem> _getDefaultCards() {
    return [
      CardItem(
        title: 'My Badge',
        iconName: 'qr_code_scanner',
        dataValue: '1',
        isCustomCard: true,
      ),
      CardItem(
        title: 'Floor Plan',
        iconName: 'location_on_outlined',
        dataValue: '1',
      ),
      CardItem(
        title: 'Networking',
        iconName: 'people_outline',
        dataValue: '2',
      ),
      CardItem(
        title: 'Exhibitors',
        iconName: 'store_mall_directory_outlined',
        dataValue: '1',
      ),
      CardItem(
        title: 'Products',
        iconName: 'category_outlined',
        dataValue: '2',
      ),
      CardItem(
        title: 'Conferences',
        iconName: 'speaker_notes_outlined',
        dataValue: '1',
      ),
      CardItem(
        title: 'My Agenda',
        iconName: 'calendar_today_outlined',
        dataValue: '2',
      ),
      CardItem(
        title: 'Institutional\nPartners',
        iconName: 'handshake_outlined',
        dataValue: '1',
      ),
      CardItem(
        title: 'Sponsors',
        iconName: 'favorite_outline',
        dataValue: '2',
      ),
    ];
  }
}

// Helper function to map string icon names to IconData objects
IconData getIconDataFromString(String iconName) {
  switch (iconName) {
    case 'qr_code_scanner':
      return Icons.qr_code_scanner;
    case 'location_on_outlined':
      return Icons.location_on_outlined;
    case 'people_outline':
      return Icons.people_outline;
    case 'store_mall_directory_outlined':
      return Icons.store_mall_directory_outlined;
    case 'category_outlined':
      return Icons.category_outlined;
    case 'speaker_notes_outlined':
      return Icons.speaker_notes_outlined;
    case 'calendar_today_outlined':
      return Icons.calendar_today_outlined;
    case 'handshake_outlined':
      return Icons.handshake_outlined;
    case 'favorite_outline':
      return Icons.favorite_outline;
    default:
      return Icons.error; // Fallback icon
  }
}