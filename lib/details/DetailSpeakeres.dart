// lib/screens/details/DetailSpeakersScreen.dart

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

// Assuming your model and API imports are correct
import '../../api_services/speaker_api_service.dart'; // 👈 NEW: Import to access imageBaseUrl
import '../../model/app_theme_data.dart';
import '../../model/speakers_model.dart';
import '../../providers/theme_provider.dart';
import 'DetailSessionScreen.dart'; // Import the session detail screen

// Constants assumed from speakers_model.dart
const String kDefaultSpeakerImageUrl = 'https://buzzevents.co/uploads/ICON-EMEC.png';

class DetailSpeakersScreen extends StatefulWidget {
  final Speakers? speaker;
  final List<String> periods;

  const DetailSpeakersScreen({Key? key, this.speaker, required this.periods}) : super(key: key);

  @override
  _DetailSpeakersScreenState createState() => _DetailSpeakersScreenState();
}

class _DetailSpeakersScreenState extends State<DetailSpeakersScreen> {

  List<ProgramSession> _allSessions = [];
  List<ProgramSession> _filteredSessions = [];

  List<String> _apiDateFilters = [];
  bool isLoading = true;
  int? _selectedDateIndex;
  bool _isSpeakerFavorite = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    _isSpeakerFavorite = widget.speaker?.isFavorite ?? false;
    _loadData();
  }

  Widget _getSpeakerImage(double radius) {
    // 💡 Access the theme for background/placeholder color
    final theme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;

    // Fetch the image base URL from the service
    const String imageBaseUrl = SpeakerApiService.imageBaseUrl;

    // Get the relative image path from the speaker object, default to a sensible file name
    // Use the null-aware operator to safely access 'pic' and default if null
    final String relativePicPath = widget.speaker?.pic ?? 'ICON-EMEC.png';

    // Construct the full URL
    // Only prepend the base URL if the pic path isn't already a full URL (though unlikely here)
    final String finalUrl = relativePicPath.isNotEmpty
        ? imageBaseUrl + relativePicPath
        : kDefaultSpeakerImageUrl; // Fallback URL

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[200], // Default grey background
      child: ClipOval(
        child: Image.network(
          finalUrl,
          fit: BoxFit.cover,
          width: radius * 2,
          height: radius * 2,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: radius * 2,
              height: radius * 2,
              color: Colors.grey[200], // Light grey placeholder
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                  color: theme.secondaryColor, // Use accent color for loading indicator
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Image.asset(
            'assets/placeholder.png', // Fallback to a local asset
            fit: BoxFit.cover,
            width: radius * 2,
            height: radius * 2,
          ),
        ),
      ),
    );
  }

  _loadData() async {
    isLoading = true;
    if (mounted) setState(() {});

    // Ensure sessions list is not null
    _allSessions = widget.speaker?.sessions ?? [];

    _apiDateFilters = widget.periods.map((dateString) {
      try {
        final date = DateTime.parse(dateString);
        return DateFormat('dd MMM.', 'fr_FR').format(date).toUpperCase();
      } catch (e) {
        return dateString;
      }
    }).toList();

    if (mounted) {
      setState(() {
        isLoading = false;
        _filteredSessions = List.from(_allSessions);
        // Automatically select the first date filter if available
        if (_apiDateFilters.isNotEmpty) {
          _filterSessionsByDate(0);
        } else {
          _selectedDateIndex = null;
        }
      });
    }
  }

  void _filterSessionsByDate(int index) {
    if (index < 0 || index >= _apiDateFilters.length) {
      setState(() {
        _selectedDateIndex = null;
        _filteredSessions = List.from(_allSessions);
      });
      return;
    }

    final String selectedFilterText = _apiDateFilters[index].toLowerCase();

    // NOTE: This format must match the input format in your JSON/model for dateDeb/dateFin
    final DateFormat sessionInputFormat = DateFormat('MM/dd/yyyy h:mm a');

    List<ProgramSession> sessionsForDay = _allSessions.where((session) {
      try {
        final sessionDate = sessionInputFormat.parse(session.dateDeb);
        final sessionDateShort = DateFormat('dd MMM.', 'fr_FR').format(sessionDate).toUpperCase();

        return sessionDateShort.toLowerCase() == selectedFilterText;
      } catch (e) {
        print("Error filtering session date: $e");
        return false;
      }
    }).toList();

    sessionsForDay.sort((a, b) {
      try {
        final timeA = sessionInputFormat.parse(a.dateDeb);
        final timeB = sessionInputFormat.parse(b.dateDeb);
        return timeA.compareTo(timeB);
      } catch (e) {
        return 0;
      }
    });

    setState(() {
      _selectedDateIndex = index;
      _filteredSessions = sessionsForDay;
    });
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Êtes-vous sûr'),
        content: const Text('Voulez-vous quitter une application'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Oui '),
          ),
        ],
      ),
    )) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // 💡 Access the theme provider and get the current theme.
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    // Safely retrieve speaker details using null checks and defaults
    final String speakerName = widget.speaker != null
        ? "${widget.speaker!.prenom} ${widget.speaker!.nom}"
        : "Speaker Name";
    final String speakerPoste = widget.speaker?.poste ?? "Speaker Position/Poste";
    // Use the 'company' getter from the Speakers model
    final String speakerCompany = widget.speaker?.company ?? "Company";
    // Handle potentially null biography (the source of the original error)
    final String speakerBio = widget.speaker?.biographie ?? "No biography available.";

    // Theme color variables for consistency
    final Color primaryContentColor = theme.blackColor;
    final Color accentColor = theme.secondaryColor;

    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: theme.whiteColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          /*
          IconButton(
            icon: Icon(
              _isSpeakerFavorite ? Icons.star : Icons.star_border,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isSpeakerFavorite = !_isSpeakerFavorite;
                widget.speaker?.isFavorite = _isSpeakerFavorite;
              });
            },
          ),
          */
        ],
      ),
      body: FadeInDown(
        duration: const Duration(milliseconds: 500),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Speaker Profile Section ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: BoxDecoration(
                  color: theme.whiteColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        _getSpeakerImage(50), // 👈 Image loading is fixed here
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.mic_none, size: 20, color: primaryContentColor.withOpacity(0.7)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      speakerName,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryContentColor),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      speakerPoste,
                      style: TextStyle(fontSize: 16, color: primaryContentColor.withOpacity(0.6)),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      speakerCompany,
                      style: TextStyle(fontSize: 16, color: primaryContentColor.withOpacity(0.6)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // --- Biography Section ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Biography",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryContentColor),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      speakerBio,
                      style: TextStyle(fontSize: 16, color: primaryContentColor.withOpacity(0.7), height: 1.5),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),

              // --- Speaker's Sessions Section ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Speaker's Sessions",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryContentColor),
                ),
              ),
              const SizedBox(height: 15),

              // Date Selection Buttons (using dynamic API filters)
              isLoading
                  ? Center(child: Padding(padding: const EdgeInsets.all(8.0), child: Text("Loading program days...", style: TextStyle(color: primaryContentColor.withOpacity(0.6)))))
                  : _apiDateFilters.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(_apiDateFilters.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: _buildDateButton(_apiDateFilters[index], index, theme),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // List of Sessions
              isLoading
                  ? Center(child: Padding(padding: const EdgeInsets.all(30.0), child: CircularProgressIndicator(color: accentColor)))
                  : _allSessions.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "This speaker has no scheduled sessions.",
                    style: TextStyle(fontSize: 16, color: primaryContentColor.withOpacity(0.6)),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
                  : _filteredSessions.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    _selectedDateIndex != null && _apiDateFilters.isNotEmpty
                        ? "No sessions scheduled for this speaker on ${_apiDateFilters[_selectedDateIndex!]}."
                        : "No sessions scheduled for this speaker on the selected day.",
                    style: TextStyle(fontSize: 16, color: primaryContentColor.withOpacity(0.6)),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredSessions.length,
                itemBuilder: (context, index) {
                  final session = _filteredSessions[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: _buildSessionCard(session, theme),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateButton(String date, int index, AppThemeData theme) {
    bool isSelected = _selectedDateIndex == index;
    final Color selectedColor = theme.primaryColor;
    final Color unselectedColor = Colors.grey[200]!;

    return GestureDetector(
      onTap: () {
        _filterSessionsByDate(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : unselectedColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          date,
          style: TextStyle(
            color: isSelected ? theme.whiteColor : theme.blackColor.withOpacity(0.87),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSessionCard(ProgramSession session, AppThemeData theme) {
    final DateFormat sessionInputFormat = DateFormat('MM/dd/yyyy h:mm a');
    String timeRange = '';
    String datePart = '';

    final Color accentColor = theme.secondaryColor;
    final Color primaryContentColor = theme.blackColor;


    try {
      final DateTime start = sessionInputFormat.parse(session.dateDeb);
      final DateTime end = sessionInputFormat.parse(session.dateFin);
      timeRange = "${DateFormat('HH:mm').format(start)} - ${DateFormat('HH:mm').format(end)}";
      datePart = DateFormat('EEE, dd MMM yyyy', 'fr_FR').format(start);
    } catch (_) {
      timeRange = 'Time N/A';
      datePart = session.dateDeb.split(' ').first;
    }

    final String tagLabel = session.type.isNotEmpty ? session.type : "Session Details";

    return Card(
      elevation: 3,
      color: theme.whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // STATIC TAG/TYPE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                tagLabel,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),
            Text(
              session.nom,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryContentColor,
              ),
            ),
            const SizedBox(height: 5),

            // Time and Date
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    "$timeRange | $datePart",
                    style: TextStyle(fontSize: 14, color: primaryContentColor.withOpacity(0.6)),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),

            // Location
            if (session.emplacement != null && session.emplacement!.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      session.emplacement!,
                      style: TextStyle(fontSize: 14, color: primaryContentColor.withOpacity(0.6)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 10),

            Align(
              alignment: Alignment.bottomRight,
              child: OutlinedButton(
                onPressed: () {
                  // Navigate to DetailSessionScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailSessionScreen(session: session),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: accentColor,
                  side: BorderSide(color: accentColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text("View Session"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}