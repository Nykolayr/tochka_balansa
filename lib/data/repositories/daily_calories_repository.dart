import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:tochka_balansa/data/datasources/hive_data.dart';
import 'package:tochka_balansa/data/models/health/daily_calories_record.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart';
import 'package:tochka_balansa/data/services/calories_calculator_service.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/presentation/pages/food/enum_eat.dart';

/// Репозиторий для управления дневными записями калорий
class DailyCaloriesRepository {
  static final DailyCaloriesRepository _instance =
      DailyCaloriesRepository._internal();
  factory DailyCaloriesRepository() => _instance;

  DailyCaloriesRepository._internal() {
    // Убираем автоматическую загрузку из конструктора
    // Загрузка будет происходить только при явном вызове init()
  }

  /// Списки  записей
  List<DailyCaloriesRecord> records = [];

  /// дата отображаемая в UI
  DateTime currentDate = DateTime.now();

  /// устанавливаем дату
  void setCurrentDate(DateTime date) {
    currentDate = date;
  }

  /// взят запись по currentDate
  DailyCaloriesRecord getCurrentRecord() {
    return getTodayRecord(currentDate);
  }

  /// Добавить продукт
  Future<void> addFoodProduct(FoodProduct product, EatType type) async {
    var record = getTodayRecord(currentDate);

    // Создаем копию списков для обновления
    List<FoodProduct> breakfast = List.from(record.breakfast);
    List<FoodProduct> lunch = List.from(record.lunch);
    List<FoodProduct> dinner = List.from(record.dinner);
    List<FoodProduct> snacks = List.from(record.snacks);

    switch (type) {
      case EatType.breakfast:
        breakfast.insert(0, product); // Добавляем в начало списка
        break;
      case EatType.lunch:
        lunch.insert(0, product); // Добавляем в начало списка
        break;
      case EatType.dinner:
        dinner.insert(0, product); // Добавляем в начало списка
        break;
      case EatType.snack:
        snacks.insert(0, product); // Добавляем в начало списка
        break;
    }

    // Создаем обновленную запись
    final updatedRecord = record.copyWith(
      breakfast: breakfast,
      lunch: lunch,
      dinner: dinner,
      snacks: snacks,
    );

    // Обновляем запись в списке
    final index = records.indexWhere((r) => r.id == record.id);
    if (index != -1) {
      records[index] = updatedRecord;
    } else {
      records.add(updatedRecord);
    }

    // Обновляем калории в дневной записи
    updateDailyCalories();
  }

  /// Удалить продукт по индексу
  Future<void> removeFoodProductByIndex(int productIndex, EatType type) async {
    var record = getTodayRecord(currentDate);

    // Создаем копию списков для обновления
    List<FoodProduct> breakfast = List.from(record.breakfast);
    List<FoodProduct> lunch = List.from(record.lunch);
    List<FoodProduct> dinner = List.from(record.dinner);
    List<FoodProduct> snacks = List.from(record.snacks);

    switch (type) {
      case EatType.breakfast:
        if (productIndex >= 0 && productIndex < breakfast.length) {
          breakfast.removeAt(productIndex);
        }
        break;
      case EatType.lunch:
        if (productIndex >= 0 && productIndex < lunch.length) {
          lunch.removeAt(productIndex);
        }
        break;
      case EatType.dinner:
        if (productIndex >= 0 && productIndex < dinner.length) {
          dinner.removeAt(productIndex);
        }
        break;
      case EatType.snack:
        if (productIndex >= 0 && productIndex < snacks.length) {
          snacks.removeAt(productIndex);
        }
        break;
    }

    // Создаем обновленную запись
    final updatedRecord = record.copyWith(
      breakfast: breakfast,
      lunch: lunch,
      dinner: dinner,
      snacks: snacks,
    );

    // Обновляем запись в списке
    final index = records.indexWhere((r) => r.id == record.id);
    if (index != -1) {
      records[index] = updatedRecord;
    } else {
      records.add(updatedRecord);
    }

    // Обновляем калории в дневной записи
    updateDailyCalories();
  }

  /// Обновить калории в дневной записи
  void updateDailyCalories() {
    // Пересчитываем все продукты по всем категориям и обновляем калории в текущей записи

    // Получаем текущую запись за выбранную дату
    var record = getTodayRecord(currentDate);

    // Список всех продуктов по категориям
    List<FoodProduct> allProducts = [];
    allProducts.addAll(record.breakfast);
    allProducts.addAll(record.lunch);
    allProducts.addAll(record.dinner);
    allProducts.addAll(record.snacks);

    // Суммируем калории всех продуктов
    double totalCalories = 0;
    for (var product in allProducts) {
      totalCalories += product.totalCalories;
    }

    // Обновляем consumedCalories в записи
    final updatedRecord = record.copyWith(
      consumedCalories: totalCalories.toInt(),
    );

    // Обновляем запись в списке
    final index = records.indexWhere((r) => r.id == record.id);
    if (index != -1) {
      records[index] = updatedRecord;
    } else {
      // Если запись не найдена в списке, добавляем её
      records.add(updatedRecord);
    }

    // Сохраняем изменения в локальное хранилище
    saveToLocal();
  }

  /// Инициализация - загрузка из локального хранилища
  Future<void> init() async {
    await loadFromLocal();
  }

  /// Получить или создать запись на сегодня
  DailyCaloriesRecord getOrCreateTodayRecord() {
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
        burnedCalories: 1500, // Базовые калории организма (BMR)
        maxCalories: 2000, // Базовое значение для взрослого человека
        gender: user.gender.name,
      );
    }

    // Получаем сегодняшнюю дату (без времени)
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Проверяем, есть ли уже запись на сегодня
    DailyCaloriesRecord? todayRecord;

    try {
      todayRecord = records.firstWhere((record) {
        final recordDate = DateTime(
          record.date.year,
          record.date.month,
          record.date.day,
        );
        return recordDate.isAtSameMomentAs(todayDate);
      });
    } catch (e) {
      // Запись не найдена, создаем новую
      Logger.i('Запись на сегодня не найдена, создаем новую');
      todayRecord = null;
    }

    if (todayRecord == null || todayRecord.consumedCalories == 0) {
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
        burnedCalories: bmr, // Базовые калории организма (BMR)
        maxCalories:
            totalCalories, // Максимальные калории включают BMR + активность
        gender: user.gender.name,
      );

      records.add(newRecord);
      saveToLocal();
      return newRecord;
    }

    return todayRecord;
  }

  /// Получить запись на конкретную дату
  DailyCaloriesRecord getTodayRecord(DateTime? date) {
    final targetDate = date ?? currentDate;
    final targetDateOnly = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );

    // Ищем запись на нужную дату
    try {
      return records.firstWhere((record) {
        final recordDate = DateTime(
          record.date.year,
          record.date.month,
          record.date.day,
        );
        return recordDate.isAtSameMomentAs(targetDateOnly);
      });
    } catch (e) {
      // Если запись не найдена, создаем новую только для сегодняшней даты
      final today = DateTime.now();
      final todayOnly = DateTime(today.year, today.month, today.day);

      if (targetDateOnly.isAtSameMomentAs(todayOnly)) {
        Logger.i('Создаем новую запись на сегодня');
        return getOrCreateTodayRecord();
      } else {
        // Для других дат возвращаем пустую запись
        Logger.i(
          'Запись на дату ${targetDateOnly.toIso8601String()} не найдена, возвращаем пустую',
        );
        return DailyCaloriesRecord.create(
          date: targetDateOnly,
          burnedCalories: 1500, // Базовые калории организма (BMR)
          maxCalories: 2000, // Базовое значение для взрослого человека
          gender: 'male', // Базовое значение
        );
      }
    }
  }

  /// Добавить калории к съеденным на сегодня
  DailyCaloriesRecord addConsumedCalories(int calories) {
    final todayRecord = getOrCreateTodayRecord();
    final updatedRecord = todayRecord.addConsumedCalories(calories);

    // Обновляем запись в списке
    final index = records.indexWhere((r) => r.id == todayRecord.id);
    if (index != -1) {
      records[index] = updatedRecord;
      saveToLocal();
    }

    return updatedRecord;
  }

  /// Добавить калории к сожженным (например, от шагов)
  DailyCaloriesRecord addBurnedCalories(int calories) {
    final todayRecord = getOrCreateTodayRecord();
    final updatedRecord = todayRecord.addBurnedCalories(calories);

    // Обновляем запись в списке
    final index = records.indexWhere((r) => r.id == todayRecord.id);
    if (index != -1) {
      records[index] = updatedRecord;
      saveToLocal();
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

  /// Очистить все записи (для тестирования)
  Future<void> clearAll() async {
    records.clear();
    await saveToLocal();
  }

  /// Сброс данных репозитория
  void reset() {
    records.clear();
    currentDate = DateTime.now();
    Logger.i('DailyCaloriesRepository: данные сброшены');
  }
}
