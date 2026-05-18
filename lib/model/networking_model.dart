// lib/model/networking_model.dart

class NetworkingClass {
  final int id;
  // 🎉 ADDED: The property required to fix the "getter not defined" error
  final int compteId;
  final String? entreprise;
  final String? ville;
  final String imagePath;
  // Add any other properties your API returns
  final String? nom; // Added 'nom' for display consistency
  final String? description;

  NetworkingClass({
    required this.id,
    required this.compteId,
    this.entreprise,
    this.ville,
    required this.imagePath,
    this.nom,
    this.description,
  });

  factory NetworkingClass.fromJson(Map<String, dynamic> json) {
    return NetworkingClass(
      id: json['id'] as int,
      // 🎉 Mapped: The JSON key 'compte_id' to the Dart property 'compteId'
      compteId: json['compte_id'] as int,
      entreprise: json['entreprise'] as String?,
      ville: json['ville'] as String?,
      imagePath: json['image_path'] as String? ?? 'default_path',
      nom: json['nom'] as String?,
      description: json['description'] as String?,
    );
  }
}