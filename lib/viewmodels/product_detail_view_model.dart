import 'package:flutter/foundation.dart';

import '../models/product.dart';

class ProductDetailViewModel extends ChangeNotifier {
	ProductDetailViewModel({required this.product});

	final Product product;

	/// Placeholdfer para futuras funcionalidades, como pré-carregar imagens ou favoritos
	Future<void> prefetchImages() async {
		// Vazio por enquanto, mas poderia ser usado para pré-carregar imagens ou outros dados relacionados ao produto.
	}
}

