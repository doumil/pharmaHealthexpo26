// lib/main/welcome_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:pharma_health_expo/program_screen.dart';
import 'package:pharma_health_expo/model/user_model.dart';
import 'package:pharma_health_expo/home_screen.dart';
import 'package:pharma_health_expo/Exhibitors.dart';
import 'package:pharma_health_expo/Contact.dart';
import 'package:pharma_health_expo/Information.dart';
import 'package:pharma_health_expo/Media%20Partners.dart';
import 'package:pharma_health_expo/Notifications.dart';
import 'package:pharma_health_expo/Official%20events.dart';
import 'package:pharma_health_expo/Speakers.dart';
import 'package:pharma_health_expo/partners.dart';
import 'package:pharma_health_expo/My%20Agenda.dart';
import 'package:pharma_health_expo/Suporting%20Partners.dart';
import 'package:pharma_health_expo/details/CongressMenu.dart';
import 'package:pharma_health_expo/my_drawer_header.dart';
import 'package:pharma_health_expo/Schedule.dart';
import 'package:pharma_health_expo/networking.dart';
import 'package:pharma_health_expo/app_user_guide_screen.dart';
import 'package:pharma_health_expo/my_profile_screen.dart';
import 'package:pharma_health_expo/my_badge_screen.dart';
import 'package:pharma_health_expo/favourites_screen.dart';
import 'package:pharma_health_expo/scanned_badges_screen.dart';
import 'package:pharma_health_expo/ExpoFloorPlan.dart';
import 'package:pharma_health_expo/meeting_ratings_screen.dart';
import 'package:pharma_health_expo/model/app_theme_data.dart';
import 'package:pharma_health_expo/providers/theme_provider.dart';
import 'package:pharma_health_expo/providers/menu_provider.dart';
import 'package:pharma_health_expo/constants.dart';
import 'package:pharma_health_expo/global/app_config.dart';
import 'package:pharma_health_expo/api_services/notification_timer.dart';
import '../main.dart';
import 'welcome_logic.dart';
import 'app_drawer_list.dart';

class DullPage extends StatelessWidget {
  final String title;
  const DullPage({Key? key, this.title = 'Dull Page'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(child: Text('This page is a work in progress.', style: TextStyle(fontSize: 18))),
    );
  }
}

class WelcomPage extends StatefulWidget {
  final User? user;
  const WelcomPage({Key? key, this.user}) : super(key: key);

  @override
  _WelcomPageState createState() => _WelcomPageState();
}

class _WelcomPageState extends State<WelcomPage> with WidgetsBindingObserver {
  var currentPage = DrawerSections.home;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  User? _loggedInUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WelcomeLogic.fetchAndSyncBadgeImmediately();
    _loadUser();
    NotificationTimer.start(notificationCountNotifier);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    NotificationTimer.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      debugPrint("📱 App resumed from background. Syncing badge and notifications...");
      WelcomeLogic.fetchAndSyncBadgeImmediately();
    }
  }

  Future<void> _loadUser() async {
    User? user = await WelcomeLogic.initializeUserAndLoadData(context, widget.user);
    if (mounted) {
      setState(() {
        _loggedInUser = user;
      });
    }
  }

  Future<void> _showLogoutDialog(BuildContext context, AppThemeData theme) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const SingleChildScrollView(child: ListBody(children: <Widget>[Text('Are you sure you want to log out?')],)),
          actions: <Widget>[
            TextButton(child: Text('Cancel', style: TextStyle(color: theme.primaryColor)), onPressed: () => Navigator.of(context).pop()),
            TextButton(child: Text('Logout', style: TextStyle(color: theme.secondaryColor, fontWeight: FontWeight.bold)), onPressed: () { Navigator.of(context).pop(); WelcomeLogic.performLogout(context); }),
          ],
        );
      },
    );
  }

  void _onNavigateToSection(DrawerSections section) {
    setState(() { currentPage = section; });
    if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) { Navigator.pop(context); }
  }

  void _handleProtectedNavigation(DrawerSections section) {
    WelcomeLogic.navigateToSectionProtected(
      context: context,
      section: section,
      scaffoldKey: _scaffoldKey,
      onNavigateCallback: _onNavigateToSection,
    );
  }

  bool get _isUserLoggedIn {
    return (_loggedInUser?.token != null && _loggedInUser!.token!.isNotEmpty) ||
        (widget.user?.token != null && widget.user!.token!.isNotEmpty);
  }

  int _getBottomNavIndexForBottomNav() {
    if (currentPage == DrawerSections.home) return 0;
    if (_isUserLoggedIn && currentPage == DrawerSections.notifications) return 1;
    return 0;
  }

  Future<bool> _onWillPop() async {
    if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) { Navigator.pop(context); return false; }
    if (currentPage != DrawerSections.home) { _onNavigateToSection(DrawerSections.home); return false; }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    // اعتماد User أولي فوري باش ميبقاش أي لودينغ أبيض فالبداية، وتتكلف HomeScreen بالتحميل الداخلي
    User currentUser = _loggedInUser ?? widget.user ?? User(id: 0, name: "", email: "", token: "");
    Widget container;

    if (currentPage == DrawerSections.home) container = HomeScreen(user: currentUser, onNavigate: _handleProtectedNavigation);
    else if (currentPage == DrawerSections.program) container = const ProgramScreen();
    else if (currentPage == DrawerSections.networking) container = NetworkinScreen(authToken: currentUser.token ?? "");
    else if (currentPage == DrawerSections.myAgenda) container = AgendaScreen();
    else if (currentPage == DrawerSections.speakers) container = SpeakersScreen();
    else if (currentPage == DrawerSections.officialEvents) container = OfficialEventsScreen();
    else if (currentPage == DrawerSections.partners) container = PartnersScreen();
    else if (currentPage == DrawerSections.exhibitors) container = ExhibitorsScreen();
    else if (currentPage == DrawerSections.eFP) container = ExpoFloorPlan();
    else if (currentPage == DrawerSections.supportingP) container = SupportingPScreen();
    else if (currentPage == DrawerSections.mediaP) container = MediaPScreen();
    else if (currentPage == DrawerSections.contact) container = ContactScreen();
    else if (currentPage == DrawerSections.information) container = InformationScreen();
    else if (currentPage == DrawerSections.schedule) container = SchelduleScreen();
    else if (currentPage == DrawerSections.notifications) container = NotificationsScreen();
    else if (currentPage == DrawerSections.congressmenu) container = CongressMenu();
    else if (currentPage == DrawerSections.appUserGuide) container = const AppUserGuideScreen();
    else if (currentPage == DrawerSections.myProfile) container = MyProfileScreen(user: currentUser);
    else if (currentPage == DrawerSections.myBadge) container = MyBadgeScreen(user: currentUser);
    else if (currentPage == DrawerSections.favourites) container = const FavouritesScreen();
    else if (currentPage == DrawerSections.scannedBadges) container = ScannedBadgesScreen(user: currentUser);
    else if (currentPage == DrawerSections.meetingRatings) container = const MeetingRatingsScreen();
    else if (currentPage == DrawerSections.sponsors) container = SupportingPScreen();
    else container = Center(child: const DullPage(title: 'Page Not Found'));

    final List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      if (_isUserLoggedIn)
        BottomNavigationBarItem(
          icon: ValueListenableBuilder<int>(
            valueListenable: notificationCountNotifier,
            builder: (context, count, child) {
              return badges.Badge(
                showBadge: count > 0,
                badgeContent: Text(count.toString(), style: TextStyle(color: theme.whiteColor, fontSize: 10)),
                badgeStyle: badges.BadgeStyle(badgeColor: theme.redColor, padding: const EdgeInsets.all(5)),
                position: badges.BadgePosition.topEnd(top: -10, end: -12),
                child: const Icon(Icons.notifications),
              );
            },
          ),
          label: 'Notifications',
        ),
      const BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        body: container,
        endDrawer: Drawer(
          backgroundColor: theme.primaryColor,
          child: SafeArea(
            top: true,
            bottom: false,
            left: false,
            right: false,
            child: SingleChildScrollView(
              child: Container(
                color: theme.primaryColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyHeaderDrawer(user: currentUser, onLogout: () => WelcomeLogic.performLogout(context)),
                    const SizedBox(height: 5.0),
                    Consumer<MenuProvider>(
                      builder: (context, menuProvider, child) {
                        final menuConfig = menuProvider.menuConfig;

                        return AppDrawerList(
                          menuConfig: menuConfig,
                          onNavigate: _handleProtectedNavigation,
                          currentSection: currentPage,
                          showLogoutDialog: _showLogoutDialog,
                          appTheme: theme,
                          isLoggedIn: _isUserLoggedIn,
                        );
                      },
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          AppConfig.version,
                          style: TextStyle(
                            color: theme.whiteColor.withOpacity(0.5),
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: navItems,
          currentIndex: _getBottomNavIndexForBottomNav(),
          selectedItemColor: theme.secondaryColor,
          unselectedItemColor: theme.whiteColor,
          backgroundColor: theme.primaryColor,
          onTap: (index) async {
            if (!_isUserLoggedIn) {
              if (index == 0) {
                _handleProtectedNavigation(DrawerSections.home);
              } else if (index == 1) {
                _scaffoldKey.currentState?.openEndDrawer();
              }
            } else {
              if (index == 0) {
                _handleProtectedNavigation(DrawerSections.home);
              } else if (index == 1) {
                _handleProtectedNavigation(DrawerSections.notifications);
                notificationCountNotifier.value = 0;
                try { await AppBadgePlus.updateBadge(0); } catch (_) {}
              } else if (index == 2) {
                _scaffoldKey.currentState?.openEndDrawer();
              }
            }
          },
        ),
      ),
    );
  }
}