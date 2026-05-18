// lib/model/speakers_model.dart

import 'dart:convert';

// --- Constants ---
const String kDefaultSpeakerImageUrl = 'https://buzzevents.co/uploads/ICON-EMEC.png';


// --- 1. Top-Level Data Model ---
class SpeakersDataModel {
  // The list of unique date strings (now correctly populated)
  final List<String> periods;
  final List<Speakers> speakers;

  SpeakersDataModel({required this.periods, required this.speakers});

  factory SpeakersDataModel.fromJson(Map<String, dynamic> json) {
    // Ensure we access the 'data' object first
    final data = json['data'] as Map<String, dynamic>?;

    if (data == null) {
      // Handle case where 'data' is missing or null
      return SpeakersDataModel(periods: [], speakers: []);
    }

    // Extract periods (list of strings)
    final List<String> periodsList = (data['periods'] as List<dynamic>? ?? [])
        .map((p) => p.toString())
        .toList();

    // Extract speakers (list of maps)
    final List<Speakers> speakersList = (data['speakers'] as List<dynamic>? ?? [])
        .map((speakerJson) => Speakers.fromJson(speakerJson as Map<String, dynamic>))
        .toList();

    return SpeakersDataModel(
      periods: periodsList,
      speakers: speakersList,
    );
  }
}

// --- 2. Program Session Model ---
class ProgramSession {
  final int id;
  final String nom; // Session name
  final String dateDeb; // Start Date/Time string (e.g., "09/29/2025 12:00 PM")
  final String dateFin; // End Date/Time string
  final String? emplacement;
  final String type; // Session type (e.g., "Break", "Webinar")
  final String description;

  ProgramSession({
    required this.id,
    required this.nom,
    required this.dateDeb,
    required this.dateFin,
    this.emplacement,
    required this.type,
    required this.description,
  });

  factory ProgramSession.fromJson(Map<String, dynamic> json) {
    return ProgramSession(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      dateDeb: json['date_deb'] ?? '',
      dateFin: json['date_fin'] ?? '',
      emplacement: json['emplacement'] as String?,
      type: json['type'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

// --- 3. Speakers Model ---
class Speakers {
  final int id;
  final String prenom;
  final String nom;
  // Note: The API key is 'compagnie', mapped to 'company' here.
  final String compagnie;
  final String poste;
  final String? pic;          // 🎯 Made nullable
  final String? biographie;   // 🎯 Made nullable
  bool isFavorite;
  final bool isRecommended;   // Defaulted to false since the new API doesn't provide it
  final List<ProgramSession> sessions; // Now populated from the API 'programs' field

  Speakers({
    this.id = 0,
    required this.prenom,
    required this.nom,
    required this.compagnie,
    required this.poste,
    this.pic,
    this.biographie,
    this.isFavorite = false,
    this.isRecommended = false,
    this.sessions = const [],
  });

  factory Speakers.fromJson(Map<String, dynamic> json) {
    // 💡 Null safety and default values applied
    return Speakers(
      id: json['id'] ?? 0,
      prenom: json['prenom'] ?? '',
      nom: json['nom'] ?? '',
      // Use 'compagnie' from API
      compagnie: json['compagnie'] ?? '',
      poste: json['poste'] ?? '',
      // Directly cast to String? as recommended for potentially null fields
      pic: json['pic'] as String?,
      biographie: json['biographie'] as String?,
      // Sessions are populated from the API 'programs' array
      sessions: (json['programs'] as List? ?? [])
          .map((i) => ProgramSession.fromJson(i))
          .toList(),
      // Default local values if not present in API
      isFavorite: json['isFavorite'] as bool? ?? false,
      isRecommended: json['isRecommended'] as bool? ?? false,
    );
  }

  // Getter for consistent naming in the UI (SpeakersScreen.dart uses this)
  String get company => compagnie;
}