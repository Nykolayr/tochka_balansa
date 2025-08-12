import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:tochka_balansa/data/models/health/daily_calories_record.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart';
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
  static const String _foodProductsKey = 'food_products';
  List<DailyCaloriesRecord> _records = [];
  List<FoodProduct> _foodProducts = []; // НОВОЕ: список продуктов

  /// Получить все записи
  List<DailyCaloriesRecord> get records => List.unmodifiable(_records);

  /// Получить все продукты
  List<FoodProduct> get foodProducts => List.unmodifiable(_foodProducts);

  /// Получить продукты по типу приема пищи
  List<FoodProduct> getProductsByMealType(String mealType) {
    return _foodProducts
        .where((product) => product.mealType == mealType)
        .toList();
  }

  /// Получить продукты по типу приема пищи с фильтрацией
  List<FoodProduct> getFilteredProducts(String mealType, String searchQuery) {
    final products = getProductsByMealType(mealType);
    if (searchQuery.isEmpty) return products;

    return products
        .where(
          (product) =>
              product.name.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
  }

  /// Добавить продукт
  Future<void> addFoodProduct(FoodProduct product) async {
    _foodProducts.add(product);
    await _saveFoodProductsToLocal();

    // Обновляем калории в дневной записи
    await _updateDailyCalories();
  }

  /// Удалить продукт
  Future<void> removeFoodProduct(String productId) async {
    _foodProducts.removeWhere((product) => product.id == productId);
    await _saveFoodProductsToLocal();

    // Обновляем калории в дневной записи
    await _updateDailyCalories();
  }

  /// Обновить калории в дневной записи
  Future<void> _updateDailyCalories() async {
    final todayRecord = await getOrCreateTodayRecord();
    final todayProducts = _foodProducts.where((product) {
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final productDate = DateTime(
        product.timestamp.year,
        product.timestamp.month,
        product.timestamp.day,
      );
      return productDate.isAtSameMomentAs(todayDate);
    }).toList();

    final totalConsumedCalories = todayProducts.fold<int>(
      0,
      (sum, product) => sum + product.totalCalories,
    );

    final updatedRecord = todayRecord.copyWith(
      consumedCalories: totalConsumedCalories,
      updatedAt: DateTime.now(),
    );

    // Обновляем запись в списке
    final index = _records.indexWhere((r) => r.id == todayRecord.id);
    if (index != -1) {
      _records[index] = updatedRecord;
      await _saveToLocal();
    }
  }

  /// Инициализация - загрузка из локального хранилища
  Future<void> init() async {
    await _loadFromLocal();
    await _loadFoodProductsFromLocal();
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
      // Если записи нет, создаем новую с РАССЧИТАННЫМИ калориями
      final bmr = CaloriesCalculatorService.calculateBMR(
        age: user.age,
        gender: user.gender.name,
        weight: user.initialWeight,
        height: user.height,
      );

      // Рассчитываем общий расход с учетом активности (БЕЗ физупражнений)
      final totalCalories = CaloriesCalculatorService.calculateTotalCalories(
        bmr: bmr,
        activityLevel: user.activityLevel,
      );

      Logger.i(
        'Создаем запись на сегодня: BMR=$bmr, активность=${user.activityLevel.title}, итого=$totalCalories',
      );

      // Проверяем, что калории не отрицательные
      if (totalCalories <= 0) {
        Logger.e('ОШИБКА: Рассчитанные калории <= 0: $totalCalories');
        Logger.e(
          'Данные пользователя: возраст=${user.age}, пол=${user.gender.name}, вес=${user.initialWeight}, рост=${user.height}',
        );
      }

      todayRecord = DailyCaloriesRecord.create(
        date: todayDate,
        burnedCalories: totalCalories > 0
            ? totalCalories
            : 1500, // Защита от отрицательных значений
        gender: user.gender.name, // НОВОЕ: передаем пол
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

  /// Добавить калории к сожженным (например, от шагов)
  Future<void> addBurnedCalories(int calories) async {
    final todayRecord = await getOrCreateTodayRecord();
    final updatedRecord = todayRecord.addBurnedCalories(calories);

    // Обновляем запись в списке
    final index = _records.indexWhere((r) => r.id == todayRecord.id);
    if (index != -1) {
      _records[index] = updatedRecord;
      await _saveToLocal();
    }
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

  /// Загрузить продукты из локального хранилища
  Future<void> _loadFoodProductsFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = prefs.getStringList(_foodProductsKey) ?? [];

      _foodProducts = productsJson
          .map((json) => FoodProduct.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      _foodProducts = [];
    }
  }

  /// Сохранить продукты в локальное хранилище
  Future<void> _saveFoodProductsToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = _foodProducts
          .map((product) => jsonEncode(product.toJson()))
          .toList();

      await prefs.setStringList(_foodProductsKey, productsJson);
    } catch (e) {
      Logger.e('Ошибка сохранения продуктов: $e');
    }
  }

  /// Очистить все записи (для тестирования)
  Future<void> clearAll() async {
    _records.clear();
    await _saveToLocal();
  }
}
