import 'package:flutter/material.dart';

import '../data/product_repository.dart';
import '../models/product.dart';
import 'format.dart';
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
            return const _ProductListSkeleton();
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
              if (isRefreshing) const LinearProgressIndicator(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: refreshProducts,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _ProductCard(
                        product: product,
                        onTap: () => openDetails(product),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.thumbnail,
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 84,
                      height: 84,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.broken_image),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product.category,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                size: 16, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: theme.textTheme.labelMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatBrl(product.price),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductListSkeleton extends StatelessWidget {
  const _ProductListSkeleton();

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: base,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBar(width: double.infinity, height: 14, color: base),
                      const SizedBox(height: 8),
                      _SkeletonBar(width: 160, height: 12, color: base),
                      const SizedBox(height: 14),
                      _SkeletonBar(width: 100, height: 16, color: base),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
