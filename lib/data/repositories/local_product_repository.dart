import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:tochka_balansa/data/datasources/hive_data.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart';

class LocalProductRepository {
  static final LocalProductRepository _instance =
      LocalProductRepository._internal();

  LocalProductRepository._internal();

  factory LocalProductRepository() {
    _instance._init();
    return _instance;
  }

  // Метод для загрузки продуктов при инициализации
  bool _isInitialized = false;

  Future<void> _init() async {
    if (!_isInitialized) {
      try {
        await getAllProducts();
        _isInitialized = true;
      } catch (e) {
        Logger.e('Ошибка при инициализации LocalProductRepository: $e');
      }
    }
  }

  /// Получить продукт по баркоду
  Future<FoodProduct?> getProductByBarcode(String barcode) async {
    try {
      final products = await getAllProducts();
      return products
          .where((product) => product.barcode == barcode)
          .firstOrNull;
    } catch (e) {
      Logger.e('Ошибка при поиске продукта по баркоду: $e');
      return null;
    }
  }

  /// Сохранить продукт
  Future<void> saveProduct(FoodProduct product) async {
    Logger.i('new ${product.toJson()}');
    try {
      final products = await getAllProducts();
      // Удаляем существующий продукт с таким же ID, чтобы избежать дубликатов
      products.removeWhere((p) => p.id == product.id);
      products.add(product);
      await saveAllProducts(products);
    } catch (e) {
      Logger.e('Ошибка при сохранении продукта: $e');
      rethrow;
    }
  }

  /// Обновить продукт
  Future<void> updateProduct(FoodProduct product) async {
    try {
      final products = await getAllProducts();
      final index = products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        products[index] = product;
        await saveAllProducts(products);
      } else {
        // Если продукт не найден, сохраняем его как новый
        await saveProduct(product);
      }
    } catch (e) {
      Logger.e('Ошибка при обновлении продукта: $e');
      rethrow;
    }
  }

  /// Удалить продукт
  Future<void> deleteProduct(String id) async {
    try {
      final products = await getAllProducts();
      products.removeWhere((p) => p.id == id);
      await saveAllProducts(products);
    } catch (e) {
      Logger.e('Ошибка при удалении продукта: $e');
      rethrow;
    }
  }

  /// Получить все локальные продукты
  Future<List<FoodProduct>> getAllProducts() async {
    try {
      final data = await HiveData.loadListJson(key: HiveDataKey.foodProducts);
      Logger.i('data $data ');
      if (data.isNotEmpty && !data.first.containsKey('error')) {
        return data
            .map(
              (json) => FoodProduct.fromJson(Map<String, dynamic>.from(json)),
            )
            .toList();
      }
      return [];
    } catch (e) {
      Logger.e('Ошибка при получении всех продуктов: $e');
      return [];
    }
  }

  /// Сохранить все продукты
  Future<void> saveAllProducts(List<FoodProduct> products) async {
    try {
      final jsonList = products.map((product) => product.toJson()).toList();
      await HiveData.saveListJson(
        json: jsonList,
        key: HiveDataKey.foodProducts,
      );
    } catch (e) {
      Logger.e('Ошибка при сохранении всех продуктов: $e');
      rethrow;
    }
  }

  /// Поиск продуктов по названию
  Future<List<FoodProduct>> searchProducts(String query) async {
    try {
      final products = await getAllProducts();
      final lowercaseQuery = query.toLowerCase();
      return products
          .where(
            (product) => product.name.toLowerCase().contains(lowercaseQuery),
          )
          .toList();
    } catch (e) {
      Logger.e('Ошибка при поиске продуктов: $e');
      return [];
    }
  }

  /// Получить избранные продукты
  Future<List<FoodProduct>> getFavoriteProducts() async {
    try {
      final products = await getAllProducts();
      return products.where((product) => product.isFavorite).toList();
    } catch (e) {
      Logger.e('Ошибка при получении избранных продуктов: $e');
      return [];
    }
  }

  /// Очистить все данные
  Future<void> clearAll() async {
    try {
      await HiveData.saveListJson(json: [], key: HiveDataKey.foodProducts);
    } catch (e) {
      Logger.e('Ошибка при очистке данных: $e');
      rethrow;
    }
  }

  /// Проверить, существует ли продукт
  Future<bool> productExists(String id) async {
    try {
      final products = await getAllProducts();
      return products.any((product) => product.id == id);
    } catch (e) {
      Logger.e('Ошибка при проверке существования продукта: $e');
      return false;
    }
  }

  /// Увеличить счетчик использования продукта
  Future<void> incrementUsage(String productId) async {
    try {
      final products = await getAllProducts();
      final product = products.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw Exception('Product not found'),
      );
      products.removeWhere((p) => p.id == productId);
      products.add(product.incrementUsage());
      await saveAllProducts(products);
    } catch (e) {
      Logger.e('Ошибка при увеличении счетчика использования: $e');
      rethrow;
    }
  }

  /// Переключить избранное
  Future<void> toggleFavorite(String productId) async {
    try {
      final products = await getAllProducts();
      final product = products.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw Exception('Product not found'),
      );
      products.removeWhere((p) => p.id == productId);
      products.add(product.toggleFavorite());
      await saveAllProducts(products);
    } catch (e) {
      Logger.e('Ошибка при переключении избранного: $e');
      rethrow;
    }
  }

  /// Получить продукты по баркоду (в случае, если один баркод может быть связан с несколькими продуктами)
  Future<List<FoodProduct>> getProductListByBarcode(String barcode) async {
    try {
      final products = await getAllProducts();
      return products.where((product) => product.barcode == barcode).toList();
    } catch (e) {
      Logger.e('Ошибка при поиске продуктов по баркоду: $e');
      return [];
    }
  }

  /// Проверить, существует ли продукт с таким баркодом
  Future<bool> barcodeExists(String barcode) async {
    try {
      final products = await getAllProducts();
      return products.any((product) => product.barcode == barcode);
    } catch (e) {
      Logger.e('Ошибка при проверке существования баркода: $e');
      return false;
    }
  }

  /// Получить количество продуктов
  Future<int> getProductCount() async {
    try {
      final products = await getAllProducts();
      return products.length;
    } catch (e) {
      Logger.e('Ошибка при получении количества продуктов: $e');
      return 0;
    }
  }
}
