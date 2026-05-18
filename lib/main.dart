// lib/main.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:emecexpo/program_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:badges/badges.dart' as badges;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:emecexpo/services/onwillpop_services.dart';
import 'package:emecexpo/model/user_model.dart';
// Your custom imports
import 'package:emecexpo/login_screen.dart';
import 'package:emecexpo/home_screen.dart';
import 'package:emecexpo/Busniess%20Safe.dart';
import 'package:emecexpo/Congress.dart';
import 'package:emecexpo/Contact.dart';
import 'package:emecexpo/Exhibitors.dart';
import 'package:emecexpo/Food.dart';
import 'package:emecexpo/How%20to%20get%20there.dart';
import 'package:emecexpo/Information.dart';
import 'package:emecexpo/Media%20Partners.dart';
import 'package:emecexpo/News.dart';
import 'package:emecexpo/Notifications.dart';
import 'package:emecexpo/Official%20events.dart';
import 'package:emecexpo/Settings.dart';
import 'package:emecexpo/Social%20Media.dart';
import 'package:emecexpo/Speakers.dart';
import 'package:emecexpo/details/DetailCongress.dart';
import 'package:emecexpo/details/DetailNetworkin.dart';
import 'package:emecexpo/partners.dart';
import 'package:emecexpo/product.dart';
import 'package:emecexpo/services/local_notification_service.dart';
import 'package:emecexpo/Activities.dart';
import 'package:emecexpo/My%20Agenda.dart';
import 'package:emecexpo/Suporting%20Partners.dart';
import 'package:emecexpo/details/CongressMenu.dart';
import 'package:emecexpo/model/notification_model.dart';
import 'package:emecexpo/my_drawer_header.dart';
import 'package:emecexpo/Schedule.dart';
import 'package:emecexpo/networking.dart';
import 'package:emecexpo/app_user_guide_screen.dart';
import 'package:emecexpo/my_profile_screen.dart';
import 'package:emecexpo/my_badge_screen.dart';
import 'package:emecexpo/favourites_screen.dart';
import 'package:emecexpo/scanned_badges_screen.dart';
import 'ExpoFloorPlan.dart';
import 'conversations_screen.dart';
import 'package:emecexpo/meeting_ratings_screen.dart';
import 'package:emecexpo/model/app_theme_data.dart'; // Required for AlertDialog styling

// Import your providers
import 'package:emecexpo/providers/theme_provider.dart';
import 'package:emecexpo/providers/home_provider.dart';
import 'package:emecexpo/providers/menu_provider.dart';
// ❌ REMOVED: import 'package:emecexpo/connectivity_wrapper.dart';

// 💡 NEW: Import the shared definitions from constants.dart
import 'package:emecexpo/constants.dart';


// Dull Page Placeholder
class DullPage extends StatelessWidget {
  final String title;

  const DullPage({
    Key? key,
    this.title = 'Dull Page',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: const Center(
        child: Text(
          'This page is a work in progress.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

// 💡 Placeholder for ConnectivityService and ConnectivityWrapper
// (assuming you need these to resolve other dependencies)
class ConnectivityService with ChangeNotifier {}
class ConnectivityWrapper extends StatelessWidget {
  final Widget child;
  const ConnectivityWrapper({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    // In a real app, this would show a connection error screen if offline
    return child;
  }
}


ValueNotifier<int> notificationCountNotifier = ValueNotifier(0);
List<NotifClass> globalLitems = [];
var name = "1", date = "1", dtime = "1", discription = "1";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? authToken = prefs.getString('authToken');
  User? initialUser;

  if (authToken != null && authToken.isNotEmpty) {
    final String? userJson = prefs.getString('currentUserJson');
    if (userJson != null && userJson.isNotEmpty) {
      try {
        initialUser = User.fromJson(json.decode(userJson));
      } catch (e) {
        debugPrint("Error parsing stored user JSON in main: $e");
        await prefs.remove('authToken');
        await prefs.remove('currentUserJson');
        initialUser = null;
      }
    }
  }

  Widget initialScreen;
  if (initialUser != null && authToken != null && authToken.isNotEmpty) {
    initialScreen = WelcomPage(user: initialUser);
  } else {
    initialScreen = const LoginScreen();
  }

  globalLitems = [];
  notificationCountNotifier.value = globalLitems.length;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..fetchThemeFromApi(),
        ),
        ChangeNotifierProvider(
          create: (_) => MenuProvider()..fetchMenuConfig(),
        ),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
      ],
      child: MyApp(initialScreen: initialScreen),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({Key? key, required this.initialScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EMEC EXPO',
      theme: ThemeData(
        primaryColor: themeProvider.currentTheme.primaryColor,
        hintColor: themeProvider.currentTheme.secondaryColor,
        scaffoldBackgroundColor: themeProvider.currentTheme.whiteColor,
        appBarTheme: AppBarTheme(
          backgroundColor: themeProvider.currentTheme.primaryColor,
          titleTextStyle: TextStyle(
            color: themeProvider.currentTheme.whiteColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(
            color: themeProvider.currentTheme.whiteColor,
          ),
        ),
      ),
      home: (initialScreen is WelcomPage)
          ? AppContent(mainAppWidget: initialScreen)
          : initialScreen,
    );
  }
}

class AppContent extends StatelessWidget {
  final Widget mainAppWidget;
  const AppContent({Key? key, required this.mainAppWidget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 💡 FIX: Temporarily using mainAppWidget directly to resolve "ConnectivityWrapper is not defined"
    return mainAppWidget;
  }
}

class WelcomPage extends StatefulWidget {
  final User? user;
  const WelcomPage({Key? key, this.user}) : super(key: key);

  @override
  _WelcomPageState createState() => _WelcomPageState();
}

class _WelcomPageState extends State<WelcomPage> {
  var currentPage = DrawerSections.home;
  var _data = "";
  late SharedPreferences prefs;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  User? _loggedInUser;

  @override
  void initState() {
    super.initState();
    _initializeUserAndLoadData();
  }

  Future<void> _performLogout() async {
    await prefs.remove('authToken');
    await prefs.remove('currentUserJson');
    _loggedInUser = null;
    notificationCountNotifier.value = 0; // Reset notifications

    // Navigate back to the LoginScreen and remove all routes below it
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }

  // Function to show the confirmation dialog
  Future<void> _showLogoutConfirmationDialog(BuildContext context, AppThemeData theme) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to log out of your account?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: theme.primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: Text(
                'Logout',
                style: TextStyle(color: theme.secondaryColor, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog first
                // EXECUTE THE LOGOUT FUNCTION
                _performLogout();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _initializeUserAndLoadData() async {
    prefs = await SharedPreferences.getInstance();

    // 1. Prioritize user passed in the constructor
    _loggedInUser = widget.user;

    // 2. If no user passed, try loading from SharedPreferences
    if (_loggedInUser == null) {
      final String? userJsonString = prefs.getString('currentUserJson');
      if (userJsonString != null) {
        try {
          final Map<String, dynamic> userMap = json.decode(userJsonString);
          _loggedInUser = User.fromJson(userMap);
        } catch (e) {
          debugPrint("Error parsing stored user JSON in WelcomPage: $e");
          await prefs.remove('authToken');
          await prefs.remove('currentUserJson');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
            );
          });
          return;
        }
      }
    }

    _data = (prefs.getString("Data") ?? '');
    debugPrint("-------------Data from prefs: $_data------------------");
    setState(() {
      if (_data == "1") {
        currentPage = DrawerSections.exhibitors;
      } else if (_data == "2") {
        currentPage = DrawerSections.congressmenu;
      } else if (_data == "3") {
        currentPage = DrawerSections.business;
      } else if (_data == "4") {
        currentPage = DrawerSections.notifications;
        notificationCountNotifier.value = 0;
      } else if (_data == "5") {
        currentPage = DrawerSections.congressmenu;
      } else if (_data == "6") {
        currentPage = DrawerSections.detailexhib;
      } else if (_data == "7") {
        currentPage = DrawerSections.detailcongress;
      } else if (_data == "8") {
        currentPage = DrawerSections.DetailNetworkin;
      } else if (_data == "9") {
        currentPage = DrawerSections.networking;
      } else if (_data == "10") {
        currentPage = DrawerSections.myAgenda;
      } else if (_data == "11") {
        currentPage = DrawerSections.program;
      } else {
        currentPage = DrawerSections.home;
      }
    });
  }

  void _onNavigateToSection(DrawerSections section) {
    setState(() {
      currentPage = section;
    });
    if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }


  int _getBottomNavIndexForBottomNav() {
    if (currentPage == DrawerSections.home) {
      return 0;
    } else if (currentPage == DrawerSections.notifications) {
      return 1;
    }
    return 0;
  }

  Future<bool> _onWillPop() async {
    if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
      Navigator.pop(context);
      return false;
    }

    if (currentPage != DrawerSections.home) {
      _onNavigateToSection(DrawerSections.home);
      return false;
    }

    return true;
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    // 🎯 FIX: Check for nullability of _loggedInUser before use
    if (_loggedInUser == null) {
      // Show a loading or error widget while user data is being resolved
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Now we can safely use _loggedInUser with null assertion
    User currentUser = _loggedInUser!;

    Widget container;

    // Switch case (or if/else) to select the current view
    if (currentPage == DrawerSections.home) {
      container = HomeScreen(
        user: currentUser,
        onNavigate: _onNavigateToSection,
      );
    }
    else if (currentPage == DrawerSections.program) {
      container = const ProgramScreen();
    }
    else if (currentPage == DrawerSections.networking) {
      container = NetworkinScreen(authToken: currentUser.token ?? "");
    } else if (currentPage == DrawerSections.myAgenda) {
      container = AgendaScreen();
    } else if (currentPage == DrawerSections.congress) {
      container = CongressScreen();
    } else if (currentPage == DrawerSections.speakers) {
      container = SpeakersScreen();
    } else if (currentPage == DrawerSections.officialEvents) {
      container = OfficialEventsScreen();
    } else if (currentPage == DrawerSections.partners) {
      container = PartnersScreen();
    } else if (currentPage == DrawerSections.exhibitors) {
      container = ExhibitorsScreen();
    } else if (currentPage == DrawerSections.eFP) {
      container = ExpoFloorPlan();
    } else if (currentPage == DrawerSections.supportingP) {
      container = SupportingPScreen();
    } else if (currentPage == DrawerSections.mediaP) {
      container = MediaPScreen();
    } else if (currentPage == DrawerSections.socialM) {
      container = SocialMScreen();
    } else if (currentPage == DrawerSections.contact) {
      container = ContactScreen();
    } else if (currentPage == DrawerSections.information) {
      container = InformationScreen();
    } else if (currentPage == DrawerSections.schedule) {
      container = SchelduleScreen();
    } else if (currentPage == DrawerSections.getThere) {
      container = GetThereScreen();
    } else if (currentPage == DrawerSections.notifications) {
      container = NotificationsScreen();
    } else if (currentPage == DrawerSections.congressmenu) {
      container = CongressMenu();
    } else if (currentPage == DrawerSections.detailexhib) {
      container = ExhibitorsScreen();
    } else if (currentPage == DrawerSections.appUserGuide) {
      container = const AppUserGuideScreen();
    } else if (currentPage == DrawerSections.myProfile) {
      container = MyProfileScreen(user: currentUser);
    } else if (currentPage == DrawerSections.myBadge) {
      container = MyBadgeScreen(user: currentUser);
    } else if (currentPage == DrawerSections.favourites) {
      container = const FavouritesScreen();
    }
    // 🚀 FIX & UPDATE: Map Scanned Badges and pass the current user
    else if (currentPage == DrawerSections.scannedBadges) {
      container = ScannedBadgesScreen(user: currentUser);
    }
    //else if (currentPage == DrawerSections.messages) {
    //container = const ConversationsScreen();

    //}
    else if (currentPage == DrawerSections.meetingRatings) {
      container = const MeetingRatingsScreen();
    }
    else if (currentPage == DrawerSections.congresses) {
      container = CongressScreen();
    } else if (currentPage == DrawerSections.sponsors) {
      container = SupportingPScreen();
    } else {
      // 💡 This is the fallback that was showing "Dull Page"
      container = Center(child: const DullPage(title: 'Page Not Found'));
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        body: container,
        endDrawer: Drawer(
          // 💡 FIX APPLIED HERE: Wrap the drawer content in SafeArea.
          // bottom: true ensures that bottom padding is applied to avoid the phone's navigation bar.
          child: SafeArea(
            top: true, // Keep the top padding to avoid the status bar
            bottom: true, // This is the crucial fix for the navigation buttons
            left: false,
            right: false,
            child: SingleChildScrollView(
              child: Container(
                color: theme.primaryColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 💡 FIX: Pass the _performLogout function to MyHeaderDrawer
                    MyHeaderDrawer(user: currentUser, onLogout: _performLogout), // Pass the non-nullable user
                    const SizedBox(height: 5.0),
                    Consumer<MenuProvider>(
                      builder: (context, menuProvider, child) {
                        final menuConfig = menuProvider.menuConfig;
                        if (menuConfig == null) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return MyDrawerList(
                          theme: themeProvider,
                          menuConfig: menuConfig,
                          onNavigate: _onNavigateToSection,
                          currentSection: currentPage,
                          // 💡 NEW: Pass the logout callback function and theme data
                          onLogout: _performLogout,
                          showLogoutDialog: _showLogoutConfirmationDialog,
                          appTheme: theme,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: ValueListenableBuilder<int>(
                valueListenable: notificationCountNotifier,
                builder: (context, count, child) {
                  return badges.Badge(
                    showBadge: count > 0,
                    badgeContent: Text(
                      count.toString(),
                      style: TextStyle(color: theme.whiteColor, fontSize: 10),
                    ),
                    badgeStyle: badges.BadgeStyle(
                      badgeColor: theme.redColor,
                      padding: const EdgeInsets.all(5),
                    ),
                    position: badges.BadgePosition.topEnd(top: -10, end: -12),
                    child: const Icon(Icons.notifications),
                  );
                },
              ),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.menu),
              label: 'Menu',
            ),
          ],
          currentIndex: _getBottomNavIndexForBottomNav(),
          selectedItemColor: theme.secondaryColor,
          unselectedItemColor: theme.whiteColor,
          backgroundColor: theme.primaryColor,
          onTap: (index) async {
            if (index == 0) {
              _onNavigateToSection(DrawerSections.home);
            } else if (index == 1) {
              _onNavigateToSection(DrawerSections.notifications);
              notificationCountNotifier.value = 0;
            } else if (index == 2) {
              _scaffoldKey.currentState?.openEndDrawer();
            }
          },
        ),
      ),
    );
  }

  Widget MyDrawerList({
    required ThemeProvider theme,
    required MenuConfig menuConfig,
    required OnNavigateCallback onNavigate,
    required DrawerSections currentSection,
    // 💡 NEW PARAMETERS FOR LOGOUT
    required VoidCallback onLogout,
    required Function(BuildContext context, AppThemeData theme) showLogoutDialog,
    required AppThemeData appTheme,
  }) {
    // ... (MyDrawerList implementation)
    return Container(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          menuItem(DrawerSections.home, "Home", Icons.home, currentSection == DrawerSections.home, onNavigate),
         // menuItem(DrawerSections.notifications, "Notifications", Icons.notifications, currentSection == DrawerSections.notifications, onNavigate),

          const Divider(color: Colors.white24, height: 20),

          if (menuConfig.exhibitors) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                "EVENT INFORMATION",
                style: TextStyle(
                  color: theme.currentTheme.whiteColor.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (menuConfig.floorPlan)
              menuItem(DrawerSections.eFP, "Floor Plan", Icons.location_on_outlined, currentSection == DrawerSections.eFP, onNavigate),
            menuItem(DrawerSections.program, "Program", Icons.calendar_today_outlined, currentSection == DrawerSections.program, onNavigate),
            if (menuConfig.exhibitors)
              menuItem(DrawerSections.exhibitors, "Exhibitors", Icons.store_mall_directory_outlined, currentSection == DrawerSections.exhibitors, onNavigate),
            if (menuConfig.speakers)
              menuItem(DrawerSections.speakers, "Speakers", Icons.speaker_notes_outlined, currentSection == DrawerSections.speakers, onNavigate),
            if (menuConfig.congresses)
              menuItem(DrawerSections.congresses, "Congresses", Icons.account_balance, currentSection == DrawerSections.congresses, onNavigate),
            if (menuConfig.sponsors)
              menuItem(DrawerSections.sponsors, "Sponsors", Icons.favorite_outline, currentSection == DrawerSections.sponsors, onNavigate),
            if (menuConfig.partners)
              menuItem(DrawerSections.partners, "Partners", Icons.handshake_outlined, currentSection == DrawerSections.partners, onNavigate),
          ],

          const Divider(color: Colors.white24, height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              "ACCOUNT",
              style: TextStyle(
                color: theme.currentTheme.whiteColor.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          menuItem(DrawerSections.myProfile, "My Profile", Icons.person_outline, currentSection == DrawerSections.myProfile, onNavigate),
          menuItem(DrawerSections.myBadge, "My Badge", FontAwesomeIcons.idBadge, currentSection == DrawerSections.myBadge, onNavigate),
          //menuItem(DrawerSections.favourites, "Favourites", Icons.favorite, currentSection == DrawerSections.favourites, onNavigate),
          menuItem(DrawerSections.scannedBadges, "Scanned Badges", Icons.qr_code_scanner, currentSection == DrawerSections.scannedBadges, onNavigate),
          //menuItem(DrawerSections.messages, "Messages", Icons.message_outlined, currentSection == DrawerSections.messages, onNavigate),
          menuItem(DrawerSections.myAgenda, "My Agenda", Icons.calendar_today_outlined, currentSection == DrawerSections.myAgenda, onNavigate),
          //menuItem(DrawerSections.meetingRatings, "Meeting ratings", Icons.star_border, currentSection == DrawerSections.meetingRatings, onNavigate),
           menuItem(DrawerSections.networking, "Networking", Icons.people_outline, currentSection == DrawerSections.networking, onNavigate),

          const Divider(color: Colors.white24, height: 20),

          menuItem(DrawerSections.contact, "Contact", Icons.contact_mail_outlined, currentSection == DrawerSections.contact, onNavigate),
          //menuItem(DrawerSections.getThere, "How to get there", Icons.directions_bus_outlined, currentSection == DrawerSections.getThere, onNavigate),
          menuItem(DrawerSections.socialM, "Social Media", FontAwesomeIcons.shareNodes, currentSection == DrawerSections.socialM, onNavigate),
          //menuItem(DrawerSections.settings, "Settings", Icons.settings_outlined, currentSection == DrawerSections.settings, onNavigate),

          // 💡 NEW: LOGOUT BUTTON
          // Use a placeholder section for the logout action, as it doesn't navigate to a content screen.
          // Using a high number or a custom value that won't conflict with existing sections.
          // Since it's an action, we call the dialog directly instead of onNavigate
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  showLogoutDialog(context, appTheme);
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      size: 24,
                      color: theme.currentTheme.secondaryColor,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Logout",
                        style: TextStyle(
                          color: theme.currentTheme.whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // END OF LOGOUT BUTTON
          const SizedBox(height: 20), // Add some spacing at the bottom
        ],
      ),
    );
  }

  Widget menuItem(DrawerSections section, String title, IconData icon, bool selected, OnNavigateCallback onNavigate) {
    final theme = Provider.of<ThemeProvider>(context, listen: false);

    return Material(
      color: selected ? Colors.white12 : Colors.transparent,
      child: InkWell(
        onTap: () {
          onNavigate(section);
          if (section == DrawerSections.notifications) {
            notificationCountNotifier.value = 0;
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: theme.currentTheme.secondaryColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                      color: theme.currentTheme.whiteColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}