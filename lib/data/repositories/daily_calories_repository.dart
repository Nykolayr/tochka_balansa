import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:tochka_balansa/data/datasources/hive_data.dart';
import 'package:tochka_balansa/data/models/health/daily_calories_record.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart';
import 'package:tochka_balansa/data/services/calories_calculator_service.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';
import 'package:get/get.dart';

/// Репозиторий для управления дневными записями калорий
class DailyCaloriesRepository {
  static final DailyCaloriesRepository _instance =
      DailyCaloriesRepository._internal();
  factory DailyCaloriesRepository() => _instance;
  DailyCaloriesRepository._internal();

  /// дата отображаемая в UI
  DateTime _currentDate = DateTime.now();
  DateTime get currentDate => _currentDate;
  set currentDate(DateTime date) {
    _currentDate = date;
  }

  /// Списки продуктов и записей
  List<DailyCaloriesRecord> records = [];
  List<FoodProduct> foodProducts = [];

  /// Добавить продукт
  Future<void> addFoodProduct(FoodProduct product) async {
    foodProducts.add(product);
    await saveFoodProductsToLocal();

    // Обновляем калории в дневной записи
    await updateDailyCalories();
  }

  /// Удалить продукт
  Future<void> removeFoodProduct(String productId) async {
    foodProducts.removeWhere((product) => product.id == productId);
    await saveFoodProductsToLocal();

    // Обновляем калории в дневной записи
    await updateDailyCalories();
  }

  /// Обновить калории в дневной записи
  Future<void> updateDailyCalories() async {
    // ИСПРАВЛЕНО: проверяем данные пользователя ПЕРЕД обновлением
    final userRepository = Get.find<UserRepository>();
    final user = userRepository.user;

    if (user.initialWeight <= 0 || user.height <= 0) {
      Logger.i('Пользователь не ввел данные, пропускаем обновление калорий');
      return; // НЕ обновляем если данных нет
    }

    final todayRecord = await getOrCreateTodayRecord();

    // Считаем калории от продуктов
    final todayProducts = foodProducts.where((product) {
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

    // Обновляем запись
    final updatedRecord = todayRecord.copyWith(
      consumedCalories: totalConsumedCalories,
      updatedAt: DateTime.now(),
    );

    // Обновляем запись в списке
    final index = records.indexWhere((r) => r.id == todayRecord.id);
    if (index != -1) {
      records[index] = updatedRecord;
      await saveToLocal();
    }
  }

  /// Инициализация - загрузка из локального хранилища
  Future<void> init() async {
    await loadFromLocal();
    await _loadFoodProductsFromLocal();
  }

  /// Получить или создать запись на сегодня
  Future<DailyCaloriesRecord> getOrCreateTodayRecord() async {
    final userRepository = Get.find<UserRepository>();
    final user = userRepository.user;

    // ИСПРАВЛЕНО: проверяем данные пользователя ДО всего остального
    if (user.initialWeight <= 0 || user.height <= 0) {
      Logger.i(
        'Пользователь не ввел данные (вес=${user.initialWeight}, рост=${user.height}), запись НЕ создается',
      );

      // Возвращаем базовую запись с минимальными значениями
      return DailyCaloriesRecord.create(
        date: DateTime.now(),
        burnedCalories: 2000, // Базовое значение
        gender: user.gender.name,
      );
    }

    // Получаем сегодняшнюю дату (без времени)
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Проверяем, есть ли уже запись на сегодня
    final todayRecord = await getTodayRecord(todayDate);

    if (todayRecord.consumedCalories == 0) {
      // ТОЛЬКО если данные валидны - создаем запись с расчетом
      Logger.i('Данные пользователя валидны, рассчитываем калории');

      final bmr = CaloriesCalculatorService.calculateBMR(
        age: user.age,
        gender: user.gender.name,
        weight: user.initialWeight,
        height: user.height,
      );

      final totalCalories = CaloriesCalculatorService.calculateTotalCalories(
        bmr: bmr,
        activityLevel: user.activityLevel,
      );

      Logger.i(
        'Создаем запись на сегодня: BMR=$bmr, активность=${user.activityLevel.title}, итого=$totalCalories',
      );

      final newRecord = DailyCaloriesRecord.create(
        date: todayDate,
        burnedCalories: totalCalories,
        gender: user.gender.name,
      );

      records.add(newRecord);
      await saveToLocal();
    }

    return todayRecord;
  }

  /// Получить запись на конкретную дату
  Future<DailyCaloriesRecord> getTodayRecord(DateTime? date) async {
    try {
      if (date == null) {
        return getOrCreateTodayRecord();
      }
      return records.firstWhere((record) {
        final recordDate = DateTime(
          record.date.year,
          record.date.month,
          record.date.day,
        );
        return recordDate.isAtSameMomentAs(date);
      });
    } catch (e) {
      Logger.e(
        'Ошибка получения записи на дату ${currentDate.toIso8601String()}: $e',
      );
      return getOrCreateTodayRecord();
    }
  }

  /// Добавить калории к съеденным на сегодня
  Future<DailyCaloriesRecord> addConsumedCalories(int calories) async {
    final todayRecord = await getOrCreateTodayRecord();
    final updatedRecord = todayRecord.addConsumedCalories(calories);

    // Обновляем запись в списке
    final index = records.indexWhere((r) => r.id == todayRecord.id);
    if (index != -1) {
      records[index] = updatedRecord;
      await saveToLocal();
    }

    return updatedRecord;
  }

  /// Добавить калории к сожженным (например, от шагов)
  Future<DailyCaloriesRecord> addBurnedCalories(int calories) async {
    final todayRecord = await getOrCreateTodayRecord();
    final updatedRecord = todayRecord.addBurnedCalories(calories);

    // Обновляем запись в списке
    final index = records.indexWhere((r) => r.id == todayRecord.id);
    if (index != -1) {
      records[index] = updatedRecord;
      await saveToLocal();
    }

    return updatedRecord;
  }

  /// Загрузить записи из локального хранилища
  Future<void> loadFromLocal() async {
    try {
      final recordsJson = await HiveData.loadListJson(
        key: HiveDataKey.dailyCaloriesRecords,
      );
      records = recordsJson
          .map((json) => DailyCaloriesRecord.fromJson(json))
          .toList();
    } catch (e) {
      Logger.e('Ошибка загрузки записей: $e');
      records = [];
    }
  }

  /// Сохранить записи в локальное хранилище
  Future<void> saveToLocal() async {
    try {
      await HiveData.saveListJson(
        key: HiveDataKey.dailyCaloriesRecords,
        json: records.map((record) => record.toJson()).toList(),
      );
    } catch (e) {
      Logger.e('Ошибка сохранения записей: $e');
    }
  }

  /// Загрузить продукты из локального хранилища
  Future<void> _loadFoodProductsFromLocal() async {
    try {
      final productsJson = await HiveData.loadListJson(
        key: HiveDataKey.foodProducts,
      );

      foodProducts = productsJson
          .map((json) => FoodProduct.fromJson(json))
          .toList();
    } catch (e) {
      Logger.e('Ошибка загрузки продуктов: $e');
      foodProducts = [];
    }
  }

  /// Сохранить продукты в локальное хранилище
  Future<void> saveFoodProductsToLocal() async {
    try {
      await HiveData.saveListJson(
        key: HiveDataKey.foodProducts,
        json: foodProducts.map((product) => product.toJson()).toList(),
      );
    } catch (e) {
      Logger.e('Ошибка сохранения продуктов: $e');
    }
  }

  /// Очистить все записи (для тестирования)
  Future<void> clearAll() async {
    records.clear();
    foodProducts.clear();
    await saveToLocal();
  }

  /// Переключить избранное продукта
  Future<void> toggleProductFavorite(String productId) async {
    final index = foodProducts.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final product = foodProducts[index];
      final updatedProduct = product.toggleFavorite();

      foodProducts[index] = updatedProduct;
      await saveFoodProductsToLocal();
    }
  }
}
