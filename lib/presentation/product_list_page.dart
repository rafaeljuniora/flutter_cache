import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';
import '../viewmodels/product_list_view_model.dart';
import 'product_detail_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late final ProductListViewModel _vm;
  late final VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _vm = ProductListViewModel();
    _listener = () {
      if (mounted) setState(() {});
    };
    _vm.addListener(_listener);
    _vm.loadProducts();
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
  void dispose() {
    _vm.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogo Problematico'),
        actions: [
          IconButton(
            onPressed: () => _vm.refreshProducts(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final vm = _vm;

          if (vm.isLoading && vm.products.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (vm.errorMessage != null && vm.products.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      vm.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: vm.loadProducts,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              if (vm.isShowingExpiredCache)
                Container(
                  width: double.infinity,
                  color: Colors.amber.shade100,
                  padding: const EdgeInsets.all(12),
                  child: const Text(
                    'Exibindo dados em cache vencido enquanto atualizamos a lista.',
                    textAlign: TextAlign.center,
                  ),
                ),
              if (vm.isRefreshing) const LinearProgressIndicator(),
              Expanded(
                child: ListView.separated(
                  itemCount: vm.products.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final product = vm.products[index];

                    return ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: product.thumbnail,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          memCacheWidth: 200,
                          memCacheHeight: 200,
                          placeholder: (context, url) {
                            return Container(
                              width: 72,
                              height: 72,
                              color: Colors.grey.shade200,
                              alignment: Alignment.center,
                              child: const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          },
                          errorWidget: (context, url, error) {
                            return Container(
                              width: 72,
                              height: 72,
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
