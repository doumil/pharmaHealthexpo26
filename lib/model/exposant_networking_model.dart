class ExposantNetworking {
  final int? id;
  final String? nom;
  final String? ville;
  final String? logo;
  final String? stand;
  final int? compteId;
  final String? activite;

  ExposantNetworking({
    this.id,
    this.nom,
    this.ville,
    this.logo,
    this.stand,
    this.compteId,
    this.activite,
  });

  factory ExposantNetworking.fromJson(Map<String, dynamic> json) {
    return ExposantNetworking(
      id: json['id'],
      nom: json['nom'],
      ville: json['ville'],
      logo: json['logo'],
      activite: json['activite'],
      compteId: json['compte_id'], // CRITICAL: Used for CommerciauxScreen
      // Extracting stand from the nested 'pivot' object
      stand: json['pivot'] != null ? json['pivot']['stand']?.toString() : "N/A",
    );
  }
}