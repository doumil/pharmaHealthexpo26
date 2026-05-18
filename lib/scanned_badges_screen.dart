// lib/scanned_badges_screen.dart

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
// Note: Replace with your actual imports for theme provider and models
import 'package:emecexpo/providers/theme_provider.dart';
import 'model/app_theme_data.dart';

// --- CSV Export Imports ---
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
// -----------------------------

import 'messages_screen.dart'; // Assume this exists
import 'model/user_scanner.dart'; // Assume Userscan model exists
import 'api_services/scanned_user_api_service.dart'; // Assume ScannedUserApiService exists
import 'data_services/scanned_badges_storage.dart'; // Assume ScannedBadgesStorage exists
import 'qr_scanner_view.dart'; // Assume QrScannerView exists
import 'model/user_model.dart'; // Assume User model exists
import 'main.dart'; // Assumed WelcomPage is here


class ScannedBadgesScreen extends StatefulWidget {
  final User user;

  const ScannedBadgesScreen({super.key, required this.user});

  @override
  State<ScannedBadgesScreen> createState() => _ScannedBadgesScreenState();
}

class _ScannedBadgesScreenState extends State<ScannedBadgesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<Userscan> _iScannedOriginalBadges = [];
  List<Userscan> _scannedMeOriginalBadges = [];

  List<Userscan> _filteredIScannedBadges = [];
  List<Userscan> _filteredScannedMeBadges = [];

  final ScannedBadgesStorage _storage = ScannedBadgesStorage();
  final ScannedUserApiService _apiService = ScannedUserApiService();

  bool _isLoading = true;
  String? _qrCodeXml;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadScannedBadges();
    _loadQrCode();
    _searchController.addListener(_filterScannedBadges);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        FocusScope.of(context).unfocus();
        _filterScannedBadges();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadQrCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? xml = prefs.getString('qrCodeXml');
    setState(() {
      _qrCodeXml = xml;
    });
  }

  void _updateBadgeList(Userscan updatedUser) {
    final index = _iScannedOriginalBadges.indexWhere((user) => user.email == updatedUser.email);
    if (index != -1) {
      setState(() {
        _iScannedOriginalBadges[index] = updatedUser;
        _filterScannedBadges();
      });
      _storage.saveIScannedBadges(_iScannedOriginalBadges);
    }
  }

  void _loadScannedBadges() async {
    setState(() => _isLoading = true);
    final List<Userscan> loadedBadges = await _storage.loadIScannedBadges();
    setState(() {
      _iScannedOriginalBadges = loadedBadges;
      _scannedMeOriginalBadges = [];
      _filterScannedBadges();
      _isLoading = false;
    });
  }

  void _filterScannedBadges() {
    String query = _searchController.text.toLowerCase();
    _filteredIScannedBadges = _iScannedOriginalBadges.where((user) {
      final String searchableText =
      '${user.name} ${user.profession} ${user.company} ${user.evolution} ${user.action} ${user.notes} ${user.email}'
          .toLowerCase();
      return searchableText.contains(query);
    }).toList();

    _filteredScannedMeBadges = _scannedMeOriginalBadges.where((user) {
      final String searchableText =
      '${user.name} ${user.profession} ${user.company} ${user.email}'
          .toLowerCase();
      return searchableText.contains(query);
    }).toList();

    setState(() {});
  }

  Future<void> _openQrScanner() async {
    debugPrint('--- [QR Scan] Opening Scanner ---');
    final String? scannedData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QrScannerView(),
      ),
    );

    if (!mounted) return;

    if (scannedData == null || scannedData.isEmpty) {
      Fluttertoast.showToast(
          msg: 'Scan cancelled or no data found.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    }

    String qrHash = scannedData;
    if (scannedData.startsWith('http') || scannedData.contains('buzzevents.co')) {
      final List<String> parts = scannedData.split('/');
      if (parts.isNotEmpty) {
        qrHash = parts.last;
      } else {
        Fluttertoast.showToast(
            msg: 'Invalid QR code format. Expected a hash or full URL.',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER);
        return;
      }
    }

    if (qrHash.length < 5 || qrHash.isEmpty) {
      Fluttertoast.showToast(
          msg: 'Invalid or too short QR Hash extracted.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER);
      return;
    }

    Fluttertoast.showToast(
        msg: 'Fetching data for scanned user...',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER);

    final Map<String, dynamic> apiResult = await _apiService.getUserByQrHash(qrHash);

    if (!mounted) return;

    // DEBUGGING: Print the API result map to confirm its structure
    debugPrint('[API Result] Received Map: ${apiResult.toString()}');

    if (apiResult['success'] == true) {

      // 🚀 FIX: Extract user data using the custom key 'userMap'
      final Map<String, dynamic>? userMap = apiResult['userMap'] as Map<String, dynamic>?;

      if (userMap == null || userMap.isEmpty) {
        Fluttertoast.showToast(
            msg: apiResult['message'] ?? 'Failed to retrieve user data, data key missing or is null.',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER);
        return;
      }

      // Use fromJson which handles the API key mapping ('nom', 'prenom', etc.)
      final Userscan newUserScan = Userscan.fromJson(userMap);

      final isDuplicate =
      _iScannedOriginalBadges.any((b) => b.email == newUserScan.email);

      if (isDuplicate) {
        Fluttertoast.showToast(
            msg: '${newUserScan.name} has already been scanned.',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER);
        return;
      }

      // --- Success: Add and Save ---
      setState(() {
        _iScannedOriginalBadges.insert(0, newUserScan);
        _filterScannedBadges();
      });
      await _storage.saveIScannedBadges(_iScannedOriginalBadges);

      Fluttertoast.showToast(
          msg: 'QR code scanned successfully for ${newUserScan.name}!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
    } else {
      final String errorMessage =
          apiResult['message'] ?? 'Failed to scan and retrieve user data.';
      Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER);
    }
  }

  // --- METHOD FOR CSV EXPORT ---
  Future<void> _exportBadgesToCSV() async {
    if (_iScannedOriginalBadges.isEmpty) {
      Fluttertoast.showToast(
          msg: 'No contacts to export.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    }

    Fluttertoast.showToast(
        msg: 'Preparing data for export...',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER);

    // 1. Prepare Data
    List<List<dynamic>> rows = [];

    rows.add([
      'Nom', 'Prenom', 'Societe', 'Profession', 'Email', 'Telephone',
      'Evolution', 'Action', 'Notes', 'Scanned Time'
    ]);

    for (var user in _iScannedOriginalBadges) {
      rows.add([
        user.lastname, user.firstname, user.company, user.profession,
        user.email, user.phone, user.evolution, user.action,
        user.notes, user.formattedScanTime,
      ]);
    }

    // 2. Convert to CSV string
    String csv = const ListToCsvConverter().convert(rows);

    // 3. Save the file (Handle permissions and path)
    if (kIsWeb) {
      Fluttertoast.showToast(
          msg: 'CSV generated. Web download requires specific browser API handling.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER);
      return;
    }

    try {
      if (Platform.isAndroid) {
        // 🚀 1. Check current status without immediately requesting
        PermissionStatus status = await Permission.storage.status;
        debugPrint("Initial Storage Status: $status");

        // 🚀 2. Handle Permanent Denial first (CRITICAL FIX)
        if (status.isPermanentlyDenied) {
          Fluttertoast.showToast(
              msg: 'Storage permission permanently denied. Please enable in Settings.',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER);
          await openAppSettings(); // Redirect user to fix permission manually
          return;
        }

        // 🚀 3. Request if not granted (or denied for the first time)
        if (!status.isGranted) {
          status = await Permission.storage.request();
          debugPrint("Status after Request: $status");
        }

        // 🚀 4. Final check: Exit if still not granted
        if (!status.isGranted) {
          Fluttertoast.showToast(
              msg: 'Storage permission required to save contacts.',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER);
          return;
        }
      }

      // --- EXECUTE SAVE LOGIC ONLY IF PERMISSION IS GRANTED ---

      // We still need this call for the path_provider library to be initialized
      final List<Directory>? externalStorageDirs = await getExternalStorageDirectories(type: StorageDirectory.downloads);

      if (externalStorageDirs == null || externalStorageDirs.isEmpty) {
        Fluttertoast.showToast(
            msg: 'Cannot access external Downloads directory.',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER);
        return;
      }

      String targetPath;
      const String customFolderName = 'EMEC Exported Contacts';

      // Attempt to get the root of the public Downloads folder for Android
      if (Platform.isAndroid) {
        // This is a common path to the public downloads folder on most Android devices.
        targetPath = '/storage/emulated/0/Download/$customFolderName';
      } else {
        // Fallback for non-Android platforms (iOS/Desktop)
        final String baseDownloadsPath = externalStorageDirs.first.path;
        targetPath = '$baseDownloadsPath/$customFolderName';
      }

      final Directory targetDirectory = Directory(targetPath);

      // Ensure the directory exists. Create it if it doesn't.
      if (!await targetDirectory.exists()) {
        await targetDirectory.create(recursive: true);
      }

      // File naming
      final fileName =
          'scanned_contacts_export_${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}_${DateTime.now().hour}${DateTime.now().minute}.csv';

      final file = File('${targetDirectory.path}/$fileName');

      await file.writeAsString(csv);

      Fluttertoast.showToast(
          msg: 'Contacts exported to:\n$customFolderName/$fileName',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER);

      if (kDebugMode) {
        print('CSV saved to: ${file.path}');
      }
    } catch (e) {
      // This toast handles the exception
      Fluttertoast.showToast(msg: 'Error saving CSV: ${e.toString()}', toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.CENTER);
      if (kDebugMode) {
        print('CSV Export Error: $e');
      }
    }
  }
  // -----------------------------------------------------------------


  Widget _buildMyBadgeContent(double screenWidth, double screenHeight) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. Display User Name
          Text(
            "${widget.user.prenom ?? ''} ${widget.user.nom ?? ''}",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xff261350), // Use primary color
            ),
          ),
          const SizedBox(height: 10),
          // 2. Display Company
          Text(
            widget.user.societe ?? 'N/A',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 40),

          // 3. Display QR Code (SVG from XML)
          if (_qrCodeXml != null && _qrCodeXml!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 15,
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: SvgPicture.string(
                _qrCodeXml!,
                width: screenWidth * 0.5,
                height: screenWidth * 0.5,
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "QR Code loading or not available. Please ensure verification was successful.",
                style: TextStyle(color: Color(0xff261350)),
              ),
            ),

          const SizedBox(height: 40),
          const Text(
            "Scan this badge to network!",
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Applying saved preference: Scaffold background color is white
    const Color scaffoldBackgroundColor = Colors.white;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    bool showIScannedPlaceholder = (_tabController.index == 0) &&
        (_filteredIScannedBadges.isEmpty && _searchController.text.isEmpty);

    bool showFloatingScanButton = (_tabController.index == 0);

    final themeProvider = Provider.of<ThemeProvider>(context);
    final AppThemeData theme = themeProvider.currentTheme;

    final primaryColor = theme.primaryColor;
    final secondaryColor = theme.secondaryColor;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Scanned Badges'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: theme.whiteColor),
            onPressed: () async {
              final SharedPreferences prefs =
              await SharedPreferences.getInstance();
              await prefs.setString("Data", "99");

              // NOTE: Assumes WelcomPage is accessible via main.dart
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WelcomPage(user: widget.user)));
            },
          ),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          actions: [
            if (_tabController.index == 0 && _iScannedOriginalBadges.isNotEmpty)
              IconButton(
                icon: Icon(Icons.download, color: theme.whiteColor),
                onPressed: _exportBadgesToCSV,
              ),
          ],
          bottom: PreferredSize(
            preferredSize:
            Size.fromHeight(kToolbarHeight + screenHeight * 0.08 + 10),
            child: Column(
              children: [
                // Search Bar Section
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.01),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: TextField(
                      controller: _searchController,
                      cursorColor: secondaryColor,
                      style:
                      TextStyle(fontSize: screenHeight * 0.02, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Recherche',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                        prefixIcon: const Icon(Icons.search, color: Colors.white),
                        border: InputBorder.none,
                        contentPadding:
                        EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                      ),
                    ),
                  ),
                ),
                // TabBar Section
                Container(
                  color: primaryColor,
                  child: TabBar(
                    controller: _tabController,
                    unselectedLabelColor: secondaryColor,
                    labelColor: Colors.white,
                    indicatorColor: Colors.white,
                    tabs: const [
                      Tab(text: 'I scanned'),
                      Tab(text: 'My Badge'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? Center(
                child: SpinKitThreeBounce(
                  color: secondaryColor,
                  size: 30.0,
                ),
              )
                  : TabBarView(
                controller: _tabController,
                children: [
                  // TAB 1: 'I scanned' content (List of scanned badges)
                  showIScannedPlaceholder
                      ? Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_scanner, size: screenWidth * 0.4, color: primaryColor.withOpacity(0.5)),
                          const SizedBox(height: 20),
                          const Text("No Badges Scanned Yet", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                          const Padding(padding: EdgeInsets.symmetric(horizontal: 40.0), child: Text("Tap the 'Scan' button in the corner to start collecting contacts.", style: TextStyle(color: Colors.grey, fontSize: 16), textAlign: TextAlign.center)),
                        ],
                      ),
                    ),
                  )
                      : _filteredIScannedBadges.isEmpty &&
                      _searchController.text.isNotEmpty
                      ? const Center(
                    child: Text("No matching scanned badges found for your search.", style: TextStyle(color: Colors.grey, fontSize: 16), textAlign: TextAlign.center),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.all(10.0),
                    itemCount: _filteredIScannedBadges.length,
                    itemBuilder: (context, index) {
                      final user = _filteredIScannedBadges[index];
                      return _buildScannedBadgeCard(user, screenWidth, screenHeight);
                    },
                  ),

                  // TAB 2: 'My Badge' content
                  _searchController.text.isNotEmpty
                      ? const Center(
                    child: Text("Search is only supported in the 'I scanned' tab.", style: TextStyle(color: Colors.grey, fontSize: 16), textAlign: TextAlign.center),
                  )
                      : _buildMyBadgeContent(screenWidth, screenHeight),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: showFloatingScanButton
            ? Padding(
          padding: const EdgeInsets.only(bottom: 20.0, right: 10.0),
          child: FloatingActionButton.extended(
            onPressed: _openQrScanner,
            label: const Text(
              'Scan',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            icon: const Icon(
              Icons.qr_code_scanner,
              color: Colors.white,
            ),
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
        )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildScannedBadgeCard(
      Userscan user, double screenWidth, double screenHeight) {
    // Applying saved preference: Colors.grey for TextStyle and Icon colors
    const Color iconColor = Colors.grey;
    const Color textColor = Colors.grey;

    return InkWell(
      onTap: () async {
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: screenWidth * 0.15,
                height: screenWidth * 0.15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: ClipOval(
                  child: user.profilePicturePath != null &&
                      user.profilePicturePath!.isNotEmpty
                      ? Image.network(
                    user.profilePicturePath!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          user.initials,
                          style: TextStyle(
                              fontSize: screenWidth * 0.06,
                              color: iconColor),
                        ),
                      );
                    },
                  )
                      : Center(
                    child: Text(
                      user.initials,
                      style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          color: iconColor),
                    ),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            user.name,
                            style: TextStyle(
                              fontSize: screenHeight * 0.022,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (user.companyLogoPath != null &&
                            user.companyLogoPath!.isNotEmpty)
                          Container(
                            width: screenWidth * 0.1,
                            height: screenWidth * 0.1,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: Image.network(
                                user.companyLogoPath!,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(Icons.business,
                                        size: screenWidth * 0.05,
                                        color: iconColor),
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      user.profession,
                      style: TextStyle(
                        fontSize: screenHeight * 0.016,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user.company,
                      style: TextStyle(
                        fontSize: screenHeight * 0.016,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    const SizedBox(height: 5),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        user.formattedScanTime,
                        style: TextStyle(
                          fontSize: screenHeight * 0.014,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}