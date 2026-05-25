import 'package:flutter/material.dart';
import 'package:pharma_health_expo/providers/app_config_provider.dart';

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

  List<CardItem> get cards => _cards;

  HomeProvider() {
    _cards = _getDefaultCards();
  }

  /// هاد الميثود كتاخد الـ config من AppConfigProvider وكتحدث البطاقات أوتوماتيكياً
  void updateCardsFromConfig(AppConfigProvider configProvider) {
    final Map<String, dynamic>? data = configProvider.rawSettings;

    if (data == null) return;

    // دالة محسنة كتشيك الحالة ديال الـ Key فـ الـ JSON
    String checkState(String dataKey) {
      final value = data[dataKey];

      // منطق مرن: إلا كان false أو 0 أو null، الكارت كتعطل
      if (value == false || value == 0 || value == '0' || value == null) {
        return '0';
      }
      return '1'; // القيمة الافتراضية للتشغيل
    }

    _cards = _getDefaultCards().map((card) {
      final String status = checkState(card.apiKey);
      return card.copyWith(dataValue: status);
    }).toList();

    notifyListeners();
  }

  // القائمة الافتراضية - تأكد أن الـ apiKey مطابق تماماً للـ Keys فـ الـ JSON ديالك
  List<CardItem> _getDefaultCards() {
    return [
      CardItem(title: 'My Badge', iconName: 'qr_code_scanner', dataValue: '1', isCustomCard: true, apiKey: 'badge'),
      CardItem(title: 'Floor Plan', iconName: 'location_on_outlined', dataValue: '1', apiKey: 'floor_plan'),
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

// Helper mapping to retrieve Material Icon Data
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