// lib/screens/SpeakersScreen.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../api_services/speaker_api_service.dart';
import 'details/DetailSpeakeres.dart';
import '../main.dart';
import '../model/speakers_model.dart';
import '../providers/theme_provider.dart';

class SpeakersScreen extends StatefulWidget {
  const SpeakersScreen({Key? key}) : super(key: key);

  @override
  _SpeakersScreenState createState() => _SpeakersScreenState();
}

class _SpeakersScreenState extends State<SpeakersScreen> {
  final SpeakerApiService _apiService = SpeakerApiService();
  late SharedPreferences prefs;
  List<Speakers> _allSpeakers = [];
  List<Speakers> _recommendedSpeakers = []; // Will be empty with the new API
  List<Speakers> _otherSpeakers = [];
  List<Speakers> _filteredOtherSpeakers = [];

  List<String> _eventPeriods = []; // Will be empty with the new API

  bool isLoading = true;
  TextEditingController _searchController = TextEditingController();
  bool _isFavoriteFilterActive = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterSpeakers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  _loadData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final SpeakersDataModel speakerData = await _apiService
          .fetchSpeakersWithSessions();

      setState(() {
        _allSpeakers = speakerData.speakers;
        _eventPeriods = speakerData.periods; // Likely an empty array [] now

        // ⚠️ Since the new API doesn't specify 'isRecommended', all fetched speakers
        // are initially considered 'other speakers' if the model defaults isRecommended to false.
        // If the model had a dedicated 'isRecommended' field that was true, this would change.
        // Based on your model update, it defaults to false, so all go to _otherSpeakers.
        _recommendedSpeakers = _allSpeakers
            .where((s) => s.isRecommended)
            .toList();
        _otherSpeakers = _allSpeakers.where((s) => !s.isRecommended).toList();

        // If _recommendedSpeakers is empty (which it will be with the new API),
        // ensure _otherSpeakers gets all of them.
        if (_recommendedSpeakers.isEmpty) {
          _otherSpeakers = _allSpeakers;
        }

        _otherSpeakers.sort((a, b) => a.nom.compareTo(b.nom));

        _filteredOtherSpeakers = _otherSpeakers;
        isLoading = false;
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString().replaceFirst('Exception: ', ''),
        toastLength: Toast.LENGTH_LONG,
      );
      setState(() {
        isLoading = false;
        _allSpeakers = [];
        _recommendedSpeakers = [];
        _otherSpeakers = [];
        _filteredOtherSpeakers = [];
        _eventPeriods = [];
      });
    }
  }

  void _filterSpeakers() {
    String query = _searchController.text.toLowerCase();
    List<Speakers> currentSourceList = _otherSpeakers;

    List<Speakers> searchResults = currentSourceList.where((speaker) {
      final fullName = "${speaker.prenom} ${speaker.nom}".toLowerCase();
      final poste = speaker.poste.toLowerCase();
      // ✅ Using the 'company' getter for the search filter
      final company = speaker.company.toLowerCase();

      return fullName.contains(query) ||
          poste.contains(query) ||
          company.contains(query);
    }).toList();

    if (_isFavoriteFilterActive) {
      searchResults = searchResults
          .where((speaker) => speaker.isFavorite)
          .toList();
    }

    setState(() {
      _filteredOtherSpeakers = searchResults;
    });
  }

  void _toggleFavorite(Speakers speaker) {
    setState(() {
      speaker.isFavorite = !speaker.isFavorite;
      _filterSpeakers();
    });
  }

  void _toggleFavoriteFilter() {
    setState(() {
      _isFavoriteFilterActive = !_isFavoriteFilterActive;
      _filterSpeakers();
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
        )) ??
        false;
  }

  // Helper widget to display network image with loading and error handling
  Widget _buildSpeakerImage(
    String? imageUrl,
    double size,
    Color placeholderColor,
  ) {
    // 🚀 NEW LOGIC: Construct full URL using imageBaseUrl from service
    final String imageBaseUrl = SpeakerApiService.imageBaseUrl;
    // Default image if imageUrl is null or empty. Use a sensible default relative path.
    final String defaultPic = 'ICON-EMEC.png';
    final String imagePath = imageUrl?.isNotEmpty == true
        ? imageUrl!
        : defaultPic;

    // Construct the full URL by combining base URL and image path
    final String finalUrl = imageBaseUrl + imagePath;

    final bool isNetworkImage = finalUrl.startsWith('http');

    return ClipOval(
      child: isNetworkImage
          ? Image.network(
              finalUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/placeholder.png', // Final local asset fallback
                width: size,
                height: size,
                fit: BoxFit.cover,
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: size,
                  height: size,
                  color: placeholderColor,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: placeholderColor.computeLuminance() > 0.5
                          ? Colors.black54
                          : Colors.white70,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            )
          : Image.asset(finalUrl, width: size, height: size, fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 💡 THEME ACCESS
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    Map<String, List<Speakers>> groupedOtherSpeakers = {};
    for (var speaker in _filteredOtherSpeakers) {
      String firstLetter = speaker.nom.isNotEmpty
          ? speaker.nom[0].toUpperCase()
          : '#';
      if (!groupedOtherSpeakers.containsKey(firstLetter)) {
        groupedOtherSpeakers[firstLetter] = [];
      }
      groupedOtherSpeakers[firstLetter]!.add(speaker);
    }
    List<String> sortedKeys = groupedOtherSpeakers.keys.toList()..sort();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.whiteColor, // 💡 THEMED
        appBar: AppBar(
          backgroundColor: theme.primaryColor,
          // 💡 THEMED
          elevation: 0,
          title: Text(
            'Speakers',
            style: TextStyle(
              color: theme.whiteColor,
              fontWeight: FontWeight.bold,
            ), // 💡 THEMED
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: theme.whiteColor),
            // 💡 THEMED
            onPressed: () async {
              prefs = await SharedPreferences.getInstance();
              prefs.setString("Data", "99");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const WelcomPage()),
              );
            },
          ),
          centerTitle: true,
          actions: [
            /*      IconButton(
       icon: Icon(Icons.tune, color: theme.whiteColor), // 💡 THEMED
       onPressed: () {
        // Handle filter
       },
      ),
      IconButton(
       icon: Icon(
        _isFavoriteFilterActive ? Icons.star : Icons.star_border,
        color: _isFavoriteFilterActive ? theme.secondaryColor : theme.whiteColor, // 💡 THEMED
       ),
       onPressed: _toggleFavoriteFilter,
      ),*/
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(height * 0.08),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: height * 0.01,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.whiteColor.withOpacity(0.2), // 💡 THEMED
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    // 🎯 UPDATED HINT TEXT
                    hintText: 'Recherche par nom, poste ou compagnie',
                    hintStyle: TextStyle(
                      color: theme.whiteColor.withOpacity(0.7),
                    ),
                    // 💡 THEMED
                    prefixIcon: Icon(Icons.search, color: theme.whiteColor),
                    // 💡 THEMED
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: height * 0.015,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: height * 0.02,
                    color: theme.whiteColor,
                  ), // 💡 THEMED
                ),
              ),
            ),
          ),
        ),
        body: isLoading
            ? Center(
                child: SpinKitThreeBounce(
                  color: theme.secondaryColor, // 💡 THEMED
                  size: 30.0,
                ),
              )
            : FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Recommended Speakers Section ---
                      if (_recommendedSpeakers.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            width * 0.04,
                            height * 0.02,
                            width * 0.04,
                            height * 0.01,
                          ),
                          child: Text(
                            'Recommended',
                            style: TextStyle(
                              fontSize: height * 0.02,
                              fontWeight: FontWeight.bold,
                              color: theme.blackColor, // 💡 THEMED
                            ),
                          ),
                        ),
                      if (_recommendedSpeakers.isNotEmpty)
                        SizedBox(
                          height: height * 0.22,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.04,
                            ),
                            itemCount: _recommendedSpeakers.length,
                            itemBuilder: (context, index) {
                              return _buildRecommendedSpeakerCard(
                                _recommendedSpeakers[index],
                                width,
                                height,
                                theme,
                              );
                            },
                          ),
                        ),
                      SizedBox(height: height * 0.02),

                      // --- Other Speakers (Grouped List) Section ---
                      if (_filteredOtherSpeakers.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              _searchController.text.isNotEmpty
                                  ? "No speakers found for your search."
                                  : (_isFavoriteFilterActive
                                        ? "No favorited speakers to display."
                                        : "No speakers to display."),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                              // 💡 STANDARD GREY
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else
                        ...sortedKeys.map((letter) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  width * 0.04,
                                  height * 0.02,
                                  width * 0.04,
                                  height * 0.01,
                                ),
                                child: Text(
                                  letter,
                                  style: TextStyle(
                                    fontSize: height * 0.02,
                                    fontWeight: FontWeight.bold,
                                    color: theme.blackColor, // 💡 THEMED
                                  ),
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.04,
                                ),
                                itemCount: groupedOtherSpeakers[letter]!.length,
                                itemBuilder: (context, index) {
                                  return _buildSpeakerListItem(
                                    groupedOtherSpeakers[letter]![index],
                                    width,
                                    height,
                                    theme,
                                  );
                                },
                              ),
                            ],
                          );
                        }).toList(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // Widget for Recommended Speaker Cards (horizontal scroll)
  Widget _buildRecommendedSpeakerCard(
    Speakers speaker,
    double width,
    double height,
    dynamic theme,
  ) {
    return Container(
      width: width * 0.35,
      margin: EdgeInsets.only(right: width * 0.03),
      decoration: BoxDecoration(
        color: theme.whiteColor, // 💡 THEMED
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2), // 💡 STANDARD GREY
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailSpeakersScreen(
                speaker: speaker,
                periods: _eventPeriods,
              ),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(width * 0.02),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  _buildSpeakerImage(
                    speaker.pic,
                    width * 0.18,
                    Colors.grey[200]!,
                  ),
                  // 💡 STANDARD GREY Placeholder
                  /*Positioned(
          top: 0,
          right: 0,
          child: IconButton(
           icon: Icon(
            speaker.isFavorite ? Icons.star : Icons.star_border,
            color: speaker.isFavorite ? theme.secondaryColor : Colors.grey[500], // 💡 THEMED/STANDARD GREY
            size: width * 0.05,
           ),
           onPressed: () => _toggleFavorite(speaker),
          ),
         ),*/
                ],
              ),
              SizedBox(height: height * 0.01),
              Text(
                "${speaker.prenom} ${speaker.nom}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: height * 0.018,
                  fontWeight: FontWeight.bold,
                  color: theme.blackColor, // 💡 THEMED
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2.0),
              // ✅ Using the 'company' getter for company name
              if (speaker.company.isNotEmpty)
                Text(
                  speaker.company,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: height * 0.014,
                    color: theme.secondaryColor, // Highlight company name
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              Text(
                speaker.poste,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: height * 0.014,
                  color: Colors.grey[700], // 💡 STANDARD GREY
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for Speaker List Items (vertical list)
  Widget _buildSpeakerListItem(
    Speakers speaker,
    double width,
    double height,
    dynamic theme,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DetailSpeakersScreen(speaker: speaker, periods: _eventPeriods),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: height * 0.015),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 1.0),
          ), // 💡 STANDARD GREY
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _buildSpeakerImage(speaker.pic, width * 0.12, Colors.grey[200]!),
            // 💡 STANDARD GREY Placeholder
            SizedBox(width: width * 0.04),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${speaker.prenom} ${speaker.nom}",
                    style: TextStyle(
                      fontSize: height * 0.02,
                      fontWeight: FontWeight.bold,
                      color: theme.blackColor, // 💡 THEMED
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  // ✅ Using the 'company' getter for company name
                  if (speaker.company.isNotEmpty)
                    Text(
                      speaker.company,
                      style: TextStyle(
                        fontSize: height * 0.016,
                        color: theme.secondaryColor, // Highlight company name
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    speaker.poste,
                    style: TextStyle(
                      fontSize: height * 0.016,
                      color: Colors.grey[700], // 💡 STANDARD GREY
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            /*IconButton(
       icon: Icon(
        speaker.isFavorite ? Icons.star : Icons.star_border,
        color: speaker.isFavorite ? theme.secondaryColor : Colors.grey[500], // 💡 THEMED/STANDARD GREY
        size: width * 0.06,
       ),
       onPressed: () => _toggleFavorite(speaker),
      ),*/
          ],
        ),
      ),
    );
  }
}
