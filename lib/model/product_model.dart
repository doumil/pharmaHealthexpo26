class ProductClass {
  String name;
  String shortname;
  String shortdiscription;
  String image; // To hold the product image path
  bool isFavorite; // For the star icon in the grid

  ProductClass(this.name, this.shortname, this.shortdiscription, this.image, {this.isFavorite = false});

// If you are loading from JSON, your fromJson method should also include image and isFavorite
// factory ProductClass.fromJson(Map<String, dynamic> json) {
//   return ProductClass(
//     json['name'] ?? '',
//     json['shortname'] ?? '',
//     json['shortdiscription'] ?? '',
//     json['image'] ?? 'assets/placeholder_product.png', // Default image
//     isFavorite: json['isFavorite'] ?? false,
//   );
// }
}