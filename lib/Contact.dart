// lib/screens/contact_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:emecexpo/api_services/event_contact_api_service.dart';
import 'package:emecexpo/model/event_contact_model.dart';
import 'package:emecexpo/model/organizer_model.dart';

// Assuming these are defined elsewhere in your project
import '../providers/theme_provider.dart';
import '../main.dart';
import '../model/app_theme_data.dart';


class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  late SharedPreferences prefs;

  final EventContactApiService _apiService = EventContactApiService();
  late Future<EventContactModel> _eventFuture;

  static const String _logoBaseUrl = "https://buzzevents.co/uploads/";

  @override
  void initState() {
    super.initState();
    _eventFuture = _apiService.fetchEventDetails();
  }

  // 🚀 CORRECTED Function: Launch Map URL
  Future<void> _launchMapUrl(String address) async {
    // URL-encode the address for the query parameter
    final encodedAddress = Uri.encodeComponent(address);

    // Use a standard Google Maps search query URL
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress');

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch map application.')),
        );
      }
      throw Exception('Could not launch map URL: $url');
    }
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () async{
            prefs = await SharedPreferences.getInstance();
            prefs.setString("Data", "99");
            // Assuming WelcomPage can be instantiated without arguments if it's the root/main screen
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const WelcomPage()));
          },
        ),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.whiteColor,
      ),
      body: Container(
        color: theme.whiteColor,
        child: FutureBuilder<EventContactModel>(
          future: _eventFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: theme.primaryColor));
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error: ${snapshot.error}', style: TextStyle(color: theme.blackColor.withOpacity(0.87))),
                ),
              );
            } else if (snapshot.hasData) {
              final eventData = snapshot.data!;
              final organizer = eventData.organizer;

              return _buildContent(context, theme, eventData, organizer);
            }
            return Center(child: Text('No event data available.', style: TextStyle(color: theme.blackColor.withOpacity(0.87))));
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppThemeData theme, EventContactModel eventData, OrganizerModel organizer) {
    // Helper function to parse and format date from 'yyyy-mm-dd HH:mm:ss...'
    String formatDate(String dateString) {
      final dateTime = DateTime.tryParse(dateString);
      if (dateTime == null) return dateString;

      final day = dateTime.day.toString();
      final year = dateTime.year.toString();

      final monthMap = {
        1: 'Jan', 2: 'Feb', 3: 'Mar', 4: 'Apr', 5: 'May', 6: 'Jun',
        7: 'Jul', 8: 'Aug', 9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dec'
      };

      final monthName = monthMap[dateTime.month] ?? '';
      return '$day $monthName, $year';
    }

    // --- Date Correction Logic to set End Day to 21 ---
    String modifiedEndDate = eventData.scheduledEndDate;
    try {
      final endDateTime = DateTime.tryParse(eventData.scheduledEndDate);
      if (endDateTime != null && endDateTime.day == 22) {
        // Create a new DateTime object with the day explicitly set to 21
        final correctedDateTime = DateTime(endDateTime.year, endDateTime.month, 21, endDateTime.hour, endDateTime.minute, endDateTime.second);
        modifiedEndDate = correctedDateTime.toIso8601String();
      }
    } catch (e) {
      print('Error modifying end date: $e');
    }

    final formattedStart = formatDate(eventData.scheduledStartDate);
    final formattedEnd = formatDate(modifiedEndDate); // Use the modified end date

    const String staticTime = '9h to 19h';

    // Static address for the exhibition location
    const String locationAddress = 'J93C+Q8Q Foire Internationale de Casablanca, Rue Doukkala, Casablanca 20030';


    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Section 1: Logo and Introduction
            Card(
              margin: const EdgeInsets.only(bottom: 20.0),
              color: theme.whiteColor,
              elevation: 2.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Dynamic Network Image for the logo (height: 150)
                    Image.network(
                      '$_logoBaseUrl${eventData.logoName}',
                      height: 150,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(height: 150, child: Center(child: CircularProgressIndicator(color: theme.secondaryColor)));
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(height: 150, child: Center(child: Icon(Icons.broken_image, size: 75, color: Colors.grey)));
                      },
                    ),
                    const SizedBox(height: 16.0),
                    // Dynamic event description
                    Text(
                      'If you have any questions or comments, please do not hesitate to contact us by phone or email.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.0, color: theme.blackColor.withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
            ),

            // Section 2: Opening Time (Start Day and End Day)
            Text(
              'Opening time',
              style: TextStyle(fontSize: 18, color: theme.primaryColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              margin: const EdgeInsets.only(bottom: 20.0),
              color: theme.whiteColor,
              elevation: 2.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    // Display Start Day
                    _buildContactInfoRow(
                      icon: Icons.access_time,
                      text: 'Start Day: $formattedStart ($staticTime)',
                      theme: theme,
                    ),
                    const Divider(),
                    // Display End Day (now shows Day 21)
                    _buildContactInfoRow(
                      icon: Icons.access_time,
                      text: 'Last Day: $formattedEnd ($staticTime)',
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ),

            // Section 3: The Exhibition's location (Clickable)
            Text(
              'The Exhibition\'s location',
              style: TextStyle(fontSize: 18, color: theme.primaryColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              margin: const EdgeInsets.only(bottom: 20.0),
              color: theme.whiteColor,
              elevation: 2.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              child: InkWell( // Make the card content tappable
                onTap: () => _launchMapUrl(locationAddress),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildContactInfoRow(
                        icon: Icons.map,
                        text: locationAddress,
                        theme: theme,
                        isClickable: true, // Pass flag to indicate clickability
                      ),
                      // Optional hint for the user
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 39.0),
                        child: Text(
                          'Tap to open in map application',
                          style: TextStyle(fontSize: 12, color: theme.secondaryColor.withOpacity(0.8)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // END The Exhibition's location

            // Section 4: Contact Details (Phone, Email, AND Organizer Address)
            Text(
              'CONTACT',
              style: TextStyle(fontSize: 18, color: theme.primaryColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              color: theme.whiteColor,
              elevation: 2.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    // Dynamic organizer phone number
                    _buildContactInfoRow(
                      icon: Icons.phone,
                      text: organizer.phone,
                      theme: theme,
                    ),
                    const Divider(),
                    // Dynamic organizer email
                    _buildContactInfoRow(
                      icon: Icons.email_outlined,
                      text: organizer.email,
                      theme: theme,
                    ),
                    const Divider(),
                    // Dynamic organizer address (Office/Organizer Location)
                    _buildContactInfoRow(
                      icon: Icons.business,
                      text: organizer.address,
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper method for consistent contact rows (MODIFIED)
  Widget _buildContactInfoRow({
    required IconData icon,
    required String text,
    required AppThemeData theme,
    bool isClickable = false, // Added flag for click state
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            size: 24,
            color: theme.secondaryColor,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: isClickable ? theme.primaryColor : theme.blackColor.withOpacity(0.87), // Highlight clickable text
                decoration: isClickable ? TextDecoration.underline : TextDecoration.none,
              ),
              overflow: TextOverflow.visible,
            ),
          ),
          // Add a navigation arrow for clickable rows
          if (isClickable)
            Icon(Icons.open_in_new, size: 20, color: theme.secondaryColor),
        ],
      ),
    );
  }
}