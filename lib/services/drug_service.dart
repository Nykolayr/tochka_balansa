import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_easylogger/flutter_logger.dart';

class DrugService {
  // Пробуем несколько разных API
  
  static Future<Map<String, dynamic>?> getDrugInfoByBarcode(String barcode) async {
    try {
      Logger.d('Ищем товар по штрих-коду: $barcode');
      
      // Пробуем первый API - UPC Item Database
      var result = await _tryUpcApi(barcode);
      if (result != null) return result;
      
      // Пробуем второй API - Barcode Lookup
      result = await _tryBarcodeLookupApi(barcode);
      if (result != null) return result;
      
      // Пробуем третий API - Open Food Facts
      result = await _tryOpenFoodFactsApi(barcode);
      if (result != null) return result;
      
      Logger.d('Товар не найден ни в одном API');
      return null;
      
    } catch (e) {
      Logger.e('Ошибка при поиске товара: $e');
      return null;
    }
  }
  
  // UPC Item Database API
  static Future<Map<String, dynamic>?> _tryUpcApi(String barcode) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.upcitemdb.com/prod/trial/lookup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'upc': barcode}),
      );
      
      Logger.d('UPC API статус: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          final item = data['items'][0];
          return {
            'name': item['title'] ?? 'Неизвестно',
            'brand': item['brand'] ?? '',
            'category': item['category'] ?? '',
            'source': 'UPC Database',
          };
        }
      }
      return null;
    } catch (e) {
      Logger.e('Ошибка UPC API: $e');
      return null;
    }
  }
  
  // Barcode Lookup API
  static Future<Map<String, dynamic>?> _tryBarcodeLookupApi(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.barcodelookup.com/v3/products?barcode=$barcode&formatted=y&key=demo'),
      );
      
      Logger.d('Barcode Lookup API статус: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['products'] != null && data['products'].isNotEmpty) {
          final product = data['products'][0];
          return {
            'name': product['title'] ?? 'Неизвестно',
            'brand': product['brand'] ?? '',
            'category': product['category'] ?? '',
            'source': 'Barcode Lookup',
          };
        }
      }
      return null;
    } catch (e) {
      Logger.e('Ошибка Barcode Lookup API: $e');
      return null;
    }
  }
  
  // Open Food Facts API (для продуктов питания и лекарств)
  static Future<Map<String, dynamic>?> _tryOpenFoodFactsApi(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json'),
      );
      
      Logger.d('Open Food Facts API статус: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1 && data['product'] != null) {
          final product = data['product'];
          return {
            'name': product['product_name'] ?? product['generic_name'] ?? 'Неизвестно',
            'brand': product['brands'] ?? '',
            'category': product['categories'] ?? '',
            'source': 'Open Food Facts',
          };
        }
      }
      return null;
    } catch (e) {
      Logger.e('Ошибка Open Food Facts API: $e');
      return null;
    }
  }
  
  // Метод для поиска в локальной базе популярных лекарств (как fallback)
  static String? getDrugNameFromLocalDatabase(String gtin) {
    final Map<String, String> localDrugs = {
      '4673745876221': 'Парацетамол 500мг',
      '620153000094': 'Аспирин 500мг',
      '4607000000000': 'Ибупрофен 400мг',
      // Можно добавить больше кодов
    };
    
    return localDrugs[gtin];
  }
} 