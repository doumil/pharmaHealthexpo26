import 'package:flutter/material.dart';
import 'package:pharma_health_expo/providers/app_config_provider.dart';
import 'package:pharma_health_expo/constants.dart'; // تأكد من الـ Import ديال DrawerSections

class MenuItem {
  final String title;
  final IconData icon;
  final DrawerSections section;
  final bool isCustomCard;

  MenuItem({
    required this.title,
    required this.icon,
    required this.section,
    this.isCustomCard = false,
  });
}

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
  });

  factory MenuConfig.fromRawData(Map<String, dynamic> data) {
    bool getValue(String key) {
      final value = data[key];
      if (value == null) return true;
      if (value is bool) return value;
      if (value is Map && value.containsKey('enabled')) {
        return value['enabled'] == true;
      }
      return value.toString() == '1' || value.toString().toLowerCase() == 'true';
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
    );
  }
}

class MenuProvider with ChangeNotifier {
  MenuConfig? _menuConfig;
  MenuConfig? get menuConfig => _menuConfig;

  List<MenuItem> _visibleItems = [];
  List<MenuItem> get visibleItems => _visibleItems;

  /// هاد الميثود كتستقبل الداتا من AppConfigProvider وكتحدث القائمة وتصفيها أوتوماتيكياً
  void updateMenuFromConfig(AppConfigProvider configProvider) {
    final Map<String, dynamic>? data = configProvider.rawSettings;

    if (data != null) {
      _menuConfig = MenuConfig.fromRawData(data);
      _generateVisibleItems();
      notifyListeners();
      debugPrint("✅ [MenuProvider] Menu updated and filtered successfully.");
    }
  }

  /// بناء وتصفية الكروت الشغالة فقط (إلى كانت false كتختفي تماماً)
  void _generateVisibleItems() {
    if (_menuConfig == null) return;

    final List<Map<String, dynamic>> allItems = [
      {'title': 'My Badge', 'icon': Icons.qr_code_scanner, 'section': DrawerSections.myBadge, 'status': _menuConfig!.badge, 'custom': true},
      {'title': 'Floor Plan', 'icon': Icons.location_on_outlined, 'section': DrawerSections.eFP, 'status': _menuConfig!.floorPlan},
      {'title': 'My Agenda', 'icon': Icons.calendar_today_outlined, 'section': DrawerSections.myAgenda, 'status': _menuConfig!.program},
      {'title': 'Exhibitors', 'icon': Icons.store_mall_directory_outlined, 'section': DrawerSections.exhibitors, 'status': _menuConfig!.exhibitors},
      {'title': 'Networking', 'icon': Icons.people_outline, 'section': DrawerSections.networking, 'status': _menuConfig!.networking},
      {'title': 'Products', 'icon': Icons.category_outlined, 'section': DrawerSections.products, 'status': _menuConfig!.products},
      {'title': 'Speakers', 'icon': Icons.person_outline, 'section': DrawerSections.speakers, 'status': _menuConfig!.speakers},
      {'title': 'Institutional\nPartners', 'icon': Icons.handshake_outlined, 'section': DrawerSections.partners, 'status': _menuConfig!.partners},
      {'title': 'Sponsors', 'icon': Icons.favorite_outline, 'section': DrawerSections.sponsors, 'status': _menuConfig!.sponsors},
    ];

    _visibleItems = allItems
        .where((item) => item['status'] == true) // الفلترة الحقيقية هنا لمنع الكروت الطافية من الظهور
        .map((item) => MenuItem(
      title: item['title'] as String,
      icon: item['icon'] as IconData,
      section: item['section'] as DrawerSections,
      isCustomCard: item['custom'] == true,
    ))
        .toList();
  }
}