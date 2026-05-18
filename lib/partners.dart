// lib/partners_screen.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:cached_network_image/cached_network_image.dart'; // Using Image.network instead for unified fallback

import 'package:emecexpo/providers/theme_provider.dart';
import 'package:emecexpo/model/exhibitors_model.dart';
import 'package:emecexpo/api_services/exhibitor_api_service.dart';
import 'package:emecexpo/model/app_theme_data.dart';

import 'details/DetailExhibitors.dart';
import 'main.dart'; // Assuming this imports WelcomPage

class PartnersScreen extends StatefulWidget {
  const PartnersScreen({Key? key}) : super(key: key);

  @override
  _PartnersScreenState createState() => _PartnersScreenState();
}

class _PartnersScreenState extends State<PartnersScreen> {
  late SharedPreferences prefs;
  List<ExhibitorsClass> _partners = [];
  final ExhibitorApiService _exhibitorApiService = ExhibitorApiService();

  bool _isLoading = true;
  bool _hasError = false;

  // The fixed color for the item borders
  final Color _partnerColor = Colors.red.shade700;

  @override
  void initState() {
    super.initState();
    _loadPartnersData();
  }

  Future<void> _loadPartnersData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final List<ExhibitorsClass> allExhibitors = await _exhibitorApiService.getExhibitors();

      // Filter for exhibitors with expositionType 'partenaire'
      final List<ExhibitorsClass> fetchedPartners = allExhibitors
          .where((e) => e.expositionType?.toLowerCase() == 'partenaire')
          .toList();

      setState(() {
        _partners = fetchedPartners;
        _partners.sort((a, b) => a.title.compareTo(b.title));
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      print("Error loading partners: $e");
      setState(() {
        _isLoading = false;
        _hasError = true;
        _partners = [];
      });
    }
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Êtes-vous sûr'),
        content: const Text('Voulez-vous quitter cette application'),
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

  // 🚀 NEW HELPER: Image loading logic for partners (identical to sponsors, but separated for clarity)
  Widget _buildPartnerImage(String? imageUrl, AppThemeData theme) {
    // 🎯 Use the specific API fallback image URL
    final String defaultApiImage = 'https://buzzevents.co/uploads/ICON-EMEC.png';

    // Check if the partner image is valid; if not, use the API default.
    final String finalUrl = imageUrl?.isNotEmpty == true &&
        (imageUrl!.startsWith('http') || imageUrl.startsWith('https'))
        ? imageUrl
        : defaultApiImage;

    // Use a fixed size for consistent appearance in the grid
    const double iconSize = 50.0;

    return Image.network(
      finalUrl,
      fit: BoxFit.contain,
      // Error: Show a broken image icon if loading the final URL fails (even the default)
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.broken_image,
          color: Colors.grey,
          size: iconSize,
        );
      },
      // Loading: Show a progress indicator while the image is loading
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.secondaryColor,
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return
      Scaffold(
        backgroundColor: theme.whiteColor,
        appBar: AppBar(
          backgroundColor: theme.primaryColor,
          elevation: 0,
          title: Text(
            'Partners',
            style: TextStyle(color: theme.whiteColor, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: theme.whiteColor),
            onPressed: () async{
              prefs = await SharedPreferences.getInstance();
              prefs.setString("Data", "99");
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => WelcomPage()));
            },
          ),
          centerTitle: true,
        ),
        body: FadeInDown(
          duration: const Duration(milliseconds: 500),
          child: _buildBodyContent(theme),
        ),
      );
  }

  Widget _buildBodyContent(AppThemeData theme) {
    if (_isLoading) {
      return Center(
        child: SpinKitThreeBounce(
          color: theme.secondaryColor,
          size: 30.0,
        ),
      );
    }

    // Handle Error/Empty State
    if (_hasError || _partners.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.handshake_outlined, color: Colors.grey, size: 50),
            const SizedBox(height: 10),
            const Text(
              "No partners available or failed to load.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            /*ElevatedButton(
              onPressed: _loadPartnersData,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.secondaryColor,
              ),
              child: Text(
                'Try Again',
                style: TextStyle(color: theme.whiteColor),
              ),
            ),*/
          ],
        ),
      );
    }

    // Display Partners with updated design
    return GridView.builder(
      padding: const EdgeInsets.all(15.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15.0,
        mainAxisSpacing: 15.0,
        childAspectRatio: 1.2,
      ),
      itemCount: _partners.length,
      itemBuilder: (context, index) {
        return _buildPartnerGridItem(_partners[index], theme);
      },
    );
  }

  // Updated widget: uses the new _buildPartnerImage helper
  Widget _buildPartnerGridItem(ExhibitorsClass partner, AppThemeData theme) {
    return GestureDetector( // 🎯 WRAP with GestureDetector
      onTap: () {
        // CORRECT NAVIGATION: Passing the required 'exhibitorId' using the assumed correct field 'id'
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailExhibitorsScreen(exhibitorId: partner.id) // ⬅️ Corrected to use .id
            )
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.whiteColor,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: _partnerColor.withOpacity(0.5),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            // 🚀 INTEGRATED THE NEW IMAGE LOGIC
            child: _buildPartnerImage(partner.image, theme),
          ),
        ),
      ),
    );
  }
}