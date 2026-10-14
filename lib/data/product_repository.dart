import 'dart:convert';
import 'dart:io';

import '../models/product.dart';

class ProductRepository {
  static const String url = 'https://wantapi.com/products.php';

  static Future<List<Product>> getProducts() async {
    var client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      var request = await client.getUrl(Uri.parse(url));
      var response = await request.close().timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw HttpException('Server error: ${response.statusCode}');
      }
      var body = await response.transform(utf8.decoder).join();
      var json = jsonDecode(body) as Map<String, dynamic>;
      var list = json['data'] as List<dynamic>;
      return list
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } finally {
      client.close();
    }
  }
}
