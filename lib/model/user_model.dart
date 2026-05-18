// lib/model/user_model.dart (Confirmed and Corrected)

import 'dart:convert';

class User {
  final int id;
  final String? name;
  final String? nom;      // Last Name
  final String? prenom;   // First Name
  final String? email;
  final String? token;

  // Professional Details
  final String? societe;   // Company (Société)
  final String? profession;  // Job Title (Profession)

  // Contact & Location Details
  final String? pic;       // Profile Picture URL
  final String? tel;       // Telephone number
  final String? address;
  final String? city;
  final String? country;

  User({
    required this.id,
    this.name,
    this.nom,
    this.prenom,
    this.email,
    this.token,
    this.societe,
    this.profession,
    this.pic,
    this.tel,
    this.address,
    this.city,
    this.country,
  });

  // Original Factory: Used for Login/Profile APIs
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String?,
      nom: json['nom'] as String?,
      prenom: json['prenom'] as String?,
      email: json['email'] as String?,
      token: json['token'] as String?,

      // Professional Mappings
      societe: json['societe'] as String?,
      // 🎯 FIX: Mapped from the typo key 'prefession' in the API JSON
      profession: json['prefession'] as String?,

      // Contact & Location Mappings
      pic: json['pic'] as String?,
      tel: json['tel'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
    );
  }

  // 🚀 NEW Factory: Used for the 'user-by-order' (Scanned) API
  factory User.fromScannedJson(Map<String, dynamic> json) {
    // Note: The scanned API response is missing 'id' and 'token'.
    return User(
      // Use a placeholder ID since it's not provided
      id: -1,
      name: null,
      nom: json['nom'] as String?,
      prenom: json['prenom'] as String?,
      email: json['email'] as String?,
      token: null,

      // Professional Mappings
      societe: json['societe'] as String?,
      profession: json['prefession'] as String?, // Mapping the typo

      // Contact & Location Mappings
      tel: json['tel'] as String?,
      pic: null,
      address: null,
      city: null,
      country: null,
    );
  }

  // Helper method to convert back to JSON for SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'token': token,
      'societe': societe,
      'profession': profession,
      'pic': pic,
      'tel': tel,
      'address': address,
      'city': city,
      'country': country,
    };
  }
}