class Product {
  final int id;
  final String name;
  final String tagline;
  final String category;
  final double price;
  final String image;
  final String description;
  final Map<String, String> specs;

  const Product({
    required this.id,
    required this.name,
    required this.tagline,
    required this.category,
    required this.price,
    required this.image,
    required this.description,
    required this.specs,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    var rawSpecs = (json['specs'] as Map<String, dynamic>?) ?? {};
    var name = json['name'] as String;
    return Product(
      id: json['id'] as int,
      name: name,
      tagline: (json['tagline'] as String?) ?? '',
      category: _getCategory(name),
      price: _parsePrice(json['price']),
      image: json['image'] as String,
      description: (json['description'] as String?) ?? '',
      specs: rawSpecs.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tagline': tagline,
        'category': category,
        'price': price,
        'image': image,
        'description': description,
        'specs': specs,
      };

  static double _parsePrice(dynamic value) {
    if (value is num) return value.toDouble();
    var digits = value.toString().replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(digits) ?? 0;
  }

  static String _getCategory(String name) {
    var text = name.toLowerCase();
    if (text.contains('iphone')) return 'Phone';
    if (text.contains('macbook') || text.contains('imac')) return 'Computer';
    if (text.contains('ipad')) return 'Tablet';
    if (text.contains('watch') || text.contains('vision')) return 'Wearable';
    if (text.contains('airpods') || text.contains('homepod')) return 'Audio';
    return 'Other';
  }
}
