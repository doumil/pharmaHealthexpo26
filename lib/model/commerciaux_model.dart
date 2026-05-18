class Creneau {
  final int id;
  final String date;
  final String debut;
  final String fin;
  final int isReserved;

  Creneau({required this.id, required this.date, required this.debut, required this.fin, required this.isReserved});

  factory Creneau.fromJson(Map<String, dynamic> json) {
    return Creneau(
      id: json['creneau_id'] ?? 0,
      date: json['date'] ?? '',
      debut: json['heure_debut'] ?? '',
      fin: json['heure_fin'] ?? '',
      isReserved: json['reserver'] ?? 0,
    );
  }
}

class CommerciauxClass {
  final int id;
  final String fullName;
  final String email;
  final String imagePath;
  final List<Creneau> availableCreneaux;

  CommerciauxClass({
    required this.id,
    required this.fullName,
    required this.email,
    required this.imagePath,
    required this.availableCreneaux,
  });

  factory CommerciauxClass.fromJson(Map<String, dynamic> json) {
    var list = json['calendrier']?['creneaux'] as List? ?? [];
    List<Creneau> creneauxList = list.map((i) => Creneau.fromJson(i)).toList();

    String pic = json['pic'] as String? ?? '';
    String fullImageUrl = (pic.isNotEmpty && !pic.startsWith('http'))
        ? 'https://buzzevents.co/storage/$pic'
        : pic;

    return CommerciauxClass(
      id: json['id'] ?? 0,
      fullName: json['name'] ?? 'N/A',
      email: json['email'] ?? '',
      imagePath: fullImageUrl,
      availableCreneaux: creneauxList,
    );
  }
}