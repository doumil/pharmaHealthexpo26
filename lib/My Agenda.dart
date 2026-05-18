// lib/screens/agenda_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// 💡 CORRECTED IMPORT PATH FOR API SERVICE
import '../api_services/program_api_service.dart';
import '../model/program_model.dart';
import '../providers/theme_provider.dart';
import '../model/app_theme_data.dart';
import '../services/agenda_local_service.dart';
import '../services/google_calendar_service.dart';
import 'details/detail_program_screen.dart';
import 'main.dart'; // Assuming WelcomPage is here
import 'program_screen.dart' hide ProgramApiService;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:animate_do/animate_do.dart';

class AgendaScreen extends StatefulWidget {
  final int? sourceCode;
  const AgendaScreen({Key? key, this.sourceCode}) : super(key: key);

  @override
  _AgendaScreenState createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final ProgramApiService _apiService = ProgramApiService();
  final AgendaLocalService _localService = AgendaLocalService();
  final GoogleCalendarService _calendarService = GoogleCalendarService();

  ProgramDataModel? _programData;
  Set<String> _savedItemIds = {};

  List<ProgramItemModel> _agendaItems = [];
  Map<DateTime, List<ProgramItemModel>> _groupedAgenda = {};

  bool isLoading = true;
  int _selectedDayIndex = 0;
  List<DateTime> _allProgramDays = [];

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // 💡 Map program types to specific colors
  static final Map<String, Color> _typeColors = {
    // Atelier: #61CE70 (Green)
    'atelier': const Color(0xFF61CE70),
    // Conférence/Conférance: Blue
    'conférence': const Color(0xFF2196F3),
    'conférance': const Color(0xFF2196F3),
    // Panel: Orange
    'panel': const Color(0xFFFF9800),
  };

  // 💡 Helper function to get text color based on type
  Color _getColorForType(String type, AppThemeData theme) {
    final normalizedType = type.toLowerCase().trim();

    Color backgroundColor = _typeColors[normalizedType] ?? theme.blackColor.withOpacity(0.05);

    Color textColor;
    if (backgroundColor == const Color(0xFF61CE70) ||
        backgroundColor == const Color(0xFF2196F3) ||
        backgroundColor == const Color(0xFFFF9800)) {
      textColor = Colors.white;
    } else {
      textColor = theme.blackColor.withOpacity(0.7);
    }

    return textColor;
  }

  // 💡 Helper function to get background color
  Color _getBackgroundColorForType(String type, AppThemeData theme) {
    final normalizedType = type.toLowerCase().trim();
    return _typeColors[normalizedType] ?? theme.blackColor.withOpacity(0.05);
  }

  @override
  void initState() {
    super.initState();
    _loadAgendaData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchQuery != _searchController.text.trim()) {
      _searchQuery = _searchController.text.trim();
      setState(() {});
    }
  }

  Future<void> _loadAgendaData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // 1. Fetch all program data
      _programData = await _apiService.fetchProgramDetails();
      print("DEBUG: API fetched ${_programData?.programs.length ?? 0} program items.");

      // 2. Get saved item IDs from local storage
      _savedItemIds = await _localService.getSavedAgendaItemIds();
      print("DEBUG: Saved Item IDs Loaded: $_savedItemIds");

      // 3. Filter program items based on saved IDs
      _agendaItems = _programData!.programs
          .where((item) => _savedItemIds.contains(item.id.toString()))
          .toList();

      print("DEBUG: Filtered Agenda Items Count: ${_agendaItems.length}");

      // 4. Group only the saved items by date
      _groupAgendaItems(_agendaItems);

      // 5. Populate ALL days from program data (FIXED LOGIC HERE)
      _extractAllProgramDays();

    } catch (e) {
      print("Error loading agenda data: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _extractAllProgramDays() {
    if (_programData == null) {
      _allProgramDays = [];
      return;
    }

    _allProgramDays = _programData!.periods.map((dateString) {
      try {
        DateTime? parsedDate;

        // Check for the dateDeb format (MM/dd/yyyy h:mm a)
        if (dateString.contains(':')) {
          parsedDate = DateFormat('MM/dd/yyyy h:mm a').parse(dateString);

          // 🎯 FIX: Check and handle the yyyy-MM-dd format (e.g., 2025-09-29)
        } else if (dateString.contains('-') && dateString.length == 10) {
          parsedDate = DateFormat('yyyy-MM-dd').parse(dateString);

          // Check for MM/dd/yyyy format (less likely in periods, but safe)
        } else if (dateString.contains('/') && dateString.length == 10) {
          parsedDate = DateFormat('MM/dd/yyyy').parse(dateString);

        } else {
          parsedDate = DateTime.parse(dateString);
        }

        // Normalize to midnight for comparison
        final day = DateTime(parsedDate!.year, parsedDate.month, parsedDate.day);
        print("DEBUG: Periods Date String: $dateString -> Parsed Day: $day");
        return day;
      } catch (e) {
        print("ERROR: Failed to parse period date: $dateString. Error: $e");
        return null;
      }
    }).where((date) => date != null).cast<DateTime>().toSet().toList();

    _allProgramDays.sort((a, b) => a.compareTo(b));

    if (_allProgramDays.isNotEmpty && _selectedDayIndex >= _allProgramDays.length) {
      _selectedDayIndex = 0;
    }
    print("DEBUG: Unique Program Days: ${_allProgramDays.length}");
  }


  void _groupAgendaItems(List<ProgramItemModel> items) {
    _groupedAgenda = {};

    for (var item in items) {
      try {
        // This format MUST match the API's dateDeb field (e.g., 09/29/2025 12:00 PM)
        final inputFormat = DateFormat('MM/dd/yyyy h:mm a');
        final itemDate = inputFormat.parse(item.dateDeb);
        // Normalize to day start (midnight) for grouping
        final day = DateTime(itemDate.year, itemDate.month, itemDate.day);

        if (!_groupedAgenda.containsKey(day)) {
          _groupedAgenda[day] = [];
        }
        _groupedAgenda[day]!.add(item);
        print("DEBUG: Item ID ${item.id} (${item.title}) grouped to Day: $day");

      } catch (e) {
        print("ERROR: Failed to parse item dateDeb: ${item.dateDeb} for item ID: ${item.id}. Error: $e");
        // Skip items with invalid dates
      }
    }

    print("DEBUG: Total Days with Saved Items: ${_groupedAgenda.length}");

    // Sort items within each day by start time
    _groupedAgenda.forEach((day, list) {
      list.sort((a, b) {
        try {
          final timeA = DateFormat('MM/dd/yyyy h:mm a').parse(a.dateDeb);
          final timeB = DateFormat('MM/dd/yyyy h:mm a').parse(b.dateDeb);
          return timeA.compareTo(timeB);
        } catch (e) {
          return 0;
        }
      });
    });
  }

  void _removeItem(ProgramItemModel item) async {
    await _localService.removeFromAgenda(item.id.toString());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.title} removed from agenda.')),
    );
    _loadAgendaData();
  }


  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: theme.whiteColor,
      appBar: AppBar(
        title: Text(
          "My Agenda",
          style: TextStyle(color: theme.whiteColor, fontWeight: FontWeight.bold, fontSize: 30),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            prefs.setString("Data", "99");
            // If called directly, push back to welcome page
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const WelcomPage()));
          },
        ),
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.whiteColor,
        centerTitle: true,
        elevation: 0,
        actions: const [],
        bottom: PreferredSize(
          // Increased height for both Search Bar and Day Selector
          preferredSize: Size.fromHeight(height * 0.08 + 55),
          child: Column(
            children: [
              // RESTORED SEARCH BAR
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.01),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Recherche',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: height * 0.015),
                    ),
                    style: TextStyle(fontSize: height * 0.02, color: Colors.white),
                    cursorColor: theme.secondaryColor,
                  ),
                ),
              ),
              // Day Selector
              _buildDaySelector(theme, width, height),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
      body: isLoading
          ? Center(
        child: SpinKitThreeBounce(color: theme.secondaryColor, size: 30.0),
      )
          : _buildAgendaContent(theme, width),

      // Floating Action Button to navigate to ProgramScreen
      floatingActionButton: FadeInUp(
        child: FloatingActionButton(
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            //navigat
            prefs.setString("Data", "11");
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const WelcomPage()));
          },
          backgroundColor: theme.secondaryColor,
          child: Icon(Icons.add, color: theme.whiteColor, size: 30),
        ),
      ),
    );
  }

  Widget _buildDaySelector(AppThemeData theme, double width, double height) {
    if (_allProgramDays.isEmpty) {
      return SizedBox(height: height * 0.08);
    }

    return Container(
      color: theme.primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: _allProgramDays.asMap().entries.map((entry) {
            int idx = entry.key;
            DateTime date = entry.value;
            bool isSelected = idx == _selectedDayIndex;

            String dateLabel = DateFormat('dd MMM.').format(date).toUpperCase();

            // Check if THIS date has any saved sessions to show a marker
            bool hasSavedItems = _groupedAgenda.containsKey(date);

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDayIndex = idx;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8.0),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black.withOpacity(0.4) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : theme.whiteColor.withOpacity(0.5),
                    width: 1.0,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Text(
                      dateLabel,
                      style: TextStyle(
                        color: theme.whiteColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: width * 0.038,
                      ),
                    ),
                    if (hasSavedItems && !isSelected)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAgendaContent(AppThemeData theme, double width) {

    final currentDay = _allProgramDays.isNotEmpty ? _allProgramDays[_selectedDayIndex] : null;
    List<ProgramItemModel> sessionsForDay = _groupedAgenda[currentDay] ?? [];

    print("DEBUG: Selected Day: $currentDay | Sessions to Display: ${sessionsForDay.length}");


    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      sessionsForDay = sessionsForDay.where((item) {
        final speakerNames = item.speakers.map((s) => s.fullName.toLowerCase()).join(' ');

        return item.title.toLowerCase().contains(query) ||
            item.description.toLowerCase().contains(query) ||
            item.location.toLowerCase().contains(query) ||
            speakerNames.contains(query);
      }).toList();
    }

    // 1. Overall Empty Agenda (no saved items at all)
    if (_agendaItems.isEmpty) {
      return Center(
        child: FadeIn(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today, size: 80, color: theme.primaryColor.withOpacity(0.5)),
              const SizedBox(height: 20),
              Text(
                "Your Agenda is Empty",
                style: TextStyle(
                    color: theme.blackColor.withOpacity(0.87),
                    fontSize: width * 0.05,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                "Add sessions from the Program screen to see them here.",
                style: TextStyle(color: theme.blackColor.withOpacity(0.6), fontSize: width * 0.035),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // 2. Empty Search Results
    if (_searchQuery.isNotEmpty && sessionsForDay.isEmpty) {
      return Center(
        child: FadeIn(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 80, color: theme.primaryColor.withOpacity(0.5)),
              const SizedBox(height: 20),
              Text(
                "No Search Results",
                style: TextStyle(
                    color: theme.blackColor.withOpacity(0.87),
                    fontSize: width * 0.05,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                "Try refining your search query.",
                style: TextStyle(color: theme.blackColor.withOpacity(0.6), fontSize: width * 0.035),
                // 🎯 CORRECTED SYNTAX
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // 3. No Saved Sessions on Selected Day (but other days have sessions)
    if (sessionsForDay.isEmpty) {
      return Center(
        child: FadeIn(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 80, color: theme.primaryColor.withOpacity(0.5)),
              const SizedBox(height: 20),
              Text(
                "No Saved Sessions on this Day",
                style: TextStyle(
                    color: theme.blackColor.withOpacity(0.87),
                    fontSize: width * 0.05,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                "Check other dates or add sessions from the Program.",
                style: TextStyle(color: theme.blackColor.withOpacity(0.6), fontSize: width * 0.035),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }


    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: sessionsForDay.length,
        itemBuilder: (_, int position) {
          final item = sessionsForDay[position];
          return _buildAgendaCard(item, width, theme);
        },
      ),
    );
  }

  Widget _buildAgendaCard(ProgramItemModel item, double width, AppThemeData theme) {
    String startTime = 'N/A';
    String endTime = 'N/A';
    try {
      final inputFormat = DateFormat('MM/dd/yyyy h:mm a');
      if (item.dateDeb.isNotEmpty) {
        startTime = DateFormat('HH:mm').format(inputFormat.parse(item.dateDeb));
      }
      if (item.dateFin.isNotEmpty) {
        endTime = DateFormat('HH:mm').format(inputFormat.parse(item.dateFin));
      }
    } catch (e) {
      // Time format error
    }

    String speakerNames = item.speakers.map((s) => s.fullName).join(', ');
    // Subtitle now only holds location, speakers are in a separate row
    String subtitle = item.location;
    if (item.location == 'Not specified' || item.location.isEmpty) {
      subtitle = "Details non disponibles";
    }

    // 💡 COLOR LOGIC: Get dynamic colors for the Chip
    Color chipBackgroundColor = _getBackgroundColorForType(item.type, theme);
    Color chipTextColor = _getColorForType(item.type, theme);


    return Card(
      color: theme.whiteColor,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailProgramScreen(programItem: item),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time Box
              Container(
                width: width * 0.2,
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  color: theme.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(startTime, style: TextStyle(color: theme.secondaryColor, fontSize: 14, fontWeight: FontWeight.bold)),
                    Text('-', style: TextStyle(color: theme.secondaryColor, fontSize: 12)),
                    Text(endTime, style: TextStyle(color: theme.secondaryColor, fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              SizedBox(width: width * 0.04),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.blackColor.withOpacity(0.87)), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),

                    // 💡 UPDATED: Speaker with Icon
                    if (speakerNames.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          children: [
                            Icon(Icons.person, size: 16, color: theme.secondaryColor),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                speakerNames,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.blackColor.withOpacity(0.87),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Location (now the main subtitle)
                    Text(subtitle, style: TextStyle(fontSize: 14, color: theme.blackColor.withOpacity(0.6)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),

                    // Type Tag with dynamic color
                    Chip(
                      label: Text(
                        item.type,
                        style: TextStyle(
                          fontSize: 12,
                          color: chipTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: chipBackgroundColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                    ),
                  ],
                ),
              ),
              // Remove/Calendar Actions
              Column(
                children: [
                  // Remove from Agenda Button (Bookmark icon)
                  GestureDetector(
                    onTap: () => _removeItem(item),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                      child: Icon(
                        Icons.bookmark,
                        color: theme.secondaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Add to Google Calendar Button
                  GestureDetector(
                    onTap: () {
                      _calendarService.createCalendarEvent(context, item);
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(left: 8.0, top: 4.0),
                      child: Icon(
                        Icons.calendar_today,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}