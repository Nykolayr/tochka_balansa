import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:hive_flutter/hive_flutter.dart';

///сохранение и загрузка в Hive
class HiveData {
  static late Box _box;

  /// Инициализация Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('app_data');
  }

  static Future<void> clear() async {
    await _box.clear();
  }

  static Future<void> saveBool({
    required bool bool,
    required HiveDataKey key,
  }) async {
    await _box.put(key.name, bool);
  }

  static Future<bool> loadBool({required HiveDataKey key}) async {
    return _box.get(key.name, defaultValue: false);
  }

  static Future<void> saveString({
    required String string,
    required HiveDataKey key,
  }) async {
    await _box.put(key.name, string);
  }

  static Future<String> loadString({required HiveDataKey key}) async {
    return _box.get(key.name, defaultValue: '');
  }

  /// Сохранение JSON напрямую (Hive автоматически сериализует Map)
  static Future<void> saveJson({
    required Map<String, dynamic> json,
    required HiveDataKey key,
  }) async {
    await _box.put(key.name, json);
  }

  /// Загрузка JSON напрямую (Hive автоматически десериализует в Map)
  static Future<Map<String, dynamic>> loadJson({
    required HiveDataKey key,
  }) async {
    final data = _box.get(key.name);
    if (data != null) {
      // Безопасное приведение типов для Hive
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      } else {
        Logger.e('неверный тип данных для ${key.name}');
        return {'error': 'неверный тип данных для ${key.name}'};
      }
    } else {
      Logger.e('нет данных для ${key.name}');
      return {'error': 'нет данных для ${key.name}'};
    }
  }

  /// Синхронная загрузка JSON (для textLang)
  static Map<String, dynamic>? loadJsonSync({required HiveDataKey key}) {
    final data = _box.get(key.name);
    if (data != null && data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  /// Сохранение списка JSON напрямую
  static Future<void> saveListJson({
    required List<Map<String, dynamic>> json,
    required HiveDataKey key,
  }) async {
    await _box.put(key.name, json);
  }

  /// Загрузка списка JSON напрямую
  static Future<List<Map<String, dynamic>>> loadListJson({
    required HiveDataKey key,
  }) async {
    final list = _box.get(key.name);
    if (list != null && list is List) {
      return list.map((item) {
        if (item is Map) {
          return Map<String, dynamic>.from(item);
        } else {
          return <String, dynamic>{};
        }
      }).toList();
    } else {
      Logger.e('нет данных для ${key.name}');
      return [
        {'error': 'нет данных для ${key.name}'},
      ];
    }
  }

  static Future<void> saveList({
    required List<String> list,
    required HiveDataKey key,
  }) async {
    await _box.put(key.name, list);
  }

  static Future<List<String>> loadList({required HiveDataKey key}) async {
    final list = _box.get(key.name);
    if (list != null) {
      return (list as List).cast<String>();
    } else {
      Logger.e('нет данных для ${key.name}');
      return [];
    }
  }

  static Future<void> saveListInt({
    required List<int> list,
    required HiveDataKey key,
  }) async {
    await _box.put(key.name, list);
  }

  static Future<List<int>> loadListInt({required HiveDataKey key}) async {
    final list = _box.get(key.name);
    if (list != null) {
      return (list as List).cast<int>();
    } else {
      Logger.e('нет данных для ${key.name}');
      return [];
    }
  }
}

enum HiveDataKey {
  user,
  language,
  goalTypes,
  archivedGoals,
  scannedProducts, // Переименовали с drugs на scannedProducts
  healthData, // Добавляем ключ для данных о здоровье
  foodProducts, // Ключ для продуктов местной базы
}
