// lib/details/DetailExhibitors.dart

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emecexpo/model/exhibitors_model.dart';
import 'package:url_launcher/url_launcher.dart';

// Import the API service
import 'package:emecexpo/api_services/exhibitor_api_service.dart';

class DetailExhibitorsScreen extends StatefulWidget {
  final int exhibitorId; // Receives the exhibitor ID

  const DetailExhibitorsScreen({Key? key, required this.exhibitorId}) : super(key: key);

  @override
  _DetailExhibitorsScreenState createState() => _DetailExhibitorsScreenState();
}

class _DetailExhibitorsScreenState extends State<DetailExhibitorsScreen> {
  ExhibitorsClass? _currentExhibitor;
  bool isLoading = true;
  bool _showMoreDescription = false;

  // Fixed colors as requested (no dynamic sponsor colors)
  static const Color _primaryColor = Color(0xff261350); // Dark Purple
  static const Color _secondaryColor = Color(0xff00c1c1); // Aqua

  // Instantiate the API service
  final ExhibitorApiService _apiService = ExhibitorApiService();

  @override
  void initState() {
    super.initState();
    _loadExhibitorDetails();
  }

  // This method will load the specific exhibitor's data from API
  _loadExhibitorDetails() async {
    try {
      final List<ExhibitorsClass> allExhibitors = await _apiService.getExhibitors();
      final int idToFind = widget.exhibitorId;

      setState(() {
        _currentExhibitor = allExhibitors.firstWhere(
              (exhibitor) => exhibitor.id == idToFind,
          orElse: () => ExhibitorsClass(
            // Default error exhibitor if not found
              -1, 'Error', '', 'Exhibitor not found', '',
              'Details for this exhibitor are not available.', '',
              'assets/placeholder_error.png', false, false),
        );
        isLoading = false;
      });
    } catch (e) {
      print('Error loading exhibitor details from API: $e');
      setState(() {
        _currentExhibitor = ExhibitorsClass(
          // Default error exhibitor on API error
            -1, 'Error', '', 'Failed to load', '',
            'Could not load exhibitor details. Please check your internet connection.', '',
            'assets/placeholder_error.png', false, false);
        isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String urlString, {required LaunchMode mode}) async {
    String finalUrl = urlString;
    if (mode == LaunchMode.externalApplication && !finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
      finalUrl = 'https://$finalUrl';
    }

    final Uri url = Uri.parse(finalUrl);
    if (!await launchUrl(url, mode: mode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $urlString')),
      );
    }
  }

  // Helper to check if a section should be displayed (handles null and empty strings)
  bool _shouldShowSection(String? data) {
    return data != null && data.trim().isNotEmpty;
  }

  // Helper to check if a list section should be displayed
  bool _shouldShowListSection(List? data) {
    return data != null && data.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    if (isLoading || _currentExhibitor == null || _currentExhibitor!.id == -1) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isLoading ? "Loading Details" : "Exhibitor Not Found"),
          backgroundColor: _primaryColor,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: Center(
          child: isLoading
              ? const CircularProgressIndicator(color: _secondaryColor)
              : Text(_currentExhibitor?.shortDiscriptions ?? "Failed to load exhibitor details.", style: const TextStyle(fontSize: 18, color: Colors.red), textAlign: TextAlign.center),
        ),
      );
    }

    // Default null fields to "" (Hiding all null values using ?? '')
    final exhibitor = _currentExhibitor!;

    // FIELDS FROM THE MODEL: If null, they become "", which hides the corresponding section/row via _shouldShowSection or value.isEmpty in _buildInfoRow.
    final description = exhibitor.discriptions ?? '';
    final shortDescription = exhibitor.shortDiscriptions ?? '';
    final website = exhibitor.siteweb ?? '';
    final stand = exhibitor.stand ?? '';
    final adress = exhibitor.adress ?? '';

    // ❌ Placeholder variables for fields removed to solve the model definition error.
    // Setting them to const empty strings/lists ensures the sections are hidden and compilation succeeds.
    const String phone = '';
    const String tags = '';
    const String products = '';
    const String videoUrl = '';
    const String teamMembers = '';
    const String categories = '';

    const List<String> listTags = [];
    const List<String> listProducts = [];
    const List<String> listTeamMembers = [];
    const List<String> listCategories = [];


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _primaryColor, // Fixed color
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          exhibitor.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: const [],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section with Image and Title
            Container(
              width: width,
              padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.02),
              color: _primaryColor, // Fixed color
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child:
                      // DYNAMIC IMAGE/LOGO LOADED FROM API
                      exhibitor.image.startsWith('http') || exhibitor.image.startsWith('https')
                          ? CachedNetworkImage(
                        imageUrl: exhibitor.image,
                        width: width * 0.35,
                        height: width * 0.35,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Image.asset(
                          'assets/ICON-EMEC.png',
                          width: width * 0.35,
                          height: width * 0.35,
                          fit: BoxFit.contain,
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/placeholder_error.png',
                          width: width * 0.35,
                          height: width * 0.35,
                          fit: BoxFit.contain,
                        ),
                      )
                          : Image.asset(
                        'assets/ICON-EMEC.png', // Fallback for local assets
                        width: width * 0.35,
                        height: width * 0.35,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  FadeInDown(
                    duration: const Duration(milliseconds: 700),
                    child: Text(
                      exhibitor.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: height * 0.032,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  // Adress in Header: Hides if `adress` is null or empty.
                  if (_shouldShowSection(adress))
                    FadeInDown(
                      duration: const Duration(milliseconds: 800),
                      child: Text(
                        adress,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: height * 0.018,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Main Content Area
            Padding(
              padding: EdgeInsets.all(width * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🚩 About Exhibitor Section: Hides completely if `description` is null or empty.
                  if (_shouldShowSection(description))
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About Exhibitor',
                            style: TextStyle(
                              color: _primaryColor,
                              fontSize: height * 0.025,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: height * 0.01),
                          Text(
                            _showMoreDescription
                                ? description
                                : (description.length > 150
                                ? '${description.substring(0, 150)}...'
                                : description),
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: height * 0.018,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                          if (description.length > 150)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showMoreDescription = !_showMoreDescription;
                                });
                              },
                              child: const Text(
                                'Show more',
                                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                              ),
                            ),
                          SizedBox(height: height * 0.03),
                        ],
                      ),
                    ),

                  // 🚩 Additional Information: Labels and values hide if their variable is null/empty via _buildInfoRow
                  if (_shouldShowSection(adress) || _shouldShowSection(shortDescription) || _shouldShowSection(website) || _shouldShowSection(stand))
                    FadeInUp(
                      duration: const Duration(milliseconds: 700),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Additional Information',
                            style: TextStyle(
                              color: _primaryColor,
                              fontSize: height * 0.025,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: height * 0.01),
                          // Individual rows hide if their value is null or empty.
                          _buildInfoRow('Company Headquarters Country', adress),
                          _buildInfoRow('Short Company Description', shortDescription),
                          _buildInfoRow('Website', website, isLink: true),
                          _buildInfoRow('Stand', stand),
                          SizedBox(height: height * 0.03),
                        ],
                      ),
                    ),

                  // 🚩 Tags Section: Hides completely if `listTags` is empty.
                  if (_shouldShowListSection(listTags))
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tags', style: TextStyle(color: _primaryColor, fontSize: height * 0.025, fontWeight: FontWeight.bold)),
                          SizedBox(height: height * 0.01),
                          Wrap(spacing: 8.0, runSpacing: 8.0, children: listTags.map((tag) => _buildTagChip(tag)).toList()),
                          SizedBox(height: height * 0.03),
                        ],
                      ),
                    ),

                  // 🚩 Produits (Products) Section: Hides completely if `listProducts` is empty.
                  if (_shouldShowListSection(listProducts))
                    FadeInUp(
                      duration: const Duration(milliseconds: 900),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Produits', style: TextStyle(color: _primaryColor, fontSize: height * 0.025, fontWeight: FontWeight.bold)),
                          SizedBox(height: height * 0.01),
                          ...listProducts.map((productName) => _buildProductTile(productName)).toList(),
                          SizedBox(height: height * 0.03),
                        ],
                      ),
                    ),

                  // 🚩 Video Section: Hides completely if `videoUrl` is null or empty.
                  if (_shouldShowSection(videoUrl))
                    FadeInUp(
                      duration: const Duration(milliseconds: 1000),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Video', style: TextStyle(color: _primaryColor, fontSize: height * 0.025, fontWeight: FontWeight.bold)),
                          SizedBox(height: height * 0.01),
                          Container(
                            height: height * 0.25,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                                image: const DecorationImage(image: AssetImage('assets/video_placeholder.png'), fit: BoxFit.cover)
                            ),
                            child: Center(
                              child: IconButton(
                                icon: Icon(Icons.play_circle_fill, color: Colors.red, size: width * 0.15),
                                onPressed: () => _launchUrl(videoUrl, mode: LaunchMode.externalApplication),
                              ),
                            ),
                          ),
                          SizedBox(height: height * 0.01),
                          Text('Video Link: $videoUrl', style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
                          SizedBox(height: height * 0.03),
                        ],
                      ),
                    ),

                  // 🚩 Membres de l'équipe (Team Members) Section: Hides completely if `listTeamMembers` is empty.
                  if (_shouldShowListSection(listTeamMembers))
                    FadeInUp(
                      duration: const Duration(milliseconds: 1100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Membres de l\'équipe', style: TextStyle(color: _primaryColor, fontSize: height * 0.025, fontWeight: FontWeight.bold)),
                          SizedBox(height: height * 0.01),
                          SizedBox(height: height * 0.03),
                        ],
                      ),
                    ),

                  // 🚩 Catégories (Categories) Section: Hides completely if `listCategories` is empty.
                  if (_shouldShowListSection(listCategories))
                    FadeInUp(
                      duration: const Duration(milliseconds: 1200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Catégories', style: TextStyle(color: _primaryColor, fontSize: height * 0.025, fontWeight: FontWeight.bold)),
                          SizedBox(height: height * 0.01),
                          Wrap(spacing: 8.0, runSpacing: 8.0, children: listCategories.map((category) => _buildCategoryChip(category)).toList()),
                          SizedBox(height: height * 0.1),
                        ],
                      ),
                    ),
                  // Final space
                  if(listTags.isEmpty && listProducts.isEmpty && !_shouldShowSection(videoUrl) && listTeamMembers.isEmpty && listCategories.isEmpty)
                    SizedBox(height: height * 0.05),
                ],
              ),
            ),
          ],
        ),
      ),
      // 🚩 Bottom Navigation Bar (Call Button): Hides if `phone` is null or empty.
      bottomNavigationBar: _shouldShowSection(phone)
          ? Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.015),
        child: ElevatedButton.icon(
          onPressed: () {
            _launchUrl('tel:$phone', mode: LaunchMode.platformDefault);
          },
          icon: const Icon(Icons.phone, color: Colors.white),
          label: const Text('Call Exhibitor', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _secondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(vertical: height * 0.015),
          ),
        ),
      )
          : null, // Hide bottom navigation bar
    );
  }

  // --- Helper Widgets ---

  // Hides the row completely if the value is empty.
  Widget _buildInfoRow(String label, String value, {bool isLink = false}) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.black87,
                fontSize: MediaQuery.of(context).size.height * 0.018,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: isLink
                ? GestureDetector(
              onTap: () {
                if (value.isNotEmpty) {
                  _launchUrl(value, mode: LaunchMode.externalApplication);
                }
              },
              child: Text(
                value,
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: MediaQuery.of(context).size.height * 0.018,
                  decoration: TextDecoration.underline,
                ),
              ),
            )
                : Text(
              value,
              style: TextStyle(
                color: Colors.black54,
                fontSize: MediaQuery.of(context).size.height * 0.018,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
  // Remaining helper widgets are unchanged but included for completeness:
  Widget _buildTagChip(String tag) {
    if (tag.isEmpty) return const SizedBox.shrink();
    return Chip(
      label: Text(
        tag,
        style: TextStyle(
          color: Colors.white,
          fontSize: MediaQuery.of(context).size.height * 0.016,
        ),
      ),
      backgroundColor: _secondaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    );
  }

  Widget _buildProductTile(String productName) {
    if (productName.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: _secondaryColor, size: MediaQuery.of(context).size.height * 0.02),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          Expanded(
            child: Text(
              productName,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height * 0.018,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberTile(String initials, String name, String role) {
    if (name.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _primaryColor,
            child: Text(
              initials,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.height * 0.018,
              ),
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.04),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.height * 0.018,
                  color: Colors.black,
                ),
              ),
              Text(
                role,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.016,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    if (category.isEmpty) return const SizedBox.shrink();
    return Chip(
      label: Text(
        category,
        style: TextStyle(
          color: Colors.black87,
          fontSize: MediaQuery.of(context).size.height * 0.016,
        ),
      ),
      backgroundColor: Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    );
  }
}