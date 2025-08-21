import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:tochka_balansa/data/datasources/hive_data.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart';

/// Единый репозиторий для работы с продуктами питания
class FoodProductRepository {
  static final FoodProductRepository _instance =
      FoodProductRepository._internal();
  factory FoodProductRepository() => _instance;
  FoodProductRepository._internal();

  bool _isInitialized = false;
  final List<FoodProduct> products = [];

  /// Инициализация репозитория
  Future<void> init() async {
    if (!_isInitialized) {
      try {
        await _loadFromLocal();
        _isInitialized = true;
        Logger.i('FoodProductRepository инициализирован');
      } catch (e) {
        Logger.e('Ошибка при инициализации FoodProductRepository: $e');
      }
    }
  }

  /// Загрузка продуктов из локального хранилища
  Future<void> _loadFromLocal() async {
    try {
      final data = await HiveData.loadListJson(key: HiveDataKey.foodProducts);
      if (data.isNotEmpty && !data.first.containsKey('error')) {
        products.clear();
        products.addAll(
          data.map(
            (json) => FoodProduct.fromJson(Map<String, dynamic>.from(json)),
          ),
        );
      }
    } catch (e) {
      Logger.e('Ошибка при загрузке продуктов из локального хранилища: $e');
    }
  }

  /// Получить все продукты (синхронно из локального списка)
  List<FoodProduct> getAllProducts() {
    return products;
  }

  /// Сохранить все продукты
  void saveAllProducts(List<FoodProduct> productsToSave) {
    try {
      final jsonList = productsToSave
          .map((product) => product.toJson())
          .toList();
      HiveData.saveListJson(json: jsonList, key: HiveDataKey.foodProducts);
    } catch (e) {
      Logger.e('Ошибка при сохранении всех продуктов: $e');
    }
  }

  /// Получить продукт по баркоду
  FoodProduct? getProductByBarcode(String barcode) {
    try {
      return products
          .where((product) => product.barcode == barcode)
          .firstOrNull;
    } catch (e) {
      Logger.e('Ошибка при поиске продукта по баркоду: $e');
      return null;
    }
  }

  /// Сохранить продукт
  void saveProduct(FoodProduct product) {
    try {
      // Удаляем существующий продукт с таким же ID, чтобы избежать дубликатов
      products.removeWhere((p) => p.id == product.id);
      products.add(product);
      saveAllProducts(products);
    } catch (e) {
      Logger.e('Ошибка при сохранении продукта: $e');
    }
  }

  /// Обновить продукт
  void updateProduct(FoodProduct product) {
    try {
      final index = products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        products[index] = product;
        saveAllProducts(products);
      } else {
        // Если продукт не найден, сохраняем его как новый
        saveProduct(product);
      }
    } catch (e) {
      Logger.e('Ошибка при обновлении продукта: $e');
    }
  }

  /// Удалить продукт
  void deleteProduct(String id) {
    try {
      products.removeWhere((p) => p.id == id);
      saveAllProducts(products);
    } catch (e) {
      Logger.e('Ошибка при удалении продукта: $e');
    }
  }

  /// Получить избранные продукты
  List<FoodProduct> getFavoriteProducts() {
    try {
      return products.where((product) => product.isFavorite).toList();
    } catch (e) {
      Logger.e('Ошибка при получении избранных продуктов: $e');
      return [];
    }
  }

  /// Возвращает список недавних продуктов (за последние 7 дней)
  List<FoodProduct> getRecentProducts() {
    try {
      final now = DateTime.now();
      final recent = products
          .where((p) => now.difference(p.timestamp).inDays <= 7)
          .toList();
      // Сортируем по дате использования (сначала самые новые)
      recent.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return recent;
    } catch (e) {
      Logger.e('Ошибка при получении недавних продуктов: $e');
      return [];
    }
  }

  /// Возвращает часто используемые продукты (по usageCount)
  List<FoodProduct> getFrequentProducts() {
    try {
      final frequent = products.where((p) => p.usageCount > 0).toList();
      // Сортируем по количеству использования (сначала самые частые)
      frequent.sort((a, b) => b.usageCount.compareTo(a.usageCount));
      return frequent;
    } catch (e) {
      Logger.e('Ошибка при получении часто используемых продуктов: $e');
      return [];
    }
  }

  /// Поиск продуктов по названию
  List<FoodProduct> searchProducts(String query) {
    try {
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

  /// Переключить избранное продукта
  void toggleProductFavorite(String productId) {
    try {
      final product = products.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw Exception('Product not found'),
      );
      products.removeWhere((p) => p.id == productId);
      products.add(product.toggleFavorite());
      saveAllProducts(products);
    } catch (e) {
      Logger.e('Ошибка при переключении избранного: $e');
    }
  }

  /// Увеличить счетчик использования продукта
  void incrementUsage(String productId) {
    try {
      final product = products.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw Exception('Product not found'),
      );
      products.removeWhere((p) => p.id == productId);
      products.add(product.incrementUsage());
      saveAllProducts(products);
    } catch (e) {
      Logger.e('Ошибка при увеличении счетчика использования: $e');
    }
  }

  /// Проверить, существует ли продукт
  bool productExists(String id) {
    try {
      return products.any((product) => product.id == id);
    } catch (e) {
      Logger.e('Ошибка при проверке существования продукта: $e');
      return false;
    }
  }

  /// Проверить, существует ли продукт с таким баркодом
  bool barcodeExists(String barcode) {
    try {
      return products.any((product) => product.barcode == barcode);
    } catch (e) {
      Logger.e('Ошибка при проверке существования баркода: $e');
      return false;
    }
  }

  /// Получить продукты по баркоду (список, если один баркод связан с несколькими продуктами)
  List<FoodProduct> getProductListByBarcode(String barcode) {
    try {
      return products.where((product) => product.barcode == barcode).toList();
    } catch (e) {
      Logger.e('Ошибка при поиске продуктов по баркоду: $e');
      return [];
    }
  }

  /// Получить количество продуктов
  int getProductCount() {
    try {
      return products.length;
    } catch (e) {
      Logger.e('Ошибка при получении количества продуктов: $e');
      return 0;
    }
  }

  /// Очистить все данные
  void clearAll() {
    try {
      products.clear();
      HiveData.saveListJson(json: [], key: HiveDataKey.foodProducts);
    } catch (e) {
      Logger.e('Ошибка при очистке данных: $e');
    }
  }
}
