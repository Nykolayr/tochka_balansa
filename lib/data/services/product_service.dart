import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart';
import 'package:tochka_balansa/data/services/food_api_service.dart';
import 'package:tochka_balansa/data/repositories/local_product_repository.dart';

class ProductService {
  final LocalProductRepository _localRepository;

  ProductService({required LocalProductRepository localRepository})
    : _localRepository = localRepository;

  /// Поиск продукта по баркоду
  /// Сначала проверяет локальную БД, затем OpenFoodFacts
  Future<ProductSearchResult> searchProductByBarcode(String barcode) async {
    try {
      // 1. Поиск в локальной БД
      final localProduct = await _localRepository.getProductByBarcode(barcode);
      if (localProduct != null) {
        return ProductSearchResult.local(localProduct);
      }

      // 2. Поиск в OpenFoodFacts
      final apiProduct = await FoodApiService.getProductByBarcode(barcode);
      if (apiProduct != null) {
        return ProductSearchResult.api(apiProduct);
      }

      // 3. Продукт не найден
      return ProductSearchResult.notFound(barcode);
    } catch (e) {
      return ProductSearchResult.error(e.toString());
    }
  }

  /// Сохранение локального продукта
  Future<void> saveLocalProduct(FoodProduct product) async {
    await _localRepository.saveProduct(product);
  }

  /// Конвертация API продукта в локальный
  FoodProduct? convertApiProductToLocal(FoodProduct apiProduct) {
    try {
      return FoodProduct.create(
        name: apiProduct.name,
        barcode: apiProduct.barcode,
        amount: apiProduct.amount,
        unit: apiProduct.unit,
        caloriesPer100: apiProduct.caloriesPer100,
        proteinsPer100: apiProduct.proteinsPer100,
        fatPer100: apiProduct.fatPer100,
        carbsPer100: apiProduct.carbsPer100,
        fiberPer100: apiProduct.fiberPer100,
        saturatedFatPer100: apiProduct.saturatedFatPer100,
        imageUrl: apiProduct.imageUrl,
      );
    } catch (e) {
      Logger.e('Ошибка конвертации API продукта: $e');
      return null;
    }
  }
}

/// Результат поиска продукта
class ProductSearchResult {
  final ProductSearchStatus status;
  final FoodProduct? localProduct;
  final FoodProduct? apiProduct;
  final String? barcode;
  final String? error;

  ProductSearchResult._({
    required this.status,
    this.localProduct,
    this.apiProduct,
    this.barcode,
    this.error,
  });

  factory ProductSearchResult.local(FoodProduct product) {
    return ProductSearchResult._(
      status: ProductSearchStatus.foundLocal,
      localProduct: product,
    );
  }

  factory ProductSearchResult.api(FoodProduct product) {
    return ProductSearchResult._(
      status: ProductSearchStatus.foundApi,
      apiProduct: product,
    );
  }

  factory ProductSearchResult.notFound(String barcode) {
    return ProductSearchResult._(
      status: ProductSearchStatus.notFound,
      barcode: barcode,
    );
  }

  factory ProductSearchResult.error(String error) {
    return ProductSearchResult._(
      status: ProductSearchStatus.error,
      error: error,
    );
  }
}

enum ProductSearchStatus {
  foundLocal, // Найден в локальной БД
  foundApi, // Найден в OpenFoodFacts
  notFound, // Не найден нигде
  error, // Ошибка поиска
}
