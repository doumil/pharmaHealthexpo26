// model/favorite_item.dart
import 'package:flutter/material.dart'; // Import Material for Color

class FavoriteItem {
  final String name;
  final String location;
  final String hallLocation; // e.g., "Hall 9.9B-30"
  final String logoPath; // Path to the logo image
  final List<String> categories;
  bool isFavorite; // To toggle the star icon

  FavoriteItem({
    required this.name,
    required this.location,
    required this.hallLocation,
    required this.logoPath,
    required this.categories,
    this.isFavorite = true, // Default to true for favorite items
  });
}