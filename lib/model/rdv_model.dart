// lib/model/rdv_model.dart

class RdvClass {
  final int id;
  final String commercialName;
  final String commercialImage;
  final String rdvDate;
  final String rdvTime;
  final String status; // e.g., 'pending', 'confirmed'

  RdvClass({
    required this.id,
    required this.commercialName,
    required this.commercialImage,
    required this.rdvDate,
    required this.rdvTime,
    required this.status,
  });

  factory RdvClass.fromJson(Map<String, dynamic> json) {
    final commercial = json['commercial'] ?? {};

    String commercialImageUrl = commercial['pic'] as String? ?? '';
    if (commercialImageUrl.isNotEmpty && !commercialImageUrl.startsWith('http')) {
      commercialImageUrl = 'https://buzzevents.co/storage/' + commercialImageUrl;
    }

    return RdvClass(
      id: json['id'] as int? ?? 0,
      commercialName: commercial['nom'] as String? ?? 'N/A',
      commercialImage: commercialImageUrl,
      // Assuming 'start_time' holds the combined date/time string
      rdvDate: json['start_time'] != null
          ? json['start_time'].toString().substring(0, 10)
          : 'N/A',
      rdvTime: json['start_time'] != null
          ? json['start_time'].toString().substring(11, 16)
          : 'N/A',
      status: json['status'] as String? ?? 'pending',
    );
  }
}