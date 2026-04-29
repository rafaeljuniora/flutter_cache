import 'package:flutter/material.dart';

import '../models/product.dart';
import 'format.dart';
import 'widgets/product_network_image.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  static const double _detailImageHeight = 260;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: _detailImageHeight,
              child: PageView.builder(
                itemCount: product.images.length,
                itemBuilder: (context, index) {
                  return ProductNetworkImage(
                    imageUrl: product.images[index],
                    width: double.infinity,
                    height: _detailImageHeight,
                    fit: BoxFit.cover,
                    memCacheWidth: 1400,
                    iconSize: 48,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          product.category,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 18, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: theme.textTheme.labelLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    formatBrl(product.price),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product.description,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color: theme.colorScheme.surfaceContainerHighest,
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'Observacao didatica: ao voltar desta tela, a lista principal sera recarregada por completo.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
