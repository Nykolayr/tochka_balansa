import 'package:tochka_balansa/data/models/health/daily_calories_record.dart';
import 'package:tochka_balansa/data/services/calories_calculator_service.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Репозиторий для управления дневными записями калорий
class DailyCaloriesRepository {
  static final DailyCaloriesRepository _instance =
      DailyCaloriesRepository._internal();
  factory DailyCaloriesRepository() => _instance;
  DailyCaloriesRepository._internal();

  static const String _storageKey = 'daily_calories_records';
  List<DailyCaloriesRecord> _records = [];

  /// Получить все записи
  List<DailyCaloriesRecord> get records => List.unmodifiable(_records);

  /// Инициализация - загрузка из локального хранилища
  Future<void> init() async {
    await _loadFromLocal();
  }

  /// Получить или создать запись на сегодня
  Future<DailyCaloriesRecord> getOrCreateTodayRecord() async {
    final userRepository = Get.find<UserRepository>();
    final user = userRepository.user;

    // Получаем сегодняшнюю дату (без времени)
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Проверяем, есть ли уже запись на сегодня
    DailyCaloriesRecord? todayRecord = _getTodayRecord(todayDate);

    if (todayRecord == null) {
      // Если записи нет, создаем новую
      final bmr = CaloriesCalculatorService.calculateBMR(
        age: user.age,
        gender: user.gender.name,
        weight: user.initialWeight,
        height: user.height,
      );

      // Рассчитываем общий расход с учетом активности
      final totalCalories = CaloriesCalculatorService.calculateTotalCalories(
        bmr: bmr,
        activityLevel: user.activityLevel,
      );

      todayRecord = DailyCaloriesRecord.create(
        date: todayDate,
        burnedCalories: totalCalories,
      );

      // Добавляем запись в список и сохраняем
      _records.add(todayRecord);
      await _saveToLocal();
    }

    return todayRecord;
  }

  /// Получить запись на конкретную дату
  DailyCaloriesRecord? _getTodayRecord(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);

    try {
      return _records.firstWhere((record) {
        final recordDate = DateTime(
          record.date.year,
          record.date.month,
          record.date.day,
        );
        return recordDate.isAtSameMomentAs(targetDate);
      });
    } catch (e) {
      return null; // Запись не найдена
    }
  }

  /// Добавить калории к съеденным на сегодня
  Future<DailyCaloriesRecord> addConsumedCalories(int calories) async {
    final todayRecord = await getOrCreateTodayRecord();
    final updatedRecord = todayRecord.addConsumedCalories(calories);

    // Обновляем запись в списке
    final index = _records.indexWhere((r) => r.id == todayRecord.id);
    if (index != -1) {
      _records[index] = updatedRecord;
      await _saveToLocal();
    }

    return updatedRecord;
  }

  /// Добавить калории к сожженным на сегодня
  Future<DailyCaloriesRecord> addBurnedCalories(int calories) async {
    final todayRecord = await getOrCreateTodayRecord();
    final updatedRecord = todayRecord.addBurnedCalories(calories);

    // Обновляем запись в списке
    final index = _records.indexWhere((r) => r.id == todayRecord.id);
    if (index != -1) {
      _records[index] = updatedRecord;
      await _saveToLocal();
    }

    return updatedRecord;
  }

  /// Загрузить записи из локального хранилища
  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = prefs.getStringList(_storageKey) ?? [];

      _records = recordsJson
          .map((json) => DailyCaloriesRecord.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      _records = [];
    }
  }

  /// Сохранить записи в локальное хранилище
  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = _records
          .map((record) => jsonEncode(record.toJson()))
          .toList();

      await prefs.setStringList(_storageKey, recordsJson);
    } catch (e) {
      // Обработка ошибки сохранения
    }
  }

  /// Очистить все записи (для тестирования)
  Future<void> clearAll() async {
    _records.clear();
    await _saveToLocal();
  }
}
