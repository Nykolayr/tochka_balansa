import 'dart:convert';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

///сохранение и загрузка в shared_preferences
class LocalData {
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> saveBool({
    required bool bool,
    required LocalDataKey key,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key.name, bool);
  }

  static Future<bool> loadBool({required LocalDataKey key}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key.name) ?? false;
  }

  static Future<void> saveString({
    required String string,
    required LocalDataKey key,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key.name, string);
  }

  static Future<String> loadString({required LocalDataKey key}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key.name) ?? '';
  }

  static Future<void> saveJson({
    required Map<String, dynamic> json,
    required LocalDataKey key,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key.name, jsonEncode(json));
  }

  static Future<Map<String, dynamic>> loadJson({
    required LocalDataKey key,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(key.name);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    } else {
      Logger.e('нет данных для ${key.name}');
      return {'error': 'нет данных для ${key.name}'};
    }
  }

  static Future<void> saveListJson({
    required List<Map<String, dynamic>> json,
    required LocalDataKey key,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> list = json.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList(key.name, list);
  }

  static Future<List<Map<String, dynamic>>> loadListJson({
    required LocalDataKey key,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? list = prefs.getStringList(key.name);
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
    required LocalDataKey key,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key.name, list);
  }

  static Future<List<String>> loadList({required LocalDataKey key}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? list = prefs.getStringList(key.name);
    if (list != null) {
      return list;
    } else {
      Logger.e('нет данных для ${key.name}');
      return [];
    }
  }

  static Future<void> saveListInt({
    required List<int> list,
    required LocalDataKey key,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key.name, list.map((e) => e.toString()).toList());
  }

  static Future<List<int>> loadListInt({required LocalDataKey key}) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? list = prefs.getStringList(key.name);
    if (list != null) {
      return list.map((e) => int.parse(e)).toList();
    } else {
      Logger.e('нет данных для ${key.name}');
      return [];
    }
  }
}

enum LocalDataKey { user }
