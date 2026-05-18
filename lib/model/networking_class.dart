class NetworkingClass {
  final int id;
  final String nom;
  final String? activite;
  final String? ville;
  final String? logo;
  final String? stand;

  NetworkingClass({
    required this.id,
    required this.nom,
    this.activite,
    this.ville,
    this.logo,
    this.stand,
  });

  factory NetworkingClass.fromJson(Map<String, dynamic> json) {
    return NetworkingClass(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      activite: json['activite'],
      ville: json['ville'],
      logo: json['logo'],
      // The stand number is inside the 'pivot' object in your JSON
      stand: json['pivot'] != null ? json['pivot']['stand']?.toString() : 'N/A',
    );
  }
}