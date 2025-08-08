import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:tochka_balansa/data/models/product/scanned_product.dart';
import 'package:tochka_balansa/data/datasources/hive_data.dart';
import 'package:uuid/uuid.dart';

class ProductDatabaseService {
  static const String productsKey = 'scanned_products';
  static final Uuid _uuid = Uuid();

  // Получить все продукты
  static Future<List<ScannedProduct>> getAllProducts() async {
    try {
      final data = await HiveData.loadListJson(
        key: HiveDataKey.scannedProducts,
      );
      if (data.isNotEmpty && !data.first.containsKey('error')) {
        return data.map((productJson) {
          return ScannedProduct.fromJson(
            Map<String, dynamic>.from(productJson),
          );
        }).toList();
      }
      return [];
    } catch (e) {
      Logger.e('Ошибка при загрузке продуктов: $e');
      return [];
    }
  }

  // Найти продукт по штрих-коду
  static Future<ScannedProduct?> findProductByBarcode(String barcode) async {
    try {
      final products = await getAllProducts();
      return products
          .where((product) => product.barcode == barcode)
          .firstOrNull;
    } catch (e) {
      Logger.e('Ошибка при поиске продукта: $e');
      return null;
    }
  }

  // Добавить новый продукт
  static Future<bool> addProduct(ScannedProduct product) async {
    try {
      final products = await getAllProducts();
      products.add(product);

      final jsonList = products.map((product) => product.toJson()).toList();
      await HiveData.saveListJson(
        json: jsonList,
        key: HiveDataKey.scannedProducts,
      );

      Logger.i('Продукт добавлен: ${product.name}');
      return true;
    } catch (e) {
      Logger.e('Ошибка при добавлении продукта: $e');
      return false;
    }
  }

  // Обновить продукт
  static Future<bool> updateProduct(ScannedProduct updatedProduct) async {
    try {
      final products = await getAllProducts();
      final index = products.indexWhere(
        (product) => product.id == updatedProduct.id,
      );

      if (index != -1) {
        products[index] = updatedProduct.copyWith(updatedAt: DateTime.now());

        final jsonList = products.map((product) => product.toJson()).toList();
        await HiveData.saveListJson(
          json: jsonList,
          key: HiveDataKey.scannedProducts,
        );

        Logger.i('Продукт обновлен: ${updatedProduct.name}');
        return true;
      }
      return false;
    } catch (e) {
      Logger.e('Ошибка при обновлении продукта: $e');
      return false;
    }
  }

  // Удалить продукт
  static Future<bool> deleteProduct(String productId) async {
    try {
      final products = await getAllProducts();
      products.removeWhere((product) => product.id == productId);

      final jsonList = products.map((product) => product.toJson()).toList();
      await HiveData.saveListJson(
        json: jsonList,
        key: HiveDataKey.scannedProducts,
      );

      Logger.i('Продукт удален');
      return true;
    } catch (e) {
      Logger.e('Ошибка при удалении продукта: $e');
      return false;
    }
  }

  // Создать новый продукт
  static ScannedProduct createProduct({
    required String barcode,
    required String name,
    String? description,
    required int totalQuantity,
    required String quantityUnit,
  }) {
    return ScannedProduct(
      id: _uuid.v4(),
      barcode: barcode,
      name: name,
      description: description,
      totalQuantity: totalQuantity,
      quantityUnit: quantityUnit,
      createdAt: DateTime.now(),
    );
  }
}
