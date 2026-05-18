// lib/model/program_model.dart

// ---------------------------------------------------------------------
// Model for the nested speaker data
class SpeakerModel {
  final int id;
  final String prenom;
  final String nom;
  final String poste;
  final String? pic;

  String get fullName => '$prenom $nom';

  SpeakerModel({
    required this.id,
    required this.prenom,
    required this.nom,
    required this.poste,
    this.pic,
  });

  factory SpeakerModel.fromJson(Map<String, dynamic> json) {
    return SpeakerModel(
      id: json['id'] as int,
      prenom: json['prenom'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      poste: json['poste'] as String? ?? 'Speaker',
      pic: json['pic'] as String?,
    );
  }
}
// ---------------------------------------------------------------------

class ProgramDataModel {
  final List<String> periods;
  final List<ProgramItemModel> programs;

  ProgramDataModel({
    required this.periods,
    required this.programs,
  });

  factory ProgramDataModel.fromJson(Map<String, dynamic> json) {
    final List<String> periods = (json['periods'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ??
        [];

    final List<ProgramItemModel> programs = (json['programs'] as List<dynamic>?)
        ?.map((e) => ProgramItemModel.fromJson(e as Map<String, dynamic>))
        .toList() ??
        [];

    return ProgramDataModel(
      periods: periods,
      programs: programs,
    );
  }
}

// ---------------------------------------------------------------------

class ProgramItemModel {
  final int id;
  final String title;
  final String dateDeb;
  final String dateFin;
  final String description;
  final String location;
  final String type;
  final List<SpeakerModel> speakers;

  ProgramItemModel({
    required this.id,
    required this.title,
    required this.dateDeb,
    required this.dateFin,
    required this.description,
    required this.location,
    required this.type,
    required this.speakers,
  });

  factory ProgramItemModel.fromJson(Map<String, dynamic> json) {
    // 💡 FIX APPLIED HERE: Safely handle null for the 'speakers' list.
    final List<dynamic>? speakersJson = json['speakers'] as List<dynamic>?;

    final List<SpeakerModel> speakers = speakersJson == null
        ? [] // Return an empty list if speakersJson is null
        : speakersJson
        .map((e) => SpeakerModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return ProgramItemModel(
      id: json['id'] as int,
      title: json['nom'] as String? ?? 'Untitled Session',
      dateDeb: json['date_deb'] as String? ?? '',
      dateFin: json['date_fin'] as String? ?? '',
      description: json['description'] as String? ?? 'No description provided.',
      location: json['emplacement'] as String? ?? 'Not specified',
      type: json['type'] as String? ?? 'Event',
      speakers: speakers, // Assign the now guaranteed non-null list
    );
  }
}