// lib/model/user_scanner.dart

class Userscan {
  // --- Data Fields (from API and CSV columns) ---
  final String lastname;
  final String firstname;
  final String company;
  final String profession;
  final String email;
  final String phone;
  // Custom fields for the app (not returned by API, initialized as empty)
  final String evolution;
  final String action;
  final String notes;
  // API timestamp fields
  final String created;
  final String updated;

  // --- App/Display Fields (Metadata) ---
  final String? profilePicturePath;
  final String? companyLogoPath;
  final DateTime scanTime;

  Userscan({
    required this.lastname,
    required this.firstname,
    required this.company,
    required this.profession,
    required this.email,
    required this.phone,
    required this.evolution,
    required this.action,
    required this.notes,
    required this.created,
    required this.updated,
    this.profilePicturePath,
    this.companyLogoPath,
    required this.scanTime,
  });

  // --- Display Helpers ---
  String get name => '$firstname $lastname'.trim();
  String get title => profession;
  String get initials {
    String first = firstname.isNotEmpty ? firstname[0] : '';
    String last = lastname.isNotEmpty ? lastname[0] : '';
    return '$first$last';
  }
  String get formattedScanTime {
    return '${scanTime.day.toString().padLeft(2, '0')}/${scanTime.month.toString().padLeft(2, '0')} ${scanTime.hour.toString().padLeft(2, '0')}:${scanTime.minute.toString().padLeft(2, '0')}';
  }

  // --- Factory for API response (JSON) - MAPS API KEYS TO MODEL FIELDS ---
  factory Userscan.fromJson(Map<String, dynamic> json) {
    return Userscan(
      // MAPPING: API "nom" -> model lastname
      lastname: json['nom'] as String? ?? '',
      // MAPPING: API "prenom" -> model firstname
      firstname: json['prenom'] as String? ?? '',
      // MAPPING: API "societe" -> model company
      company: json['societe'] as String? ?? '',
      // MAPPING: API "prefession" -> model profession
      profession: json['prefession'] as String? ?? '',
      email: json['email'] as String? ?? '',
      // MAPPING: API "tel" -> model phone
      phone: json['tel'] as String? ?? '',

      // Initialize custom fields as empty strings for a fresh scan
      evolution: '',
      action: '',
      notes: '',
      created: '',
      updated: '',

      profilePicturePath: null,
      companyLogoPath: null,
      scanTime: DateTime.now(), // Set scan time upon receipt from API
    );
  }

  // --- Serialization for Storage (toMap/toJson) and Factory from Stored Data (fromMap) ---
  Map<String, dynamic> toMap() {
    return {
      'lastname': lastname,
      'firstname': firstname,
      'company': company,
      'profession': profession,
      'email': email,
      'phone': phone,
      'evolution': evolution,
      'action': action,
      'notes': notes,
      'created': created,
      'updated': updated,
      'profilePicturePath': profilePicturePath,
      'companyLogoPath': companyLogoPath,
      'scanTime': scanTime.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory Userscan.fromMap(Map<String, dynamic> map) {
    // FIX: Safely retrieve scanTime string, defaulting to a current timestamp if null/missing.
    final String scanTimeString = map['scanTime'] as String? ?? DateTime.now().toIso8601String();

    return Userscan(
      lastname: map['lastname'] as String? ?? '',
      firstname: map['firstname'] as String? ?? '',
      company: map['company'] as String? ?? '',
      profession: map['profession'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      evolution: map['evolution'] as String? ?? '',
      action: map['action'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      created: map['created'] as String? ?? '',
      updated: map['updated'] as String? ?? '',
      profilePicturePath: map['profilePicturePath'] as String?,
      companyLogoPath: map['companyLogoPath'] as String?,
      scanTime: DateTime.parse(scanTimeString),
    );
  }
}