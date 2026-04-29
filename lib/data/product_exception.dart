class ProductException implements Exception {
  ProductException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ProductNetworkException extends ProductException {
  ProductNetworkException([super.message = 'Falha de conexao. Verifique sua internet e tente novamente.']);
}

class ProductTimeoutException extends ProductException {
  ProductTimeoutException([super.message = 'A requisicao demorou mais do que o esperado. Tente novamente.']);
}

class ProductServerException extends ProductException {
  ProductServerException(int statusCode)
      : super('O servidor respondeu com erro ($statusCode). Tente novamente em instantes.');
}

class ProductDataException extends ProductException {
  ProductDataException([super.message = 'Nao foi possivel processar os dados recebidos.']);
}
