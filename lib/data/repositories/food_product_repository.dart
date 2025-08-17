import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:tochka_balansa/data/datasources/hive_data.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart';

/// Репозиторий для работы с продуктами
class FoodProductRepository {
  static final FoodProductRepository _instance =
      FoodProductRepository._internal();
  factory FoodProductRepository() => _instance;
  FoodProductRepository._internal() {
    getProductsFromLocal();
  }

  final List<FoodProduct> products = [];

  List<FoodProduct> getFavoriteProducts() =>
      products.where((p) => p.isFavorite).toList();

  /// Возвращает список недавних продуктов (например, за последние 7 дней, максимум 20)
  List<FoodProduct> getRecentProducts() {
    final now = DateTime.now();
    // Считаем недавними продукты, добавленные/использованные за последние 7 дней
    final recent = products
        .where((p) => now.difference(p.timestamp).inDays <= 7)
        .toList();
    // Сортируем по дате использования (сначала самые новые)
    recent.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    // Ограничиваем, например, 20 продуктами
    return recent.toList();
  }

  /// Возвращает часто используемые продукты (по usageCount, максимум 20)
  List<FoodProduct> getFrequentProducts() {
    final frequent = products.where((p) => (p.usageCount) > 0).toList();
    // Сортируем по количеству использования (сначала самые частые)
    frequent.sort((a, b) => (b.usageCount).compareTo(a.usageCount));
    // Ограничиваем, например, 20 продуктами
    return frequent.toList();
  }

  /// Переключить избранное продукта
  Future<void> toggleProductFavorite(String productId) async {
    final index = products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final product = products[index];
      final updatedProduct = product.toggleFavorite();

      products[index] = updatedProduct;
      await saveProductsToLocal();
    }
  }

  /// сохраняем текущий список продуктов
  Future<void> saveProductsToLocal() async {
    try {
      await HiveData.saveListJson(
        key: HiveDataKey.foodProducts,
        json: products.map((record) => record.toJson()).toList(),
      );
    } catch (e) {
      Logger.e('Ошибка сохранения продуктов: $e');
    }
  }

  /// получаем список продуктов из локального хранилища
  Future<List<FoodProduct>> getProductsFromLocal() async {
    try {
      final json = await HiveData.loadListJson(key: HiveDataKey.foodProducts);
      return json.map((e) => FoodProduct.fromJson(e)).toList();
    } catch (e) {
      Logger.e('Ошибка получения продуктов: $e');
      return [];
    }
  }
}
