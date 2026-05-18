// lib/model/badge_model.dart
class MyBadge {
  final String name;
  final String role;
  final String company;
  final String qrCodeImagePath; // Path to the QR code image asset
  final String visitorStatus; // e.g., "VISITOR"

  MyBadge({
    required this.name,
    required this.role,
    required this.company,
    required this.qrCodeImagePath,
    this.visitorStatus = 'VISITOR', // Default value as seen in the image
  });

  // Helper getter to combine role and company for display, as seen in the badge image
  String get roleAndCompany => '$role at $company';
}