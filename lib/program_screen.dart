// lib/screens/program_screen.dart

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 💡 CORRECTED IMPORT PATH FOR API SERVICE
import '../api_services/program_api_service.dart';
import '../services/agenda_local_service.dart';
import '../services/google_calendar_service.dart';
import '../model/program_model.dart';

// Assuming these are defined elsewhere
import '../providers/theme_provider.dart';
import '../main.dart';
import '../model/app_theme_data.dart';
import 'My Agenda.dart';
import 'details/detail_program_screen.dart';

class ProgramScreen extends StatefulWidget {
  const ProgramScreen({Key? key}) : super(key: key);

  @override
  _ProgramScreenState createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen> {
  // 💡 Initialization remains correct
  final ProgramApiService _apiService = ProgramApiService();
  final AgendaLocalService _agendaLocalService = AgendaLocalService();
  final GoogleCalendarService _calendarService = GoogleCalendarService();

  ProgramDataModel? _programData;

  List<DateTime> uniqueDays = [];
  int _selectedDayIndex = 0;

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<ProgramItemModel> filteredAgendaItems = [];
  bool isLoading = true;

  Set<String> _savedItemIds = {};

  // 💡 NEW: Map program types to specific colors
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
    // Normalize type to lowercase for case-insensitive matching
    final normalizedType = type.toLowerCase().trim();

    // Get the background color
    Color backgroundColor = _typeColors[normalizedType] ?? theme.blackColor.withOpacity(0.05);

    // Determine a readable text color
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
    initializeDateFormatting('fr_FR', null).then((_) {
      _loadData();
    });
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
      _applyFilters();
    }
  }

  Future<void> _loadData() async {
    isLoading = true;
    if (mounted) setState(() {});

    try {
      _programData = await _apiService.fetchProgramDetails();
      _extractUniqueDays();

      if (uniqueDays.isNotEmpty) {
        _selectedDayIndex = 0;
      }

      _savedItemIds = await _agendaLocalService.getSavedAgendaItemIds();

      _applyFilters();
    } catch (e) {
      print("Error loading program data: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _toggleAgendaItem(ProgramItemModel item) async {
    // Convert item.id to String
    final String itemId = item.id.toString();

    final bool wasAdded = await _agendaLocalService.toggleAgendaItem(itemId);

    _savedItemIds = await _agendaLocalService.getSavedAgendaItemIds();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.title} ${wasAdded ? 'added to' : 'removed from'} agenda.')),
    );

    setState(() {});
  }


  void _extractUniqueDays() {
    if (_programData == null) {
      uniqueDays = [];
      return;
    }
    uniqueDays = _programData!.periods.map((dateString) {
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        return null;
      }
    }).where((date) => date != null).cast<DateTime>().toList();
    uniqueDays.sort((a, b) => a.compareTo(b));
  }

  void _applyFilters() {
    if (_programData == null || uniqueDays.isEmpty || _selectedDayIndex >= uniqueDays.length) {
      filteredAgendaItems = [];
      if (mounted) setState(() {});
      return;
    }

    DateTime selectedDay = uniqueDays[_selectedDayIndex];

    // 1. Filter by Selected Day
    List<ProgramItemModel> dailyItems = _programData!.programs.where((item) {
      try {
        final itemDate = DateFormat('MM/dd/yyyy h:mm a').parse(item.dateDeb);
        return itemDate.year == selectedDay.year &&
            itemDate.month == selectedDay.month &&
            itemDate.day == selectedDay.day;
      } catch (e) {
        return false;
      }
    }).toList();

    List<ProgramItemModel> categoryFilteredItems = dailyItems;

    // 2. Filter by Search Query
    if (_searchQuery.isNotEmpty) {
      categoryFilteredItems = categoryFilteredItems.where((item) {
        final query = _searchQuery.toLowerCase();
        final speakerNames = item.speakers.map((s) => s.fullName.toLowerCase()).join(' ');

        return item.title.toLowerCase().contains(query) ||
            item.description.toLowerCase().contains(query) ||
            item.location.toLowerCase().contains(query) ||
            speakerNames.contains(query);
      }).toList();
    }

    // Sort by Start Time
    categoryFilteredItems.sort((a, b) {
      try {
        final timeA = DateFormat('MM/dd/yyyy h:mm a').parse(a.dateDeb);
        final timeB = DateFormat('MM/dd/yyyy h:mm a').parse(b.dateDeb);
        return timeA.compareTo(timeB);
      } catch (e) {
        return 0;
      }
    });

    filteredAgendaItems = categoryFilteredItems;

    if (mounted) setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: theme.whiteColor,
      appBar: AppBar(
        title: const Text(
          "Program",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            prefs.setString("Data", "99");
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const WelcomPage()));
          },
        ),
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.whiteColor,
        centerTitle: true,
        elevation: 0,
        actions: [
          // Agenda Icon to navigate to AgendaScreen
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              prefs.setString("Data", "10");
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => const WelcomPage()));
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(height * 0.08 + 55),
          child: Column(
            children: [
              // Search Bar Decoration
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
              // Custom Date Selector (Days)
              _buildDaySelector(theme, width, height),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Agenda Content Area
          Expanded(
            child: isLoading
                ? Center(
              child: CircularProgressIndicator(color: theme.secondaryColor),
            )
                : filteredAgendaItems.isEmpty
                ? _buildEmptyState(theme, width)
                : FadeInUp(
              duration: const Duration(milliseconds: 500),
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: filteredAgendaItems.length,
                itemBuilder: (_, int position) {
                  final item = filteredAgendaItems[position];
                  return _buildAgendaCard(item, width, theme);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector(AppThemeData theme, double width, double height) {
    return Container(
      color: theme.primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: isLoading || uniqueDays.isEmpty
          ? SizedBox(height: height * 0.05)
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: uniqueDays.asMap().entries.map((entry) {
            int idx = entry.key;
            DateTime date = entry.value;
            bool isSelected = idx == _selectedDayIndex;

            String dateLabel = DateFormat('dd MMM.', 'fr_FR').format(date).toUpperCase();

            // Logic to check if any saved agenda item belongs to this day
            bool hasSavedItems = _programData?.programs.any((item) {
              if (_savedItemIds.contains(item.id.toString())) {
                try {
                  final itemDate = DateFormat('MM/dd/yyyy h:mm a').parse(item.dateDeb);
                  return itemDate.year == date.year && itemDate.month == date.month && itemDate.day == date.day;
                } catch (e) {
                  return false;
                }
              }
              return false;
            }) ?? false;


            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDayIndex = idx;
                  _applyFilters();
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

  Widget _buildCategoryTabs(AppThemeData theme, double width) {
    return const SizedBox.shrink();
  }

  Widget _buildEmptyState(AppThemeData theme, double width) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: width * 0.25,
            height: width * 0.2,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(width * 0.1),
              border: Border.all(color: theme.primaryColor, width: 2),
            ),
            child: Center(
              child: Icon(
                Icons.list_alt,
                size: width * 0.12,
                color: theme.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _searchQuery.isNotEmpty ? "No results found" : "No activities",
            style: TextStyle(
                color: theme.blackColor.withOpacity(0.87),
                fontSize: width * 0.045,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            _searchQuery.isNotEmpty
                ? "Try refining your search query."
                : "No activities planned for this day.",
            style: TextStyle(color: theme.blackColor.withOpacity(0.6), fontSize: width * 0.035),
            textAlign: TextAlign.center,
          ),
        ],
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
      print("Error formatting time for card: $e");
    }

    String speakerNames = item.speakers.map((s) => s.fullName).join(', ');

    // 💡 CRITICAL FIX: Normalize the location string to ensure 'Not specified' or empty means truly empty.
    String location = item.location;
    if (location.isEmpty || location == 'Not specified' || location == 'Details non disponibles') {
      location = '';
    }

    // Use .toString() when checking membership in the set
    bool isInAgenda = _savedItemIds.contains(item.id.toString());

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
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.blackColor.withOpacity(0.87),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // 💡 Speaker with Icon
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

                    // 💡 LOCATION ROW: Only renders if the 'location' string is NOT empty after normalization.
                    if (location.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            // Location Icon
                            Icon(Icons.location_on, size: 16, color: theme.secondaryColor),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.blackColor.withOpacity(0.6),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Type Tag
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
              // Agenda Icon in Card with toggle action
              GestureDetector(
                onTap: () => _toggleAgendaItem(item), // Toggle the item in agenda
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                  child: Icon(
                    isInAgenda ? Icons.bookmark : Icons.bookmark_border,
                    color: isInAgenda ? theme.secondaryColor : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}