// lib/auth_popup.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pharma_health_expo/login_screen.dart';
import 'package:pharma_health_expo/providers/theme_provider.dart';
import 'package:pharma_health_expo/global/app_config.dart';

class AuthPopup {
  static Future<void> show(BuildContext context) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final theme = themeProvider.currentTheme;

    Future<void> _launchUrlRegister() async {
      final Uri url = Uri.parse(AppConfig.registerUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 20.0),
            decoration: BoxDecoration(
              color: theme.blackColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0),
              ),
              border: Border.all(color: theme.whiteColor.withOpacity(0.1)),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo et bouton de fermeture plus compacts
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: Image(
                            image: theme.logoImage,
                            height: 35, // Réduit
                            fit: BoxFit.contain,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.whiteColor.withOpacity(0.1),
                                ),
                                child: Icon(Icons.close, color: theme.whiteColor.withOpacity(0.7), size: 18),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Icône de la main et textes réduits
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.secondaryColor.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.waving_hand_rounded,
                              size: 26, // Réduit
                              color: theme.secondaryColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Welcome',
                            style: TextStyle(
                              fontSize: 18, // Réduit
                              fontWeight: FontWeight.bold,
                              color: theme.whiteColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'You are in Guest Mode',
                            style: TextStyle(
                              fontSize: 13, // Réduit
                              color: theme.whiteColor.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Boutons ajustés pour ne pas prendre trop de hauteur
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12), // Réduit
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: theme.secondaryColor, width: 1.5),
                            ),
                            child: Text(
                              'Log in',
                              style: TextStyle(
                                color: theme.secondaryColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _launchUrlRegister();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.secondaryColor,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12), // Réduit
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Register',
                              style: TextStyle(
                                color: theme.whiteColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}