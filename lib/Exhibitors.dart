// lib/exhibitors_screen.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:emecexpo/details/ExhibitorsMenu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:emecexpo/providers/theme_provider.dart';
// 💡 IMPORTANT: Import CachedNetworkImage
import 'package:cached_network_image/cached_network_image.dart';

import 'package:emecexpo/model/exhibitors_model.dart';
import 'package:emecexpo/api_services/exhibitor_api_service.dart';
import 'package:emecexpo/details/DetailExhibitors.dart';

import 'main.dart';
import 'model/app_theme_data.dart';

class ExhibitorsScreen extends StatefulWidget {
  const ExhibitorsScreen({Key? key}) : super(key: key);

  @override
  _ExhibitorsScreenState createState() => _ExhibitorsScreenState();
}

class _ExhibitorsScreenState extends State<ExhibitorsScreen> {
  late SharedPreferences prefs;
  List<ExhibitorsClass> _allApiExhibitors = [];

  List<ExhibitorsClass> _sponsors = [];
  List<ExhibitorsClass> _otherExhibitors = [];
  List<ExhibitorsClass> _filteredOtherExhibitors = [];

  bool isLoading = true;
  TextEditingController _searchController = TextEditingController();
  bool _isStarFilterActive = false;

  final ExhibitorApiService _exhibitorApiService = ExhibitorApiService();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterExhibitors);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Helper to get sponsor color for the border (Uses ExhibitorsClass)
  Color _getSponsorBorderColor(ExhibitorsClass exhibitor) {
    // Check sponsor type for color assignment
    final String? sponsorType = exhibitor.sponsorType?.toLowerCase()?.trim(); // Added trim for safety

    if (sponsorType == 'diamond') {
      return const Color(0xff00c1c1); // Aqua
    } else if (sponsorType == 'platinum') { // Corrected: removed extra space
      return Colors.grey.shade600; // Grey
    } else if (sponsorType == 'gold') {
      return const Color(0xffCE8946);
    }else if (sponsorType == 'bronz'){
      return const Color(0xffceb346);
    }

    // Default border color if not a recognized sponsor type or not a sponsor
    return Colors.grey.withOpacity(0.2);
  }

  // Helper to determine sort rank for sponsors
  int _getSponsorRank(String? type) {
    switch (type?.toLowerCase()?.trim()) { // Added trim for safety
      case 'diamond':
        return 1;
      case 'platinum':
        return 2;
      case 'gold':
        return 3;
      case 'bronze':
        return 4;
      default:
        return 99; // Non-sponsored or uncategorized at the end
    }
  }

  _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // LOAD ALL EXHIBITORS from the single API service
      _allApiExhibitors = await _exhibitorApiService.getExhibitors();
      print('API Exhibitors Fetched: ${_allApiExhibitors.length} items');

      // 💡 KEY CHANGE: Filter out all 'partenaire' entries from the main list.
      final List<ExhibitorsClass> validExhibitors = _allApiExhibitors
          .where((e) => e.expositionType?.toLowerCase() != 'partenaire')
          .toList();

      // Filter the valid list into Sponsors and Other Exhibitors
      _sponsors = validExhibitors
          .where((e) => e.expositionType?.toLowerCase() == 'sponsor')
          .toList();

      _otherExhibitors = validExhibitors
          .where((e) => e.expositionType?.toLowerCase() != 'sponsor')
          .toList();

      // Sort Sponsors by type priority for display
      _sponsors.sort((a, b) {
        int aRank = _getSponsorRank(a.sponsorType);
        int bRank = _getSponsorRank(b.sponsorType);
        if (aRank != bRank) {
          return aRank.compareTo(bRank);
        }
        return a.title.compareTo(b.title); // Secondary sort by title
      });

      // Sort Other Exhibitors alphabetically
      _otherExhibitors.sort((a, b) => a.title.compareTo(b.title));

      _filteredOtherExhibitors = _otherExhibitors;
      print('Sponsors List Populated: ${_sponsors.length} items');
      print('Main Exhibitors List Populated: ${_otherExhibitors.length} items');
    } catch (e) {
      print("Error loading ALL data: $e");
      Fluttertoast.showToast(msg: "Failed to load all data: ${e.toString()}", toastLength: Toast.LENGTH_LONG);
    } finally {
      setState(() {
        isLoading = false;
        print('isLoading set to false');
      });
    }
  }

  void _filterExhibitors() {
    String query = _searchController.text.toLowerCase();
    print('Search query: "$query"');

    List<ExhibitorsClass> searchResults = _otherExhibitors.where((exhibitor) {
      final title = exhibitor.title.toLowerCase();
      final stand = exhibitor.stand.toLowerCase();
      final adress = exhibitor.adress.toLowerCase();
      final shortDescription = exhibitor.shortDiscriptions.toLowerCase();
      final fullDescription = exhibitor.discriptions.toLowerCase();

      return title.contains(query) ||
          stand.contains(query) ||
          adress.contains(query) ||
          shortDescription.contains(query) ||
          fullDescription.contains(query);
    }).toList();

    if (_isStarFilterActive) {
      searchResults = searchResults.where((exhibitor) => exhibitor.star).toList();
    }

    setState(() {
      _filteredOtherExhibitors = searchResults;
      print('Search results count for query "$query": ${_filteredOtherExhibitors.length}');
      if (searchResults.isEmpty && query.isNotEmpty) {
        Fluttertoast.showToast(msg: "Search not found...!", toastLength: Toast.LENGTH_SHORT);
      } else if (searchResults.isEmpty && _isStarFilterActive && query.isEmpty) {
        Fluttertoast.showToast(msg: "No favorited exhibitors to show...!", toastLength: Toast.LENGTH_SHORT);
      }
    });
  }

  void _toggleStarFilter() {
    setState(() {
      _isStarFilterActive = !_isStarFilterActive;
      _filterExhibitors();
    });
  }

  // NEW WIDGET: Error message for Sponsors
  Widget _buildSponsorErrorState(AppThemeData theme) {
    return Container(
      width: double.infinity,
      height: 100, // Fixed height for visual consistency
      margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_outline, // Default icon
              color: Colors.grey, // Default icon color
              size: 30,
            ),
            const SizedBox(height: 5),
            const Text(
              "No sponsors available or failed to load.", // Default message
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    Map<String, List<ExhibitorsClass>> groupedOtherExhibitors = {};
    for (var exhibitor in _filteredOtherExhibitors) {
      String firstLetter = exhibitor.title.isNotEmpty ? exhibitor.title[0].toUpperCase() : '#';
      if (!groupedOtherExhibitors.containsKey(firstLetter)) {
        groupedOtherExhibitors[firstLetter] = [];
      }
      groupedOtherExhibitors[firstLetter]!.add(exhibitor);
    }
    List<String> sortedKeys = groupedOtherExhibitors.keys.toList()..sort();

    return FadeInDown(
      //onWillPop: _onWillPop,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: theme.whiteColor,
          appBar: AppBar(
            backgroundColor: theme.primaryColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: theme.whiteColor), // Assuming a light icon on a colored AppBar
              onPressed: () async{
                prefs = await SharedPreferences.getInstance();
                prefs.setString("Data", "99");
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => WelcomPage()));
              },
            ),
            title: Text(
              'Exhibitors',
              style: TextStyle(
                color: theme.whiteColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              // IconButton(
              //   icon: Icon(
              //     Icons.filter_list,
              //     color: theme.whiteColor,
              //   ),
              //   onPressed: () {
              //     Fluttertoast.showToast(msg: "Other filters coming soon!");
              //   },
              // ),
              /*IconButton(
                icon: Icon(
                  _isStarFilterActive ? Icons.star : Icons.star_border,
                  color: _isStarFilterActive ? theme.secondaryColor : theme.whiteColor,
                ),
                onPressed: _toggleStarFilter,
              ),*/
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(height * 0.08),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.01),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.whiteColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Recherche',
                      hintStyle: TextStyle(color: theme.whiteColor.withOpacity(0.7)),
                      prefixIcon: Icon(Icons.search, color: theme.whiteColor),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: height * 0.015),
                    ),
                    style: TextStyle(fontSize: height * 0.02, color: theme.whiteColor),
                  ),
                ),
              ),
            ),
          ),
          body: isLoading
              ? Center(
            child: SpinKitThreeBounce(
              color: theme.secondaryColor,
              size: 30.0,
            ),
          )
              : FadeInDown(
            duration: const Duration(milliseconds: 500),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recommended Exhibitors Section (Sponsors)
                  Padding(
                    padding: EdgeInsets.fromLTRB(width * 0.04, height * 0.02, width * 0.04, height * 0.01),
                    child: Text(
                      'Sponsors',
                      style: TextStyle(
                        fontSize: height * 0.02,
                        fontWeight: FontWeight.bold,
                        color: theme.blackColor,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.22,
                    child: _sponsors.isEmpty
                    // Show error state if no sponsors were loaded/found
                        ? _buildSponsorErrorState(theme)
                        : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                      itemCount: _sponsors.length,
                      itemBuilder: (context, index) {
                        // Use the ExhibitorsClass object
                        return _buildRecommendedExhibitorCard(_sponsors[index], width, height, theme);
                      },
                    ),
                  ),
                  SizedBox(height: height * 0.02),

                  // Alphabetically Grouped Other Exhibitors Section (from API)
                  Padding(
                    padding: EdgeInsets.fromLTRB(width * 0.04, height * 0.02, width * 0.04, height * 0.01),
                    child: Text(
                      'All Exhibitors',
                      style: TextStyle(
                        fontSize: height * 0.02,
                        fontWeight: FontWeight.bold,
                        color: theme.blackColor,
                      ),
                    ),
                  ),
                  if (_filteredOtherExhibitors.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          _searchController.text.isNotEmpty
                              ? "No exhibitors found for your search."
                              : (_isStarFilterActive ? "No favorited exhibitors to display." : "No exhibitors to display."),
                          style: const TextStyle(color: Colors.grey, fontSize: 16),
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
                            padding: EdgeInsets.fromLTRB(width * 0.04, height * 0.02, width * 0.04, height * 0.01),
                            child: Text(
                              letter,
                              style: TextStyle(
                                fontSize: height * 0.02,
                                fontWeight: FontWeight.bold,
                                color: theme.blackColor,
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                            itemCount: groupedOtherExhibitors[letter]!.length,
                            itemBuilder: (context, index) {
                              return _buildExhibitorListItem(groupedOtherExhibitors[letter]![index], width, height, theme);
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
      ),
    );
  }

  // Card widget now accepts ExhibitorsClass
  Widget _buildRecommendedExhibitorCard(ExhibitorsClass exhibitor, double width, double height, AppThemeData theme) {
    // Determine border color based on sponsorship level
    final Color borderColor = _getSponsorBorderColor(exhibitor);
    // Determine the category name to display (e.g., "DIAMOND", "GOLD")
    final String? categoryName = exhibitor.sponsorType?.trim().toUpperCase();

    return GestureDetector(
      onTap: () {
        // Navigating to DetailExhibitorsScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailExhibitorsScreen(exhibitorId: exhibitor.id),
          ),
        );
      },
      child: Stack( // 💡 NEW: Use Stack to layer the text banner over the card
        clipBehavior: Clip.none, // Allows the banner to extend outside the main Container
        children: [
          Container(
            width: width * 0.45,
            margin: EdgeInsets.only(right: width * 0.03, top: 10.0), // 💡 ADDED TOP MARGIN for banner space
            decoration: BoxDecoration(
              color: theme.whiteColor,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: borderColor, width: 2), // Dynamic Border
            ),
            child: Padding(
              padding: EdgeInsets.all(width * 0.02),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      // Logo/Image
                      SizedBox(
                        width: width * 0.25,
                        height: width * 0.15,
                        child: exhibitor.image.isNotEmpty && (exhibitor.image.startsWith('http') || exhibitor.image.startsWith('https'))
                            ? CachedNetworkImage(
                          imageUrl: exhibitor.image,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => Center(child: CircularProgressIndicator(strokeWidth: 2, color: theme.secondaryColor)),
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/ICON-EMEC.png',
                            fit: BoxFit.contain,
                          ),
                        )
                            : Image.asset(
                          'assets/ICON-EMEC.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.01),
                  Text(
                    exhibitor.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: height * 0.018,
                      fontWeight: FontWeight.bold,
                      color: theme.blackColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    exhibitor.adress.isNotEmpty ? exhibitor.adress : exhibitor.shortDiscriptions,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: height * 0.014,
                      color: theme.blackColor.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // 🚀 NEW: Category Text Banner at the top
          Positioned(
            top: 0.0, // Position on the edge of the Container (which has a 10.0 top margin)
            left: 0,
            right: width * 0.03, // Match the outer container's right margin
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: borderColor, // Background color matches the border
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: [
                    BoxShadow(
                      color: borderColor.withOpacity(0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  // Display text in the requested format: "---DIAMOND---"
                  '${categoryName ?? 'SPONSOR'}',
                  style: TextStyle(
                    color: theme.whiteColor, // White text for contrast
                    fontWeight: FontWeight.bold,
                    fontSize: 10.0,
                    letterSpacing: 1.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // List Item widget remains focused on ExhibitorsClass
  Widget _buildExhibitorListItem(ExhibitorsClass exhibitor, double width, double height, AppThemeData theme) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailExhibitorsScreen(exhibitorId: exhibitor.id),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: height * 0.015),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.blackColor.withOpacity(0.2),
              width: 1.0,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ClipOval(
              // 💡 FIX APPLIED HERE: Use CachedNetworkImage for the logo
              child: SizedBox(
                width: width * 0.12,
                height: width * 0.12,
                child: exhibitor.image.isNotEmpty && (exhibitor.image.startsWith('http') || exhibitor.image.startsWith('https'))
                    ? CachedNetworkImage(
                  imageUrl: exhibitor.image,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(child: CircularProgressIndicator(strokeWidth: 2, color: theme.secondaryColor)), // Placeholder while loading
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/ICON-EMEC.png', // Fallback on error
                    fit: BoxFit.cover,
                  ),
                )
                    : Image.asset(
                  'assets/ICON-EMEC.png', // Fallback for empty or non-URL images
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: width * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exhibitor.title,
                    style: TextStyle(
                      fontSize: height * 0.02,
                      fontWeight: FontWeight.bold,
                      color: theme.blackColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    exhibitor.adress.isNotEmpty ? exhibitor.adress : exhibitor.shortDiscriptions,
                    style: TextStyle(
                      fontSize: height * 0.016,
                      color: theme.blackColor.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    "Stand :${exhibitor.stand}",
                    style: TextStyle(
                      color: Colors.black26,
                      height: 1.5,
                      fontSize: height * 0.014,
                    ),
                  ),
                ],
              ),
            ),
            /*IconButton(
              icon: Icon(
                exhibitor.star ? Icons.star : Icons.star_border,
                color: exhibitor.star ? theme.secondaryColor : Colors.grey,
                size: width * 0.06,
              ),
              onPressed: () {
                setState(() {
                  exhibitor.star = !exhibitor.star;
                  _filterExhibitors();
                });
              },
            ),*/
          ],
        ),
      ),
    );
  }
}