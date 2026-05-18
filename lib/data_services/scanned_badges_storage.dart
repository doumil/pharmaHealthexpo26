// lib/data_services/scanned_badges_storage.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// ✅ FIX: Changed import to match the correct model file
import '../model/user_scanner.dart';

class ScannedBadgesStorage {
  static const String _keyIScanned = 'iScannedBadgesList';
  static const String _keyScannedMe = 'scannedMeBadgesList';

  /// Loads the list of badges scanned by the current user.
  Future<List<Userscan>> loadIScannedBadges() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyIScanned);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      // ✅ FIX: Use Userscan.fromMap (since storage uses map structure)
      return jsonList.map((json) => Userscan.fromMap(json)).toList();
    } catch (e) {
      // ignore: avoid_print
      print("Error loading I Scanned Badges from storage: $e");
      return [];
    }
  }

  /// Saves the updated list of badges scanned by the current user.
  Future<void> saveIScannedBadges(List<Userscan> badges) async {
    final prefs = await SharedPreferences.getInstance();
    // ✅ FIX: Use Userscan.toMap for serialization
    final jsonList = badges.map((badge) => badge.toMap()).toList();
    await prefs.setString(_keyIScanned, json.encode(jsonList));
  }
}