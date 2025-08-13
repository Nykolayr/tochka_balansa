import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FoodApiService {
  static const String _baseUrl = 'https://world.openfoodfacts.org';

  /// Поиск продуктов по названию
  static Future<List<FoodApiProduct>> searchProducts(String query) async {
    try {
      Logger.d('Ищем продукты: $query');

      final url = Uri.parse(
        '$_baseUrl/cgi/search.pl?search_terms=$query&search_simple=1&action=process&json=1&page_size=10',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = data['products'] as List?;

        if (products != null) {
          return products
              .map((product) => FoodApiProduct.fromJson(product))
              .where((product) => product.name.isNotEmpty)
              .take(10)
              .toList();
        }
      }

      return [];
    } catch (e) {
      Logger.e('Ошибка поиска продуктов: $e');
      return [];
    }
  }

  /// Получить продукт по штрих-коду
  static Future<FoodApiProduct?> getProductByBarcode(String barcode) async {
    try {
      Logger.d('Ищем продукт по штрих-коду: $barcode');

      final url = Uri.parse('$_baseUrl/api/v0/product/$barcode.json');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 1 && data['product'] != null) {
          return FoodApiProduct.fromJson(data['product']);
        }
      }

      return null;
    } catch (e) {
      Logger.e('Ошибка поиска по штрих-коду: $e');
      return null;
    }
  }
}

/// Модель продукта из API
class FoodApiProduct {
  final String name;
  final String? brand;
  final String? barcode;
  final double? caloriesPer100g;
  final double? proteinsPer100g;
  final double? fatsPer100g;
  final double? carbsPer100g;
  final String? imageUrl;

  const FoodApiProduct({
    required this.name,
    this.brand,
    this.barcode,
    this.caloriesPer100g,
    this.proteinsPer100g,
    this.fatsPer100g,
    this.carbsPer100g,
    this.imageUrl,
  });

  factory FoodApiProduct.fromJson(Map<String, dynamic> json) {
    return FoodApiProduct(
      name: json['product_name'] ?? json['generic_name'] ?? '',
      brand: json['brands'],
      barcode: json['code'],
      caloriesPer100g: _parseNutrient(json['nutriments']?['energy-kcal_100g']),
      proteinsPer100g: _parseNutrient(json['nutriments']?['proteins_100g']),
      fatsPer100g: _parseNutrient(json['nutriments']?['fat_100g']),
      carbsPer100g: _parseNutrient(json['nutriments']?['carbohydrates_100g']),
      imageUrl: json['image_url'],
    );
  }

  static double? _parseNutrient(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed;
    }
    return null;
  }

  /// Получить отображаемое название
  String get displayName {
    if (brand != null && brand!.isNotEmpty) {
      return '$brand $name';
    }
    return name;
  }

  /// Получить калории (по умолчанию 0 если нет данных)
  int get calories => caloriesPer100g?.round() ?? 0;
}
