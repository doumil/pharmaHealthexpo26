// lib/model/organizer_model.dart

class OrganizerModel {
  final String name;
  final String email;
  final String phone;
  final String company;
  final String address;

  OrganizerModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.company,
    required this.address,
  });

  factory OrganizerModel.fromJson(Map<String, dynamic> json) {
    return OrganizerModel(
      // The keys here must match the keys in the 'organisateurs' array from the API response
      name: json['nom_organisateur'] as String? ?? 'N/A Organizer', // Assuming 'nom_organisateur' from API
      email: json['email'] as String? ?? 'N/A Email',
      phone: json['tel'] as String? ?? 'N/A Phone',
      company: json['societe'] as String? ?? 'N/A Company',
      address: json['address'] as String? ?? 'N/A Address',
    );
  }
}