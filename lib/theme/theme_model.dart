import 'package:flutter/material.dart';

class ApiTheme {
  final String primaryColorHex;
  final String iconName;
  final String menuType;

  ApiTheme({
    required this.primaryColorHex,
    required this.iconName,
    required this.menuType,
  });

  factory ApiTheme.fromJson(Map<String, dynamic> json) {
    return ApiTheme(
      primaryColorHex: json['primaryColorHex'] ?? '00c1c1',
      iconName: json['iconName'] ?? 'home',
      menuType: json['menuType'] ?? 'default',
    );
  }
}

class ThemeModel with ChangeNotifier {
  // 🎨 Your global colors
  Color get primaryColor => const Color(0xff261350);
  Color get accentColor => const Color(0xff00c1c1);
  Color get drawerHeaderColor => const Color(0xff261350);
  Color get drawerTextColor => Colors.white;
  Color get drawerDividerColor => Colors.white24;

  // 🖼️ Your global icons
  IconData get homeIcon => Icons.home_outlined;
  IconData get notificationsIcon => Icons.notifications_none;
  IconData get userGuideIcon => Icons.menu_book;
  IconData get floorPlanIcon => Icons.location_on_outlined;
  IconData get exhibitorsIcon => Icons.work_outline;
  IconData get productIcon => Icons.shopping_bag_outlined;
  IconData get speakersIcon => Icons.speaker_group_outlined;
  IconData get congressesIcon => Icons.account_balance;
  IconData get sponsorsIcon => Icons.star_border;
  IconData get partnersIcon => Icons.handshake;
  IconData get myProfileIcon => Icons.person_outline;
  IconData get myBadgeIcon => Icons.badge;
  IconData get favouritesIcon => Icons.favorite_border;
  IconData get scannedBadgesIcon => Icons.qr_code_scanner;
  IconData get messagesIcon => Icons.message_outlined;
  IconData get myAgendaIcon => Icons.calendar_today;
  IconData get meetingRatingsIcon => Icons.star_half;
  IconData get networkingIcon => Icons.share_rounded;
  IconData get contactIcon => Icons.contact_phone_outlined;
  IconData get getThereIcon => Icons.map;
  IconData get socialMediaIcon => Icons.language;
  IconData get settingsIcon => Icons.settings;

  // 📋 The new variable to store the menu type
  String currentMenu = 'default';

  // Function to update the theme from an API response
  void updateThemeFromApi(ApiTheme apiTheme) {
    // This is a simplified example.
    // You would replace this with actual logic to parse the API response
    // and set the colors, icons, and menu type.
    currentMenu = apiTheme.menuType;

    // Notify listeners so the UI rebuilds with the new menu
    notifyListeners();
  }
}