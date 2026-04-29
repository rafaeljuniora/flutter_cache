import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';
import 'product_api.dart';

class ProductRepository {
  ProductRepository({ProductApi? api}) : _api = api ?? ProductApi();

  final ProductApi _api;

  List<Product>? _memoryCache;

  static const _productsCacheKey = 'products_cache';
  static const _productsCacheTimeKey = 'products_cache_time';
  static const _cacheTtl = Duration(minutes: 60);

  Future<CachedProductsResult?> getCachedProducts() async {
    if (_memoryCache != null) {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_productsCacheTimeKey);

      return CachedProductsResult(
        products: _memoryCache!,
        isExpired: _isExpired(timestamp),
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString(_productsCacheKey);
    final timestamp = prefs.getInt(_productsCacheTimeKey);

    if (cachedJson == null) {
      return null;
    }

    final decoded = jsonDecode(cachedJson) as List<dynamic>;
    final products = decoded
        .map((item) => Product.fromMap(item as Map<String, dynamic>))
        .toList();

    _memoryCache = products;

    return CachedProductsResult(
      products: products,
      isExpired: _isExpired(timestamp),
    );
  }

  Future<List<Product>> fetchAndCacheProducts() async {
    final products = await _api.fetchProducts();

    _memoryCache = products;

    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      products.map((product) => product.toMap()).toList(),
    );

    await prefs.setString(_productsCacheKey, encoded);
    await prefs.setInt(
      _productsCacheTimeKey,
      DateTime.now().millisecondsSinceEpoch,
    );

    return products;
  }

  bool _isExpired(int? timestamp) {
    if (timestamp == null) {
      return true;
    }

    final savedAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final age = DateTime.now().difference(savedAt);

    return age > _cacheTtl;
  }
}

class CachedProductsResult {
  CachedProductsResult({
    required this.products,
    required this.isExpired,
  });

  final List<Product> products;
  final bool isExpired;
}
