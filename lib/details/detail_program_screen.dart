// lib/screens/detail_program_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../model/program_model.dart'; // Must contain SpeakerModel and updated ProgramItemModel
import '../providers/theme_provider.dart';
import '../main.dart';
import '../model/app_theme_data.dart';

class DetailProgramScreen extends StatelessWidget {
  final ProgramItemModel programItem;

  const DetailProgramScreen({Key? key, required this.programItem}) : super(key: key);

  // Helper to format the combined date and time range
  String _formatDateTimeRange(String dateDeb, String dateFin) {
    if (dateDeb.isEmpty || dateFin.isEmpty) return 'Date et heure non disponibles';
    try {
      final inputFormat = DateFormat('MM/dd/yyyy h:mm a');
      final start = inputFormat.parse(dateDeb);
      final end = inputFormat.parse(dateFin);

      final datePart = DateFormat('EEE, dd MMM yyyy', 'fr_FR').format(start);
      final timeRange = "${DateFormat('HH:mm').format(start)} - ${DateFormat('HH:mm').format(end)}";

      return "$datePart | $timeRange";
    } catch (e) {
      return "Date et heure non disponibles";
    }
  }

  // Helper function for Time and Location Section
  Widget _buildTimeAndLocationSection(AppThemeData theme, Color primaryContentColor, Color accentContentColor) {
    final String formattedTime = _formatDateTimeRange(programItem.dateDeb, programItem.dateFin);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date and Time Header
        Text(
          'Date & Time',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryContentColor.withOpacity(0.9)),
        ),
        const SizedBox(height: 8),
        // Date and Time Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 20, color: accentContentColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  formattedTime,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: primaryContentColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),

        // Location
        if (programItem.location.isNotEmpty && programItem.location != 'Not specified') ...[
          // Location Header
          Text(
            'Location',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryContentColor.withOpacity(0.9)),
          ),
          const SizedBox(height: 8),
          // Location Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 20, color: Colors.grey),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    programItem.location,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: primaryContentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Helper for displaying a list of speakers (can be one or more)
  Widget _buildSpeakerListSection(AppThemeData theme, Color primaryContentColor, Color accentContentColor) {
    if (programItem.speakers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          programItem.speakers.length > 1 ? 'Speakers' : 'Speaker',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryContentColor.withOpacity(0.9)),
        ),
        const SizedBox(height: 8),
        // List of speakers
        ...programItem.speakers.map((speaker) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // Speaker Icon/Image placeholder
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: accentContentColor,
                    child: speaker.pic != null && speaker.pic!.isNotEmpty
                        ? ClipOval(
                      child: Image.network(
                        speaker.pic!,
                        fit: BoxFit.cover,
                        width: 30,
                        height: 30,
                        // Fallback icon on error
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.person, size: 18, color: theme.whiteColor),
                      ),
                    )
                        : Icon(Icons.person, size: 18, color: theme.whiteColor),
                  ),
                  const SizedBox(width: 10),
                  // Speaker Name and Post
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          speaker.fullName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: primaryContentColor,
                          ),
                        ),
                        Text(
                          speaker.poste,
                          style: TextStyle(
                            fontSize: 14,
                            color: primaryContentColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    final Color primaryContentColor = theme.blackColor;
    final Color accentContentColor = theme.secondaryColor;
    final Color cardBackgroundColor = theme.whiteColor;

    final String sessionTitle = programItem.title.isNotEmpty ? programItem.title : "Session Title";
    final String sessionType = programItem.type.isNotEmpty ? programItem.type : "General Session";


    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.whiteColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: theme.primaryColor,
        elevation: 0,
        title: Center(
          child: Text(
            'Session Details',
            style: TextStyle(color: theme.whiteColor, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [

        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            // --- Session Header Card (Profile Section Style) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                color: cardBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Placeholder Icon/Image for the Session
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: accentContentColor.withOpacity(0.1),
                        child: Icon(Icons.mic_external_on, size: 40, color: accentContentColor),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.label_important, size: 20, color: theme.whiteColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Session Title
                  Text(
                    sessionTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryContentColor,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Session Type Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentContentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      sessionType.toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: accentContentColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- Details and Description Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // --- Time and Location Section ---
                  _buildTimeAndLocationSection(theme, primaryContentColor, accentContentColor),
                  const SizedBox(height: 25),

                  // 💡 Speaker/Presenter Section - This calls the function that displays the speakers
                  _buildSpeakerListSection(theme, primaryContentColor, accentContentColor),
                  if (programItem.speakers.isNotEmpty) const SizedBox(height: 25),


                  // --- Description Header ---
                  Text(
                    'Description',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryContentColor
                    ),
                  ),
                  const Divider(color: Colors.grey),

                  // --- Description Body ---
                  Text(
                    programItem.description.isNotEmpty ? programItem.description : 'Description non disponible pour cette session.',
                    style: TextStyle(
                        fontSize: 16,
                        color: primaryContentColor.withOpacity(0.7),
                        height: 1.5
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}