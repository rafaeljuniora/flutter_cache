import 'package:flutter/material.dart';

import '../data/product_exception.dart';
import '../data/product_repository.dart';
import '../models/product.dart';
import 'product_detail_page.dart';
import 'widgets/product_network_image.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ProductRepository _repository = ProductRepository();

  bool isLoading = false;
  bool isRefreshing = false;
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
      final loaded = await _repository.getProducts();

      if (!mounted) return;

      setState(() {
        products = loaded;
      });
    } on ProductException catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Nao foi possivel carregar os produtos agora.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> refreshProducts() async {
    setState(() {
      isRefreshing = true;
      errorMessage = null;
    });

    try {
      final loaded = await _repository.getProducts();

      if (!mounted) return;

      setState(() {
        products = loaded;
      });
    } on ProductException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nao foi possivel atualizar os produtos agora.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isRefreshing = false;
        });
      }
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
            onPressed: isRefreshing ? null : refreshProducts,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (errorMessage != null) {
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
              if (isRefreshing) const LinearProgressIndicator(),
              Expanded(
                child: ListView.separated(
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ProductNetworkImage(
                        imageUrl: product.thumbnail,
                        width: 72,
                        height: 72,
                        borderRadius: BorderRadius.circular(8),
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
