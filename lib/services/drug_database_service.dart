import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:tochka_balansa/data/models/drug/drug.dart';
import 'package:tochka_balansa/data/datasources/hive_data.dart';
import 'package:uuid/uuid.dart';

class DrugDatabaseService {
  static const String drugsKey = 'drugs';
  static final Uuid _uuid = Uuid();

  // Получить все лекарства
  static Future<List<Drug>> getAllDrugs() async {
    try {
      final data = await HiveData.loadListJson(
        key: HiveDataKey.scannedProducts,
      );
      if (data.isNotEmpty && !data.first.containsKey('error')) {
        return data.map((drugJson) {
          return Drug.fromJson(Map<String, dynamic>.from(drugJson));
        }).toList();
      }
      return [];
    } catch (e) {
      Logger.e('Ошибка при загрузке лекарств: $e');
      return [];
    }
  }

  // Найти лекарство по штрих-коду
  static Future<Drug?> findDrugByBarcode(String barcode) async {
    try {
      final drugs = await getAllDrugs();
      return drugs.where((drug) => drug.barcode == barcode).firstOrNull;
    } catch (e) {
      Logger.e('Ошибка при поиске лекарства: $e');
      return null;
    }
  }

  // Добавить новое лекарство
  static Future<bool> addDrug(Drug drug) async {
    try {
      final drugs = await getAllDrugs();
      drugs.add(drug);

      final jsonList = drugs.map((drug) => drug.toJson()).toList();
      await HiveData.saveListJson(
        json: jsonList,
        key: HiveDataKey.scannedProducts,
      );

      Logger.i('Лекарство добавлено: ${drug.name}');
      return true;
    } catch (e) {
      Logger.e('Ошибка при добавлении лекарства: $e');
      return false;
    }
  }

  // Обновить лекарство
  static Future<bool> updateDrug(Drug updatedDrug) async {
    try {
      final drugs = await getAllDrugs();
      final index = drugs.indexWhere((drug) => drug.id == updatedDrug.id);

      if (index != -1) {
        drugs[index] = updatedDrug.copyWith(updatedAt: DateTime.now());

        final jsonList = drugs.map((drug) => drug.toJson()).toList();
        await HiveData.saveListJson(
          json: jsonList,
          key: HiveDataKey.scannedProducts,
        );

        Logger.i('Лекарство обновлено: ${updatedDrug.name}');
        return true;
      }
      return false;
    } catch (e) {
      Logger.e('Ошибка при обновлении лекарства: $e');
      return false;
    }
  }

  // Удалить лекарство
  static Future<bool> deleteDrug(String drugId) async {
    try {
      final drugs = await getAllDrugs();
      drugs.removeWhere((drug) => drug.id == drugId);

      final jsonList = drugs.map((drug) => drug.toJson()).toList();
      await HiveData.saveListJson(
        json: jsonList,
        key: HiveDataKey.scannedProducts,
      );

      Logger.i('Лекарство удалено');
      return true;
    } catch (e) {
      Logger.e('Ошибка при удалении лекарства: $e');
      return false;
    }
  }

  // Создать новое лекарство
  static Drug createDrug({
    required String barcode,
    required String name,
    String? description,
    required int totalQuantity,
    required String quantityUnit,
  }) {
    return Drug(
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
