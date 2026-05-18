// lib/model/exhibitors_model.dart

class ExhibitorsClass {
  final int id;
  final String title;
  final String stand; // Mapped from pivot.stand
  final String adress;
  final String shortDiscriptions; // Mapped from activite
  final String discriptions; // Placeholder for full description (not in current API JSON)
  final String siteweb; // Mapped from site
  final String image; // Mapped from logo
  bool star;
  final bool isRecommended;

  // New fields for sponsor logic
  final String? expositionType; // Mapped from exposition_type
  final String? sponsorType; // Mapped from sponsor_type

  ExhibitorsClass(
      this.id,
      this.title,
      this.stand,
      this.adress,
      this.shortDiscriptions,
      this.discriptions,
      this.siteweb,
      this.image,
      this.star,
      this.isRecommended, {
        this.expositionType,
        this.sponsorType,
      });

  // Base URL for exhibitor logos
  static const String _logoBaseUrl = "https://buzzevents.co/uploads/";

  factory ExhibitorsClass.fromJson(Map<String, dynamic> json) {
    // Check for nested 'pivot' data for stand and use default if not present
    final pivotStand = json['pivot']?['stand'] as String? ?? 'N/A';

    // Construct the full image URL from the 'logo' field
    final logoFileName = json['logo'] as String?;
    final imageUrl = (logoFileName != null && logoFileName.isNotEmpty)
        ? '$_logoBaseUrl$logoFileName'
        : 'assets/ICON-EMEC.png'; // Use a local default image if logo is null or empty

    // Placeholder for star status (typically loaded from local storage, defaulting to false)
    bool isStarred = false;

    return ExhibitorsClass(
      json['id'] as int,
      json['nom'] as String? ?? 'No Name', // nom -> title
      pivotStand, // pivot.stand -> stand
      json['pays'] as String? ?? 'N/A', // pays -> adress (used for headquarters country in DetailScreen)
      json['activite'] as String? ?? 'No Activity', // activite -> shortDiscriptions
      json['adresse'] as String? ?? 'Details not available.', // adresse -> discriptions (full description)
      json['site'] as String? ?? 'N/A', // site -> siteweb
      imageUrl, // logo -> image (full URL)
      isStarred, // star (default false)
      false, // isRecommended (handled by expositionType/sponsorType logic)

      // New fields
      expositionType: json['exposition_type'] as String?,
      sponsorType: json['sponsor_type'] as String?,
    );
  }
}