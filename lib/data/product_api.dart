import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ProductApi {
  ProductApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Product>> fetchProducts() async {
    //await Future.delayed(const Duration(seconds: 2));

    final response = await _client.get(
      Uri.parse('https://dummyjson.com/products?limit=30'),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar produtos');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final rawProducts = data['products'] as List<dynamic>;

    return rawProducts
        .map((item) => Product.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}
