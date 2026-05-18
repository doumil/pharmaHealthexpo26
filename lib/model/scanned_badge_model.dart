// lib/model/scanned_badge_model.dart (Assumed file content)

import 'package:intl/intl.dart';
import 'user_model.dart'; // Import User model

class ScannedBadge {
  final String name;
  final String title;
  final String company;
  final String? profilePicturePath;
  final String? companyLogoPath;
  final List<String> tags;
  final DateTime scanDateTime;
  final String initials;
  final String email; // Added email for API identification

  ScannedBadge({
    required this.name,
    required this.title,
    required this.company,
    this.profilePicturePath,
    this.companyLogoPath,
    required this.tags,
    required this.scanDateTime,
    required this.initials,
    required this.email,
  });

  // 🚀 NEW: Factory constructor to convert API User object to ScannedBadge
  factory ScannedBadge.fromUser(User user) {
    String fullName = "${user.prenom ?? ''} ${user.nom ?? ''}".trim();

    String initials = '';
    if (user.prenom?.isNotEmpty == true) initials += user.prenom![0];
    if (user.nom?.isNotEmpty == true) initials += user.nom![0];

    return ScannedBadge(
      name: fullName.isEmpty ? (user.email ?? 'Unknown User') : fullName,
      title: user.profession ?? 'Professional',
      company: user.societe ?? 'Unknown Company',
      profilePicturePath: user.pic, // Use user's profile picture URL
      companyLogoPath: null, // Company logo path is often separate
      tags: const ['Attendee'], // Default tag for a scanned user
      scanDateTime: DateTime.now(),
      initials: initials.toUpperCase(),
      email: user.email ?? '',
    );
  }

  // Factory for loading from local storage
  factory ScannedBadge.fromJson(Map<String, dynamic> json) {
    return ScannedBadge(
      name: json['name'],
      title: json['title'],
      company: json['company'],
      profilePicturePath: json['profilePicturePath'],
      companyLogoPath: json['companyLogoPath'],
      tags: List<String>.from(json['tags'] ?? []),
      scanDateTime: DateTime.parse(json['scanDateTime']),
      initials: json['initials'],
      email: json['email'] ?? '',
    );
  }

  // Method for saving to local storage
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'title': title,
      'company': company,
      'profilePicturePath': profilePicturePath,
      'companyLogoPath': companyLogoPath,
      'tags': tags,
      'scanDateTime': scanDateTime.toIso8601String(),
      'initials': initials,
      'email': email,
    };
  }

  String get formattedScanTime => DateFormat('dd MMM yyyy, HH:mm').format(scanDateTime);
}