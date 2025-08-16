import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:hive/hive.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart';

class LocalProductRepository {
  static const String _boxName = 'local_products';
  late Box<FoodProduct> _box;

  /// Инициализация репозитория
  Future<void> init() async {
    _box = await Hive.openBox<FoodProduct>(_boxName);
  }

  /// Получить продукт по баркоду
  Future<FoodProduct?> getProductByBarcode(String barcode) async {
    try {
      final products = _box.values.where(
        (product) => product.barcode == barcode,
      );
      return products.isNotEmpty ? products.first : null;
    } catch (e) {
      Logger.e('Ошибка при поиске продукта по баркоду: $e');
      return null;
    }
  }

  /// Сохранить продукт
  Future<void> saveProduct(FoodProduct product) async {
    try {
      await _box.add(product);
    } catch (e) {
      Logger.e('Ошибка при сохранении продукта: $e');
      rethrow;
    }
  }

  /// Обновить продукт
  Future<void> updateProduct(FoodProduct product) async {
    try {
      final index = _box.values.toList().indexWhere((p) => p.id == product.id);
      if (index != -1) {
        await _box.putAt(index, product);
      }
    } catch (e) {
      Logger.e('Ошибка при обновлении продукта: $e');
      rethrow;
    }
  }

  /// Удалить продукт
  Future<void> deleteProduct(String id) async {
    try {
      final index = _box.values.toList().indexWhere((p) => p.id == id);
      if (index != -1) {
        await _box.deleteAt(index);
      }
    } catch (e) {
      Logger.e('Ошибка при удалении продукта: $e');
      rethrow;
    }
  }

  /// Получить все локальные продукты
  List<FoodProduct> getAllProducts() {
    try {
      return _box.values.toList();
    } catch (e) {
      Logger.e('Ошибка при получении всех продуктов: $e');
      return [];
    }
  }

  /// Поиск продуктов по названию
  List<FoodProduct> searchProducts(String query) {
    try {
      final lowercaseQuery = query.toLowerCase();
      return _box.values
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
  List<FoodProduct> getFavoriteProducts() {
    try {
      return _box.values.where((product) => product.isFavorite).toList();
    } catch (e) {
      Logger.e('Ошибка при получении избранных продуктов: $e');
      return [];
    }
  }

  /// Очистить все данные
  Future<void> clearAll() async {
    try {
      await _box.clear();
    } catch (e) {
      Logger.e('Ошибка при очистке данных: $e');
      rethrow;
    }
  }

  /// Закрыть репозиторий
  Future<void> close() async {
    try {
      await _box.close();
    } catch (e) {
      Logger.e('Ошибка при закрытии репозитория: $e');
    }
  }
}
