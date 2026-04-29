import 'package:flutter/foundation.dart';

import '../data/product_exception.dart';
import '../data/product_repository.dart';
import '../models/product.dart';

class ProductListViewModel extends ChangeNotifier {
	ProductListViewModel({ProductRepository? repository})
		: _repository = repository ?? ProductRepository();

	final ProductRepository _repository;

	List<Product> products = [];
	bool isLoading = false;
	bool isRefreshing = false;
	bool isShowingExpiredCache = false;
	String? errorMessage;
	String? refreshMessage;

	Future<void> loadProducts() async {
		isLoading = true;
		errorMessage = null;
		refreshMessage = null;
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
				} on ProductException catch (e) {
					refreshMessage = e.message;
					isRefreshing = false;
					notifyListeners();
				} catch (_) {
					refreshMessage = 'Nao foi possivel atualizar os produtos agora.';
					isRefreshing = false;
					notifyListeners();
				}
			}
		} on ProductException catch (e) {
			errorMessage = e.message;
			isLoading = false;
			isRefreshing = false;
			notifyListeners();
		} catch (_) {
			errorMessage = 'Nao foi possivel carregar os produtos agora.';
			isLoading = false;
			isRefreshing = false;
			notifyListeners();
		}
	}

	Future<void> refreshProducts() async {
		isRefreshing = true;
		errorMessage = null;
		refreshMessage = null;
		notifyListeners();

		try {
			final freshProducts = await _repository.fetchAndCacheProducts();

			products = freshProducts;
			isRefreshing = false;
			isShowingExpiredCache = false;
			notifyListeners();
		} on ProductException catch (e) {
			refreshMessage = e.message;
			isRefreshing = false;
			notifyListeners();
		} catch (_) {
			refreshMessage = 'Nao foi possivel atualizar os produtos agora.';
			isRefreshing = false;
			notifyListeners();
		}
	}

	String? consumeRefreshMessage() {
		final message = refreshMessage;
		refreshMessage = null;
		return message;
	}
}
