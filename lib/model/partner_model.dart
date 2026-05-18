// lib/model/partner_model.dart

class PartnerClass {
  final int id;
  final String title;
  final String imageUrl;

  PartnerClass({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  factory PartnerClass.fromJson(Map<String, dynamic> json) {
    return PartnerClass(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? 'Partner', // Use 'title' or 'name'
      imageUrl: json['image'] ?? '', // Assuming 'image' holds the URL
    );
  }
}