// lib/main/main_app.dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:pharma_health_expo/providers/theme_provider.dart';
import 'package:pharma_health_expo/providers/app_config_provider.dart';
import 'package:pharma_health_expo/providers/menu_provider.dart';
import 'package:pharma_health_expo/providers/home_provider.dart';
import 'package:pharma_health_expo/global/app_config.dart';
import 'package:pharma_health_expo/api_services/api_global.dart';
import 'welcome_page.dart';

class MyApp extends StatefulWidget {
  final Widget initialScreen;
  const MyApp({Key? key, required this.initialScreen}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    try {
      final fetchedEditionId = await ApiGlobal.fetchActiveEditionId();
      AppConfig.editionId = fetchedEditionId;

      final configProvider = Provider.of<AppConfigProvider>(context, listen: false);
      await configProvider.initializeConfig();

      if (configProvider.rawSettings != null && mounted) {
        Provider.of<ThemeProvider>(context, listen: false).updateThemeFromConfig(configProvider);
        Provider.of<MenuProvider>(context, listen: false).updateMenuFromConfig(configProvider);
        Provider.of<HomeProvider>(context, listen: false).updateCardsFromConfig(configProvider);
      }
    } catch (e) {
      debugPrint("⚠️ Initialization sequence faulted: $e");
    }

    if (mounted) {
      setState(() { _isInitializing = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: SpinKitCircle(color: Color(0xFF004B9F), size: 50.0),
          ),
        ),
      );
    }

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final currentTheme = themeProvider.currentTheme;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: currentTheme.appTitle,
          theme: ThemeData(
            primaryColor: currentTheme.primaryColor,
            hintColor: currentTheme.secondaryColor,
            scaffoldBackgroundColor: currentTheme.whiteColor,
            appBarTheme: AppBarTheme(
              backgroundColor: currentTheme.primaryColor,
              titleTextStyle: TextStyle(color: currentTheme.whiteColor, fontSize: 20, fontWeight: FontWeight.bold),
              iconTheme: IconThemeData(color: currentTheme.whiteColor),
            ),
          ),
          home: (widget.initialScreen is WelcomPage)
              ? AppContent(mainAppWidget: widget.initialScreen)
              : widget.initialScreen,
        );
      },
    );
  }
}

class AppContent extends StatelessWidget {
  final Widget mainAppWidget;
  const AppContent({Key? key, required this.mainAppWidget}) : super(key: key);

  @override
  Widget build(BuildContext context) { return mainAppWidget; }
}