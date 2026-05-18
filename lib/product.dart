// lib/product_screen.dart

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:emecexpo/providers/theme_provider.dart';
import 'model/app_theme_data.dart';
import 'model/product_model.dart';
import 'package:http/http.dart' as http;

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<ProductClass> _allProducts = [];
  List<ProductClass> _filteredProducts = [];

  bool isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  _loadData() async {
    await Future.delayed(const Duration(seconds: 1));

    _allProducts.add(ProductClass("@XS-BOX L/XL", "Building entry point for..", "Aginode", "assets/placeholder_product.png", isFavorite: false));
    _allProducts.add(ProductClass("* i3TOUCH Interactive Touchscreens", "i3 GROUP", "", "assets/placeholder_product.png", isFavorite: true));
    _allProducts.add(ProductClass("+150 HR Communication Design..", "HR tttoolbox", "", "assets/placeholder_product.png", isFavorite: false));
    _allProducts.add(ProductClass("+18 Modules End-to-End HR Platform - Us..", "HR tttoolbox", "", "assets/placeholder_product.png", isFavorite: true));
    _allProducts.add(ProductClass("Product Five Name", "Company E", "Description of product five", "assets/placeholder_product.png", isFavorite: false));
    _allProducts.add(ProductClass("Product Six Name", "Company F", "Description of product six", "assets/placeholder_product.png", isFavorite: false));
    _allProducts.add(ProductClass("Awesome Gadget X", "Innovate Corp", "A revolutionary new gadget.", "assets/placeholder_product.png", isFavorite: true));
    _allProducts.add(ProductClass("Smart Widget Pro", "Future Tech", "Next-gen smart home device.", "assets/placeholder_product.png", isFavorite: false));

    setState(() {
      _filteredProducts = List.from(_allProducts);
      isLoading = false;
    });
  }

  void _filterProducts() {
    String query = _searchController.text.toLowerCase();
    List<ProductClass> results = _allProducts.where((product) {
      final name = product.name.toLowerCase();
      final shortname = product.shortname.toLowerCase();
      final shortdescription = product.shortdiscription.toLowerCase();
      return name.contains(query) || shortname.contains(query) || shortdescription.contains(query);
    }).toList();

    setState(() {
      _filteredProducts = results;
      if (results.isEmpty && query.isNotEmpty) {
        Fluttertoast.showToast(msg: "Search not found...!", toastLength: Toast.LENGTH_SHORT);
      }
    });
  }

  void _toggleFavorite(ProductClass product) {
    setState(() {
      product.isFavorite = !product.isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access the theme
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.whiteColor,
        elevation: 0,
        title: Text(
          'Products',
          style: TextStyle(fontWeight: FontWeight.bold, color: theme.whiteColor),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: theme.whiteColor),
            onPressed: () {
              Fluttertoast.showToast(msg: "Filter action!");
            },
          ),
          IconButton(
            icon: Icon(Icons.sort, color: theme.whiteColor),
            onPressed: () {
              Fluttertoast.showToast(msg: "Sort action!");
            },
          ),
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
                cursorColor: theme.secondaryColor,
                style: TextStyle(fontSize: height * 0.02, color: theme.whiteColor),
                decoration: InputDecoration(
                  hintText: 'Recherche',
                  hintStyle: TextStyle(color: theme.whiteColor.withOpacity(0.7)),
                  prefixIcon: Icon(Icons.search, color: theme.whiteColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: height * 0.015),
                ),
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
        child: Column(
          children: [
            Expanded(
              child: _filteredProducts.isEmpty && _searchController.text.isNotEmpty
                  ? Center(
                child: Text(
                  "No products found for your search.",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              )
                  : GridView.builder(
                padding: EdgeInsets.all(width * 0.04),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: width * 0.04,
                  mainAxisSpacing: height * 0.02,
                  childAspectRatio: 0.7,
                ),
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  ProductClass product = _filteredProducts[index];
                  return _buildProductGridCard(product, width, height, theme);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGridCard(ProductClass product, double width, double height, AppThemeData theme) {
    return Card(
      color: theme.whiteColor,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell(
        onTap: () {
          Fluttertoast.showToast(msg: "Tapped on ${product.name}");
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10.0)),
                  child: Image.asset(
                    product.image,
                    width: double.infinity,
                    height: height * 0.13,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: height * 0.13,
                        color: Colors.grey.withOpacity(0.2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: height * 0.05, color: Colors.grey),
                            const SizedBox(height: 5),
                            Text(
                              "No Image",
                              style: TextStyle(color: Colors.grey, fontSize: height * 0.015),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: width * 0.02,
                  right: width * 0.02,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(product),
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: theme.whiteColor.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        product.isFavorite ? Icons.star : Icons.star_border,
                        color: product.isFavorite ? theme.secondaryColor : Colors.grey,
                        size: width * 0.06,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(width * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: height * 0.018,
                      fontWeight: FontWeight.bold,
                      color: theme.blackColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: height * 0.005),
                  Text(
                    product.shortname.isNotEmpty ? product.shortname : product.shortdiscription,
                    style: TextStyle(
                      fontSize: height * 0.014,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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