import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import '../models/product.dart';
import 'product_exception.dart';

class ProductApi {
  ProductApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _client
          .get(
            Uri.parse('https://dummyjson.com/products?limit=30'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw ProductServerException(response.statusCode);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final rawProducts = data['products'] as List<dynamic>;

      return rawProducts
          .map((item) => Product.fromMap(item as Map<String, dynamic>))
          .toList();
    } on TimeoutException {
      throw ProductTimeoutException();
    } on http.ClientException {
      throw ProductNetworkException();
    } on FormatException {
      throw ProductDataException();
    } on ProductException {
      rethrow;
    } catch (_) {
      throw ProductException(
        'Ocorreu um erro inesperado ao carregar os produtos.',
      );
    }
  }
}
