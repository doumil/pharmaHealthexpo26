// lib/model/sponsor_model.dart

class SponsorClass {
  final int id;
  final String title;
  final String stand;
  final String shortDiscriptions;
  final String adress;
  final String discriptions;
  final String webSite;
  final String image;
  bool star;
  final bool isRecommended;

  SponsorClass(
      this.id,
      this.title,
      this.stand,
      this.shortDiscriptions,
      this.adress,
      this.discriptions,
      this.webSite,
      this.image,
      this.star, {
        this.isRecommended = false,
      });

  factory SponsorClass.fromJson(Map<String, dynamic> json) {
    return SponsorClass(
      json['id'] ?? 0,
      json['title'] ?? '',
      json['stand'] ?? '',
      json['short_discriptions'] ?? '',
      json['adress'] ?? '',
      json['discriptions'] ?? '',
      json['web_site'] ?? '',
      json['image'] ?? '',
      json['star'] ?? false,
      isRecommended: true,
    );
  }
}