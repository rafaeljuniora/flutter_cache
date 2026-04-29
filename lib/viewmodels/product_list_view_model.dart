import 'package:flutter/foundation.dart';

import '../data/product_repository.dart';
import '../models/product.dart';

class ProductListViewModel extends ChangeNotifier {
	ProductListViewModel({ProductRepository? repository}) : _repository = repository ?? ProductRepository();

	final ProductRepository _repository;

	List<Product> products = [];
	bool isLoading = false;
	bool isRefreshing = false;
	bool isShowingExpiredCache = false;
	String? errorMessage;

	Future<void> loadProducts() async {
		isLoading = true;
		errorMessage = null;
		notifyListeners();

		try {
			final cachedResult = await _repository.getCachedProducts();

			if (cachedResult == null) {
				final freshProducts = await _repository.fetchAndCacheProducts();

				products = freshProducts;
				isLoading = false;
				isRefreshing = false;
				isShowingExpiredCache = false;
				notifyListeners();
				return;
			}

			products = cachedResult.products;
			isLoading = false;
			isShowingExpiredCache = cachedResult.isExpired;
			notifyListeners();

			if (cachedResult.isExpired) {
				isRefreshing = true;
				notifyListeners();

				try {
					final freshProducts = await _repository.fetchAndCacheProducts();

					products = freshProducts;
					isRefreshing = false;
					isShowingExpiredCache = false;
					notifyListeners();
				} catch (_) {
					isRefreshing = false;
					notifyListeners();
				}
			}
		} catch (e) {
			errorMessage = 'Falha ao carregar produtos: $e';
			isLoading = false;
			isRefreshing = false;
			notifyListeners();
		}
	}

	Future<void> refreshProducts() async {
		isRefreshing = true;
		errorMessage = null;
		notifyListeners();

		try {
			final freshProducts = await _repository.fetchAndCacheProducts();

			products = freshProducts;
			isRefreshing = false;
			isShowingExpiredCache = false;
			notifyListeners();
		} catch (e) {
			errorMessage = 'Falha ao atualizar produtos: $e';
			isRefreshing = false;
			notifyListeners();
		}
	}
}

