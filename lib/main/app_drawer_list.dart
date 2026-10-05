// lib/main/app_drawer_list.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharma_health_expo/providers/theme_provider.dart';
import 'package:pharma_health_expo/providers/menu_provider.dart';
import 'package:pharma_health_expo/model/app_theme_data.dart';
import 'package:pharma_health_expo/constants.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:pharma_health_expo/auth_popup.dart';
import '../main.dart';

class AppDrawerList extends StatelessWidget {
  final MenuConfig? menuConfig;
  final OnNavigateCallback onNavigate;
  final DrawerSections currentSection;
  final Function(BuildContext context, AppThemeData theme) showLogoutDialog;
  final AppThemeData appTheme;
  final bool isLoggedIn;

  const AppDrawerList({
    Key? key,
    required this.menuConfig,
    required this.onNavigate,
    required this.currentSection,
    required this.showLogoutDialog,
    required this.appTheme,
    required this.isLoggedIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final floorPlanActive = menuConfig?.floorPlan ?? true;
    final programActive = menuConfig?.program ?? true;
    final exhibitorsActive = menuConfig?.exhibitors ?? true;
    final speakersActive = menuConfig?.speakers ?? true;
    final sponsorsActive = menuConfig?.sponsors ?? true;
    final partnersActive = menuConfig?.partners ?? true;
    final badgeActive = menuConfig?.badge ?? true;
    final networkingActive = menuConfig?.networking ?? true;

    return Container(
      color: themeProvider.currentTheme.primaryColor, // 🛑 زدنا هذي باش الـ Container يشد لون الثيم التحتاني وما يبانش اختلاف فاللون
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMenuItem(context, DrawerSections.home, "Home", Icons.home, currentSection == DrawerSections.home, onNavigate, true),
          const Divider(color: Colors.white24, height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              "EVENT INFORMATION",
              style: TextStyle(
                color: themeProvider.currentTheme.whiteColor.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildMenuItem(context, DrawerSections.eFP, "Floor Plan", Icons.location_on_outlined, currentSection == DrawerSections.eFP, onNavigate, floorPlanActive),
          _buildMenuItem(context, DrawerSections.program, "Program", Icons.calendar_today_outlined, currentSection == DrawerSections.program, onNavigate, programActive),
          _buildMenuItem(context, DrawerSections.exhibitors, "Exhibitors", Icons.store_mall_directory_outlined, currentSection == DrawerSections.exhibitors, onNavigate, exhibitorsActive),
          _buildMenuItem(context, DrawerSections.speakers, "Speakers", Icons.speaker_notes_outlined, currentSection == DrawerSections.speakers, onNavigate, speakersActive),
          _buildMenuItem(context, DrawerSections.sponsors, "Sponsors", Icons.favorite_outline, currentSection == DrawerSections.sponsors, onNavigate, sponsorsActive),
          _buildMenuItem(context, DrawerSections.partners, "Partners", Icons.handshake_outlined, currentSection == DrawerSections.partners, onNavigate, partnersActive),

          if (isLoggedIn) ...[
            const Divider(color: Colors.white24, height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                "ACCOUNT",
                style: TextStyle(
                  color: themeProvider.currentTheme.whiteColor.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildMenuItem(context, DrawerSections.myProfile, "My Profile", Icons.person_outline, currentSection == DrawerSections.myProfile, onNavigate, true),
            _buildMenuItem(context, DrawerSections.myBadge, "My Badge", Icons.badge_outlined, currentSection == DrawerSections.myBadge, onNavigate, badgeActive),
            _buildMenuItem(context, DrawerSections.scannedBadges, "Scanned Badges", Icons.qr_code_scanner, currentSection == DrawerSections.scannedBadges, onNavigate, true),
            _buildMenuItem(context, DrawerSections.myAgenda, "My Agenda", Icons.calendar_today_outlined, currentSection == DrawerSections.myAgenda, onNavigate, programActive),
            _buildMenuItem(context, DrawerSections.networking, "Networking", Icons.people_outline, currentSection == DrawerSections.networking, onNavigate, networkingActive),
          ],

          const Divider(color: Colors.white24, height: 20),
          _buildMenuItem(context, DrawerSections.contact, "Contact", Icons.contact_mail_outlined, currentSection == DrawerSections.contact, onNavigate, true),

          if (isLoggedIn)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () { showLogoutDialog(context, appTheme); },
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 24, color: themeProvider.currentTheme.secondaryColor),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          "Logout",
                          style: TextStyle(color: themeProvider.currentTheme.whiteColor, fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context,
      DrawerSections section,
      String title,
      IconData icon,
      bool selected,
      OnNavigateCallback onNavigate,
      bool isEnabled,
      ) {
    final theme = Provider.of<ThemeProvider>(context, listen: false);

    return Material(
      color: selected ? Colors.white12 : Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? () async {
          bool isProtectedSection = section == DrawerSections.myBadge ||
              section == DrawerSections.myAgenda ||
              section == DrawerSections.networking ||
              section == DrawerSections.myProfile ||
              section == DrawerSections.scannedBadges;

          if (!isLoggedIn && isProtectedSection) {
            final scaffoldState = Scaffold.maybeOf(context);
            if (scaffoldState?.isEndDrawerOpen ?? false) {
              Navigator.pop(context);
            }
            AuthPopup.show(context);
          } else {
            onNavigate(section);
            if (section == DrawerSections.notifications) {
              notificationCountNotifier.value = 0;
              try { await AppBadgePlus.updateBadge(0); } catch (_) {}
            }
          }
        } : null,
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isEnabled ? theme.currentTheme.secondaryColor : Colors.grey,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                        color: isEnabled ? theme.currentTheme.whiteColor : Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}