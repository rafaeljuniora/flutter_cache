import 'package:flutter/material.dart';

import '../data/product_repository.dart';
import '../models/product.dart';
import 'product_detail_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ProductRepository _repository = ProductRepository();

  bool isLoading = false;
  bool isRefreshing = false;
  bool isShowingExpiredCache = false;
  String? errorMessage;
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final cachedResult = await _repository.getCachedProducts();

      if (cachedResult == null) {
        final freshProducts = await _repository.fetchAndCacheProducts();

        if (!mounted) return;

        setState(() {
          products = freshProducts;
          isLoading = false;
          isRefreshing = false;
          isShowingExpiredCache = false;
        });

        return;
      }

      if (!mounted) return;

      setState(() {
        products = cachedResult.products;
        isLoading = false;
        isShowingExpiredCache = cachedResult.isExpired;
      });

      if (cachedResult.isExpired) {
        setState(() {
          isRefreshing = true;
        });

        try {
          final freshProducts = await _repository.fetchAndCacheProducts();

          if (!mounted) return;

          setState(() {
            products = freshProducts;
            isRefreshing = false;
            isShowingExpiredCache = false;
          });
        } catch (e) {
          if (!mounted) return;

          setState(() {
            isRefreshing = false;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Falha ao carregar produtos: $e';
        isLoading = false;
        isRefreshing = false;
      });
    }
  }

  Future<void> refreshProducts() async {
    setState(() {
      isRefreshing = true;
      errorMessage = null;
    });

    try {
      final freshProducts = await _repository.fetchAndCacheProducts();

      if (!mounted) return;

      setState(() {
        products = freshProducts;
        isRefreshing = false;
        isShowingExpiredCache = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Falha ao atualizar produtos: $e';
        isRefreshing = false;
      });
    }
  }

  Future<void> openDetails(Product product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogo Problematico'),
        actions: [
          IconButton(
            onPressed: refreshProducts,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (isLoading && products.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (errorMessage != null && products.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: loadProducts,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              if (isShowingExpiredCache)
                Container(
                  width: double.infinity,
                  color: Colors.amber.shade100,
                  padding: const EdgeInsets.all(12),
                  child: const Text(
                    'Exibindo dados em cache vencido enquanto atualizamos a lista.',
                    textAlign: TextAlign.center,
                  ),
                ),
              if (isRefreshing)
                const LinearProgressIndicator(),
              Expanded(
                child: ListView.separated(
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.thumbnail,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 72,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.broken_image),
                            );
                          },
                        ),
                      ),
                      title: Text(
                        product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${product.category} • R\$ ${product.price.toStringAsFixed(2)}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => openDetails(product),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
