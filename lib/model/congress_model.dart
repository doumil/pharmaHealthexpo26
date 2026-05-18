class Speaker {
  final String name;
  final String imageUrl;

  Speaker({required this.name, required this.imageUrl});
}

class CongressClass {
  final int id;
  final String title; // e.g., "Opening | Welcome Address"
  final String? subtitle; // If there's a secondary title
  final bool isSessionOver; // To display "Session is over"
  final String? date; // e.g., "mer., 16 avr. 2025"
  final String? time; // e.g., "10:15 - 10:20 | Africa(Casablanca time)"
  final String? location; // e.g., "GITEX Africa/Ai Stage"
  final String? stage; // e.g., "Ai Stage"
  final List<String>? tags; // e.g., ["GITEX Africa"]
  final List<Speaker>? speakers; // List of speakers for this session

  CongressClass({
    required this.id,
    required this.title,
    this.subtitle,
    this.isSessionOver = false,
    this.date,
    this.time,
    this.location,
    this.stage,
    this.tags,
    this.speakers,
  });
}