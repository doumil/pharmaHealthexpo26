import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart'; // 💡 Import Provider
import 'package:emecexpo/providers/theme_provider.dart'; // 💡 Import ThemeProvider
import '../model/favorite_item_model.dart';
import 'main.dart';
import 'model/app_theme_data.dart';
import 'package:shared_preferences/shared_preferences.dart';


class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  late SharedPreferences prefs;
  final TextEditingController _searchController = TextEditingController();
  List<FavoriteItem> _allFavoriteItems = [];
  List<FavoriteItem> _filteredFavoriteItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteItems();
    _searchController.addListener(_filterFavoriteItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadFavoriteItems() async {
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _allFavoriteItems = [
        FavoriteItem(
          name: 'TAMWILCOM',
          location: 'Maroc',
          hallLocation: 'Hall 9.9B-30',
          logoPath: 'assets/tamwilcom_logo.png',
          categories: ['Banking, Finance & Insurance', 'Environment & Sustainability', 'Gaming'],
          isFavorite: true,
        ),
        FavoriteItem(
          name: 'Tech Solutions Inc.',
          location: 'USA',
          hallLocation: 'Booth 12A-45',
          logoPath: 'assets/company_logo2.png',
          categories: ['Software Development', 'Cloud Services'],
          isFavorite: true,
        ),
        FavoriteItem(
          name: 'Green Energy Co.',
          location: 'France',
          hallLocation: 'Zone C-10',
          logoPath: 'assets/company_logo3.png',
          categories: ['Renewable Energy', 'Sustainability'],
          isFavorite: true,
        ),
      ];
      _filteredFavoriteItems = List.from(_allFavoriteItems);
      _isLoading = false;
    });
  }

  void _filterFavoriteItems() {
    String query = _searchController.text.toLowerCase();
    List<FavoriteItem> results = _allFavoriteItems.where((item) {
      final name = item.name.toLowerCase();
      final location = item.location.toLowerCase();
      final hallLocation = item.hallLocation.toLowerCase();
      final categories = item.categories.join(' ').toLowerCase();
      return name.contains(query) ||
          location.contains(query) ||
          hallLocation.contains(query) ||
          categories.contains(query);
    }).toList();

    setState(() {
      _filteredFavoriteItems = results;
      if (results.isEmpty && query.isNotEmpty) {
        Fluttertoast.showToast(msg: "No matching favorites found.");
      }
    });
  }

  void _toggleFavorite(FavoriteItem item) {
    setState(() {
      item.isFavorite = !item.isFavorite;
      if (!item.isFavorite) {
        _allFavoriteItems.remove(item);
        _filterFavoriteItems();
        Fluttertoast.showToast(msg: "${item.name} removed from favorites.");
      } else {
        Fluttertoast.showToast(msg: "${item.name} added to favorites.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 💡 Access the theme provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourites'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white), // Assuming a light icon on a colored AppBar
          onPressed: () async{
            prefs = await SharedPreferences.getInstance();
            prefs.setString("Data", "99");
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => WelcomPage()));
          },
        ),
        // ✅ Apply primaryColor from the theme
        backgroundColor: theme.primaryColor,
        // ✅ Apply whiteColor for the text and icons
        foregroundColor: theme.whiteColor,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              Fluttertoast.showToast(msg: "Filter action!");
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              Fluttertoast.showToast(msg: "Sort action!");
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(screenHeight * 0.08),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.01),
            child: Container(
              decoration: BoxDecoration(
                // ✅ Use whiteColor with opacity for the search bar background
                color: theme.whiteColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: TextField(
                controller: _searchController,
                // ✅ Use secondaryColor for the cursor
                cursorColor: theme.secondaryColor,
                // ✅ Use whiteColor for the input text
                style: TextStyle(fontSize: screenHeight * 0.02, color: theme.whiteColor),
                decoration: InputDecoration(
                  hintText: 'Recherche',
                  // ✅ Use whiteColor with opacity for hint text
                  hintStyle: TextStyle(color: theme.whiteColor.withOpacity(0.7)),
                  // ✅ Use whiteColor for the search icon
                  prefixIcon: Icon(Icons.search, color: theme.whiteColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
        child: SpinKitThreeBounce(
          // ✅ Use secondaryColor for the loading indicator
          color: theme.secondaryColor,
          size: 30.0,
        ),
      )
          : (_filteredFavoriteItems.isEmpty && _searchController.text.isEmpty)
          ? const Center(
        child: Text(
          "No favorite items added yet.",
          style: TextStyle(color: Colors.grey, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      )
          : (_filteredFavoriteItems.isEmpty && _searchController.text.isNotEmpty)
          ? const Center(
        child: Text(
          "No matching favorites found for your search.",
          style: TextStyle(color: Colors.grey, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: _filteredFavoriteItems.length,
        itemBuilder: (context, index) {
          final item = _filteredFavoriteItems[index];
          // 💡 Pass the theme to the card builder
          return _buildFavoriteItemCard(item, screenWidth, screenHeight, theme);
        },
      ),
    );
  }

  // 💡 Updated method signature to accept an AppThemeData object
  Widget _buildFavoriteItemCard(FavoriteItem item, double screenWidth, double screenHeight, AppThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      // ✅ Use whiteColor for the card background
      color: theme.whiteColor,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo/Image Placeholder
            Container(
              width: screenWidth * 0.15,
              height: screenWidth * 0.15,
              decoration: BoxDecoration(
                // ✅ Use blackColor with opacity for the background
                color: theme.blackColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8.0),
                // ✅ Use blackColor with opacity for the border
                border: Border.all(color: theme.blackColor.withOpacity(0.1)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  item.logoPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.business,
                        size: screenWidth * 0.08,
                        // ✅ Use a darker shade of grey or black with opacity
                        color: Colors.grey[500],
                      ),
                    );
                  },
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: TextStyle(
                            fontSize: screenHeight * 0.022,
                            fontWeight: FontWeight.bold,
                            // ✅ Use blackColor for the text
                            color: theme.blackColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _toggleFavorite(item),
                        child: Icon(
                          item.isFavorite ? Icons.star : Icons.star_border,
                          // ✅ Use secondaryColor for the filled star, and a grey for the border
                          color: item.isFavorite ? theme.secondaryColor : Colors.grey,
                          size: screenWidth * 0.06,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    item.location,
                    style: TextStyle(
                      fontSize: screenHeight * 0.016,
                      // ✅ Use blackColor with opacity
                      color: theme.blackColor.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: screenHeight * 0.018, color: Colors.grey),
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        item.hallLocation,
                        style: TextStyle(
                          fontSize: screenHeight * 0.016,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: item.categories.map((category) {
                      return Chip(
                        label: Text(
                          category,
                          style: TextStyle(
                            fontSize: screenHeight * 0.014,
                            // ✅ Use blackColor with opacity
                            color: theme.blackColor.withOpacity(0.87),
                          ),
                        ),
                        // ✅ Use blackColor with opacity for the chip background
                        backgroundColor: theme.blackColor.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}