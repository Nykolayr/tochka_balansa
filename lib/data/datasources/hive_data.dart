import 'dart:convert';
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

  static Future<void> saveJson({
    required Map<String, dynamic> json,
    required HiveDataKey key,
  }) async {
    await _box.put(key.name, jsonEncode(json));
  }

  static Future<Map<String, dynamic>> loadJson({
    required HiveDataKey key,
  }) async {
    final String? data = _box.get(key.name);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    } else {
      Logger.e('нет данных для ${key.name}');
      return {'error': 'нет данных для ${key.name}'};
    }
  }

  static Future<void> saveListJson({
    required List<Map<String, dynamic>> json,
    required HiveDataKey key,
  }) async {
    final List<String> list = json.map((e) => jsonEncode(e)).toList();
    await _box.put(key.name, list);
  }

  static Future<List<Map<String, dynamic>>> loadListJson({
    required HiveDataKey key,
  }) async {
    final List<String>? list = _box.get(key.name);
    if (list != null) {
      return list.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
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
    final List<String>? list = _box.get(key.name);
    if (list != null) {
      return list;
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
    final List<int>? list = _box.get(key.name);
    if (list != null) {
      return list;
    } else {
      Logger.e('нет данных для ${key.name}');
      return [];
    }
  }
}

enum HiveDataKey { user }
