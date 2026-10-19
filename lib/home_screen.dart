// lib/home_screen.dart
import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pharma_health_expo/services/onwillpop_services.dart';
import 'package:pharma_health_expo/constants.dart';
import 'package:pharma_health_expo/model/user_model.dart';
import 'package:pharma_health_expo/login_screen.dart';
import 'package:pharma_health_expo/providers/menu_provider.dart';
import 'package:pharma_health_expo/providers/theme_provider.dart';
import 'package:pharma_health_expo/providers/app_config_provider.dart';
import 'package:pharma_health_expo/global/app_config.dart';
import 'package:pharma_health_expo/auth_popup.dart';
import 'package:pharma_health_expo/api_services/event_contact_api_service.dart';
import 'package:pharma_health_expo/model/event_contact_model.dart';
import 'package:pharma_health_expo/model/app_theme_data.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final DrawerSections section;
  final bool isCustomCard;
  final bool isEnabled;

  MenuItem({
    required this.title,
    required this.icon,
    required this.section,
    this.isCustomCard = false,
    required this.isEnabled,
  });
}

class HomeScreen extends StatefulWidget {
  final User? user;
  final OnNavigateCallback onNavigate;

  const HomeScreen({Key? key, this.user, required this.onNavigate}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _loggedInUser;
  late SharedPreferences prefs;
  bool _isLoggedIn = false;

  final EventContactApiService _contactApiService = EventContactApiService();
  late Future<EventContactModel?> _eventDetailsFuture;

  @override
  void initState() {
    super.initState();
    _initializeUserAndToken();
    _eventDetailsFuture = _contactApiService.fetchEventDetails();
  }

  Future<void> _initializeUserAndToken() async {
    prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('authToken');
    User? userFromWidget = widget.user;
    User? userFromPrefs;

    final String? userJsonString = prefs.getString('currentUserJson');
    if (userJsonString != null) {
      try {
        final Map<String, dynamic> userMap = json.decode(userJsonString);
        userFromPrefs = User.fromJson(userMap);
      } catch (e) {
        debugPrint("Error parsing stored user JSON: $e");
        await prefs.remove('currentUserJson');
      }
    }

    setState(() {
      _isLoggedIn = authToken != null && authToken.isNotEmpty;
      _loggedInUser = userFromWidget ?? userFromPrefs;
    });
  }

  Future<void> _launchMapUrl(String address) async {
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  List<MenuItem> _getAllMenuItems(MenuConfig? menuConfig) {
    final bool isProgramActive = menuConfig?.program ?? true;

    return [
      MenuItem(title: 'My Badge', icon: Icons.qr_code_scanner, section: DrawerSections.myBadge, isCustomCard: true, isEnabled: menuConfig?.badge ?? true),
      MenuItem(title: 'Floor Plan', icon: Icons.location_on_outlined, section: DrawerSections.eFP, isEnabled: menuConfig?.floorPlan ?? true),
      MenuItem(title: 'My Agenda', icon: Icons.calendar_today_outlined, section: DrawerSections.myAgenda, isEnabled: isProgramActive),
      MenuItem(title: 'Program', icon: Icons.event_note, section: DrawerSections.program, isEnabled: isProgramActive),
      MenuItem(title: 'Exhibitors', icon: Icons.store_mall_directory_outlined, section: DrawerSections.exhibitors, isEnabled: menuConfig?.exhibitors ?? true),
      MenuItem(title: 'Networking', icon: Icons.people_outline, section: DrawerSections.networking, isEnabled: menuConfig?.networking ?? true),
      MenuItem(title: 'Speakers', icon: Icons.person_outline, section: DrawerSections.speakers, isEnabled: menuConfig?.speakers ?? true),
      MenuItem(title: 'Partners', icon: Icons.handshake_outlined, section: DrawerSections.partners, isEnabled: menuConfig?.partners ?? true),
      MenuItem(title: 'Sponsors', icon: Icons.favorite_outline, section: DrawerSections.sponsors, isEnabled: menuConfig?.sponsors ?? true),
    ];
  }

  Widget _buildFlexibleMenuCard({
    required BuildContext context,
    required MenuItem item,
    required double cardHeight,
    required double iconSize,
    required double fontSize,
    required double horizontalPadding,
    required ThemeProvider themeProvider,
    bool isWide = false,
  }) {
    final theme = themeProvider.currentTheme;

    CrossAxisAlignment alignment = CrossAxisAlignment.center;
    if (isWide && item.title != 'My Badge') {
      alignment = CrossAxisAlignment.start;
    }

    return GestureDetector(
      onTap: item.isEnabled ? () {
        bool isProtected = item.section == DrawerSections.myBadge ||
            item.section == DrawerSections.myAgenda ||
            item.section == DrawerSections.networking;

        if (!_isLoggedIn && isProtected) {
          AuthPopup.show(context);
        } else {
          widget.onNavigate(item.section);
        }
      } : null,
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          color: item.isEnabled
              ? theme.primaryColor.withOpacity(0.18)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
              color: item.isEnabled
                  ? theme.whiteColor.withOpacity(0.15)
                  : Colors.white.withOpacity(0.05)
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: isWide ? 15 : 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: alignment,
          children: <Widget>[
            Icon(
              item.icon,
              size: iconSize,
              color: item.isEnabled ? theme.secondaryColor : Colors.white30,
            ),
            SizedBox(height: isWide ? 12.0 : 8.0),
            Text(
              item.title,
              textAlign: alignment == CrossAxisAlignment.start ? TextAlign.left : TextAlign.center,
              style: TextStyle(
                color: item.isEnabled ? theme.whiteColor : Colors.white30,
                fontSize: fontSize,
                fontWeight: isWide ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateShort(String dateString) {
    final dateTime = DateTime.tryParse(dateString);
    if (dateTime == null) return dateString;
    final monthMap = {1: 'Jan', 2: 'Feb', 3: 'Mar', 4: 'Apr', 5: 'May', 6: 'Jun', 7: 'Jul', 8: 'Aug', 9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dec'};
    return '${dateTime.day} ${monthMap[dateTime.month]}';
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    final themeProvider = Provider.of<ThemeProvider>(context);
    final configProvider = Provider.of<AppConfigProvider>(context);
    final theme = themeProvider.currentTheme;

    // جلب قائمة الصور السلايدات من AppConfigProvider
    final List<String> slides = configProvider.slides;

    return Consumer<MenuProvider>(
      builder: (context, menuProvider, child) {
        final menuConfig = menuProvider.menuConfig;
        final List<MenuItem> allMenuItems = _getAllMenuItems(menuConfig);
        final int itemCount = allMenuItems.length;

        final List<Widget> menuWidgets = [];
        int index = 0;
        final double hSpacing = width * 0.03;
        final double vSpacing = height * 0.025;

        if (itemCount > 0) {
          bool isFirstRowSpecial = ((itemCount % 2 != 0) || allMenuItems[0].isCustomCard) && itemCount >= 3;

          if (isFirstRowSpecial) {
            if (itemCount >= 3 && allMenuItems[0].isCustomCard) {
              final bigCard = _buildFlexibleMenuCard(
                context: context,
                item: allMenuItems[index],
                cardHeight: height * 0.28,
                iconSize: 60,
                fontSize: 22.0,
                horizontalPadding: width * 0.05,
                themeProvider: themeProvider,
                isWide: true,
              );

              final smallCard1 = _buildFlexibleMenuCard(
                context: context,
                item: allMenuItems[index + 1],
                cardHeight: height * 0.13,
                iconSize: 40,
                fontSize: 15.0,
                horizontalPadding: width * 0.08,
                themeProvider: themeProvider,
              );

              final smallCard2 = _buildFlexibleMenuCard(
                context: context,
                item: allMenuItems[index + 2],
                cardHeight: height * 0.13,
                iconSize: 40,
                fontSize: 15.0,
                horizontalPadding: width * 0.08,
                themeProvider: themeProvider,
              );

              menuWidgets.add(
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: bigCard),
                    SizedBox(width: hSpacing),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          smallCard1,
                          SizedBox(height: height * 0.018),
                          smallCard2,
                        ],
                      ),
                    ),
                  ],
                ),
              );
              menuWidgets.add(SizedBox(height: vSpacing));
              index += 3;
            }
          }

          while (itemCount - index >= 2) {
            final card1 = _buildFlexibleMenuCard(
              context: context,
              item: allMenuItems[index],
              cardHeight: height * 0.2,
              iconSize: 40,
              fontSize: 15.0,
              horizontalPadding: width * 0.03,
              themeProvider: themeProvider,
            );
            final card2 = _buildFlexibleMenuCard(
              context: context,
              item: allMenuItems[index + 1],
              cardHeight: height * 0.2,
              iconSize: 40,
              fontSize: 15.0,
              horizontalPadding: width * 0.03,
              themeProvider: themeProvider,
            );

            menuWidgets.add(
              Row(
                children: [
                  Expanded(child: card1),
                  SizedBox(width: hSpacing),
                  Expanded(child: card2),
                ],
              ),
            );
            menuWidgets.add(SizedBox(height: vSpacing));
            index += 2;
          }

          if (itemCount - index == 1) {
            final singleCard = _buildFlexibleMenuCard(
              context: context,
              item: allMenuItems[index],
              cardHeight: height * 0.2,
              iconSize: 40,
              fontSize: 15.0,
              horizontalPadding: width * 0.03,
              themeProvider: themeProvider,
            );

            menuWidgets.add(
              Row(
                children: [
                  Expanded(child: singleCard),
                  Expanded(child: const SizedBox()),
                ],
              ),
            );
            menuWidgets.add(SizedBox(height: vSpacing));
          }
        }

        return WillPopScope(
          onWillPop: OnWillPop().onWillPop1,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: theme.blackColor,
              centerTitle: true,
              title: Text(
                "Pharma Health Expo",
                style: TextStyle(
                  color: theme.whiteColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              elevation: 0,
            ),
            body: FutureBuilder<EventContactModel?>(
              future: _eventDetailsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.blackColor,
                          theme.primaryColor.withOpacity(0.9),
                        ],
                      ),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: theme.secondaryColor,
                      ),
                    ),
                  );
                }

                String dateText = "Loading dates...";
                String locationText = "DoubleTree by Hilton Casablanca";

                if (snapshot.hasData && snapshot.data != null) {
                  final eventData = snapshot.data!;
                  dateText = "${_formatDateShort(eventData.scheduledStartDate)} - ${_formatDateShort(eventData.scheduledEndDate)} ${DateTime.tryParse(eventData.scheduledStartDate)?.year ?? ''}";
                }

                return LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints viewportConstraints) {
                    return SingleChildScrollView(
                      child: FadeInDown(
                        duration: const Duration(milliseconds: 500),
                        child: Container(
                          constraints: BoxConstraints(
                            minHeight: viewportConstraints.maxHeight,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                theme.blackColor,
                                theme.primaryColor.withOpacity(0.9),
                              ],
                            ),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.02),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 1. Slides Carousel مع إضافة Headers لتفادي حجب السيرفر (403 Forbidden)
                              if (slides.isNotEmpty) ...[
                                SizedBox(
                                  height: height * 0.22,
                                  child: PageView.builder(
                                    itemCount: slides.length,
                                    itemBuilder: (context, index) {
                                      final imageUrl = slides[index];
                                      return Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: theme.secondaryColor.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            headers: const {
                                              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                                              'Accept': 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
                                            },
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Center(
                                                child: CircularProgressIndicator(
                                                  color: theme.secondaryColor,
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) {
                                              debugPrint("⚠️ Slide image loading failed: $error");
                                              return Container(
                                                color: Colors.black26,
                                                child: const Center(
                                                  child: Icon(Icons.broken_image, color: Colors.white54, size: 40),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: height * 0.02),
                              ],

                              // 2. Info Cards (Dates & Time)
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: theme.primaryColor.withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: theme.whiteColor.withOpacity(0.15)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.calendar_today_rounded, color: theme.secondaryColor, size: 22),
                                          const SizedBox(height: 8),
                                          Text(
                                            dateText,
                                            style: TextStyle(
                                              color: theme.whiteColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: width * 0.03),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: theme.primaryColor.withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: theme.whiteColor.withOpacity(0.15)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.access_time_rounded, color: theme.secondaryColor, size: 22),
                                          const SizedBox(height: 8),
                                          Text(
                                            "9:00 AM to 7:00 PM",
                                            style: TextStyle(
                                              color: theme.whiteColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: height * 0.015),

                              // Location Card
                              GestureDetector(
                                onTap: () => _launchMapUrl(locationText),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: theme.whiteColor.withOpacity(0.15)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.location_on_rounded, color: theme.secondaryColor, size: 24),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          locationText,
                                          style: TextStyle(
                                            color: theme.whiteColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Icon(Icons.open_in_new, size: 18, color: theme.whiteColor.withOpacity(0.7)),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: height * 0.025),

                              // 3. Main Menu Grid Cards
                              ...menuWidgets,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}