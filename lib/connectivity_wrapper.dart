import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Import your existing ThemeProvider for consistent styling
import 'package:emecexpo/providers/theme_provider.dart';


// -----------------------------------------------------------------------------
// A. Connectivity Service (The Global Provider)
// -----------------------------------------------------------------------------

class ConnectivityService extends ChangeNotifier {
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  // Track previous state to know if a transition (loss or restore) happened
  bool _previousState = true;
  bool get previousState => _previousState;

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityService() {
    _initializeConnectivityCheck();
  }

  void _initializeConnectivityCheck() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    await _updateConnectionStatus(connectivityResult);

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<bool> _checkInternetExistence() async {
    try {
      // Check for real internet access (not just local Wi-Fi)
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    bool hasNetworkInterface = !results.contains(ConnectivityResult.none);
    bool actualConnection = false;

    if (hasNetworkInterface) {
      actualConnection = await _checkInternetExistence();
    }

    if (_isConnected != actualConnection) {
      _previousState = _isConnected;
      _isConnected = actualConnection;
      notifyListeners(); // Notify all listeners (i.e., AppContent)
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}

// -----------------------------------------------------------------------------
// B. No Internet Full Screen (Custom Page)
// -----------------------------------------------------------------------------

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;

    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('Connection Error')),
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.whiteColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 💡 FIX: Using Icons.wifi_off as Icons.cable_off may not be available.
              Icon(
                Icons.wifi_off,
                size: 100,
                color: theme.primaryColor,
              ),
              const SizedBox(height: 20),
              const Text(
                'No Internet Connection',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please check your Wi-Fi or mobile data connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// C. App Content Wrapper (The Global Manager - Simplified)
// -----------------------------------------------------------------------------

class AppContent extends StatelessWidget {
  final Widget mainAppWidget;
  const AppContent({super.key, required this.mainAppWidget});

  @override
  Widget build(BuildContext context) {
    // Listen to changes in the ConnectivityService
    final connectivityService = Provider.of<ConnectivityService>(context);

    // If disconnected, immediately show the full No Internet Screen.
    if (!connectivityService.isConnected) {
      return const NoInternetScreen();
    }

    // If connected, show the main application content (WelcomPage).
    return mainAppWidget;
  }
}