import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:tochka_balansa/data/datasources/hive_data.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';

class HealthRepository {
  HealthData healthData = HealthData.initial();

  static final HealthRepository _instance = HealthRepository._internal();

  HealthRepository._internal();

  factory HealthRepository() => _instance;

  /// Загрузка данных о здоровье из локального хранилища
  Future<void> loadHealthDataFromLocal() async {
    try {
      final data = await HiveData.loadJson(key: HiveDataKey.healthData);
      // Проверяем, что в данных нет ошибки
      if (!data.containsKey('error')) {
        // Конвертируем Map<dynamic, dynamic> в Map<String, dynamic>
        final convertedData = Map<String, dynamic>.from(data);
        healthData = HealthData.fromJson(convertedData);
      }
    } catch (e) {
      Logger.e('Error loading health data: $e');
      healthData = HealthData.initial();
    }
  }

  /// Сохранение данных о здоровье в локальное хранилище
  Future<void> saveHealthDataToLocal() async {
    try {
      await HiveData.saveJson(
        json: healthData.toJson(),
        key: HiveDataKey.healthData,
      );
    } catch (e) {
      Logger.e('Error saving health data: $e');
    }
  }
}
