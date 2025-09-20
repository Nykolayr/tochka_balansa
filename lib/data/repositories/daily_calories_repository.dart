import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:tochka_balansa/data/datasources/hive_data.dart';
import 'package:tochka_balansa/data/models/health/daily_calories_record.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart';
import 'package:tochka_balansa/data/services/calories_calculator_service.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/presentation/pages/food/enum_eat.dart';
import 'package:tochka_balansa/presentation/pages/home/date_navigation_controller.dart';
import 'package:tochka_balansa/presentation/pages/main/bloc/main_bloc.dart';

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
    // Используем currentDate для добавления продуктов
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

    // Сохраняем изменения в локальное хранилище
    saveToLocal();

    // Обновляем дневник
    _updateDiary();
  }

  /// Удалить продукт по индексу
  Future<void> removeFoodProductByIndex(int productIndex, EatType type) async {
    // Используем currentDate для удаления продуктов
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

    // Сохраняем изменения в локальное хранилище
    saveToLocal();

    // Обновляем дневник
    _updateDiary();
  }

  /// Обновить калории в дневной записи
  void updateDailyCalories() {
    // Пересчитываем все продукты по всем категориям и обновляем калории в текущей записи

    // Всегда используем реальную сегодняшнюю дату для обновления калорий
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    var record = getTodayRecord(todayDate);

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

  /// Перезаписать запись на сегодня с новыми данными пользователя
  DailyCaloriesRecord recreateTodayRecord() {
    Logger.i('Перезаписываем запись на сегодня с новыми данными пользователя');

    final userRepository = Get.find<UserRepository>();
    final user = userRepository.user;

    // Получаем сегодняшнюю дату (без времени)
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Рассчитываем BMR (базовый метаболизм)
    final bmr = CaloriesCalculatorService.calculateBMR(
      age: user.age,
      gender: user.gender.name,
      weight: user.initialWeight,
      height: user.height,
    );

    // Удаляем существующую запись на сегодня, если она есть
    records.removeWhere(
      (record) =>
          record.date.year == todayDate.year &&
          record.date.month == todayDate.month &&
          record.date.day == todayDate.day,
    );

    // Создаем новую запись с правильными данными
    final newRecord = DailyCaloriesRecord.create(
      date: todayDate,
      burnedCalories: bmr, // Базовые калории организма (BMR)
      maxCalories: 5000, // Фиксированная максимальная емкость сосудов
      gender: user.gender.name,
    );

    records.add(newRecord);
    saveToLocal();

    Logger.i(
      'Запись на сегодня перезаписана: BMR=$bmr, активность=${user.activityLevel.title}',
    );

    return newRecord;
  }

  /// Получить или создать запись на сегодня
  DailyCaloriesRecord getOrCreateTodayRecord() {
    Logger.i(
      'getOrCreateTodayRecord: загружено ${records.length} записей из локального хранилища',
    );

    final userRepository = Get.find<UserRepository>();
    final user = userRepository.user;

    // ИСПРАВЛЕНО: проверяем данные пользователя ДО всего остального
    if (!user.isReg) {
      Logger.i(
        'Пользователь не зарегистрирован (name="${user.name}"), запись НЕ создается',
      );

      // Возвращаем пустую запись без создания в базе данных
      return DailyCaloriesRecord.create(
        date: DateTime.now(),
        burnedCalories: 0, // Нет данных пользователя - нет BMR
        maxCalories: 5000, // Фиксированная максимальная емкость сосудов
        gender: user.gender.name,
      );
    }

    // Получаем сегодняшнюю дату (без времени)
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Рассчитываем BMR (базовый метаболизм) - выносим в начало для использования в обновлении
    final bmr = CaloriesCalculatorService.calculateBMR(
      age: user.age,
      gender: user.gender.name,
      weight: user.initialWeight,
      height: user.height,
    );

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

    if (todayRecord == null) {
      // ТОЛЬКО если запись не найдена - создаем новую запись с расчетом
      Logger.i(
        'Запись на сегодня не найдена, создаем новую с расчетом калорий',
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
        maxCalories: 5000, // Фиксированная максимальная емкость сосудов
        gender: user.gender.name,
      );

      records.add(newRecord);
      saveToLocal();
      return newRecord;
    }

    // Используем существующую запись
    Logger.i(
      'Используем существующую запись на сегодня: consumedCalories=${todayRecord.consumedCalories}, burnedCalories=${todayRecord.burnedCalories}',
    );
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
        // Проверяем, введены ли данные пользователя перед созданием записи
        final userRepository = Get.find<UserRepository>();
        final user = userRepository.user;

        if (!user.isReg) {
          Logger.i('Пользователь не зарегистрирован, возвращаем пустую запись');
          return DailyCaloriesRecord.create(
            date: targetDateOnly,
            burnedCalories: 0, // Нет данных пользователя - нет BMR
            maxCalories: 5000, // Фиксированная максимальная емкость сосудов
            gender: user.gender.name,
          );
        }

        Logger.i('Создаем новую запись на сегодня');
        return getOrCreateTodayRecord();
      } else {
        // Для других дат НЕ создаем записи - возвращаем пустую без добавления в records
        Logger.i(
          'Запись на дату ${targetDateOnly.toIso8601String()} не найдена, возвращаем пустую БЕЗ создания',
        );
        return DailyCaloriesRecord.create(
          date: targetDateOnly,
          burnedCalories: 0, // НЕ создаем записи для прошлых дат
          maxCalories: 5000,
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
    // Используем currentDate вместо сегодняшней даты
    final targetRecord = getTodayRecord(currentDate);
    final updatedRecord = targetRecord.addBurnedCalories(calories);

    // Обновляем запись в списке
    final index = records.indexWhere((r) => r.id == targetRecord.id);
    if (index != -1) {
      records[index] = updatedRecord;
      saveToLocal();
    } else {
      // Если запись не найдена, добавляем её
      records.add(updatedRecord);
      saveToLocal();
    }

    // Обновляем MainBloc с новыми данными
    try {
      final mainBloc = Get.find<MainBloc>();
      mainBloc.add(
        UpdateCaloriesEvent(
          consumedCalories: updatedRecord.consumedCalories,
          burnedCalories: updatedRecord.burnedCalories,
          maxCalories: updatedRecord.maxCalories,
        ),
      );
    } catch (e) {
      print('Ошибка обновления MainBloc: $e');
    }

    // Обновляем дневник
    _updateDiary();

    return updatedRecord;
  }

  /// Загрузить записи из локального хранилища
  Future<void> loadFromLocal() async {
    try {
      final recordsJson = await HiveData.loadListJson(
        key: HiveDataKey.dailyCaloriesRecords,
      );
      Logger.i(
        'Загружено записей из локального хранилища: ${recordsJson.length}',
      );
      records = recordsJson.map((json) {
        try {
          Logger.i('Обрабатываем запись: ${json.runtimeType}');
          final convertedJson = Map<String, dynamic>.from(json as Map);
          Logger.i('Конвертированный JSON: $convertedJson');
          final record = DailyCaloriesRecord.fromJson(convertedJson);
          Logger.i('Успешно создана запись: ${record.date}');
          return record;
        } catch (e) {
          Logger.e('Ошибка при обработке записи $json: $e');
          rethrow;
        }
      }).toList();
      Logger.i('Успешно загружено ${records.length} записей калорий');
    } catch (e) {
      Logger.e('Ошибка загрузки записей: $e');
      records = [];
    }
  }

  /// Сохранить записи в локальное хранилище
  Future<void> saveToLocal() async {
    try {
      Logger.i(
        'Сохраняем ${records.length} записей калорий в локальное хранилище',
      );
      await HiveData.saveListJson(
        key: HiveDataKey.dailyCaloriesRecords,
        json: records.map((record) => record.toJson()).toList(),
      );
      Logger.i('Успешно сохранено ${records.length} записей калорий');
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

  /// Обновить дневник
  void _updateDiary() {
    try {
      // Получаем DateNavigationController и обновляем дневник
      final dateController = Get.find<DateNavigationController>();
      dateController.updateDiary();
    } catch (e) {
      // Игнорируем ошибку, если контроллер не найден
      print('DateNavigationController не найден: $e');
    }
  }

  /// Очистить завтрак
  Future<void> clearBreakfast() async {
    final targetRecord = getTodayRecord(currentDate);
    final updatedRecord = targetRecord.copyWith(breakfast: []);

    final index = records.indexWhere((r) => r.id == targetRecord.id);
    if (index != -1) {
      records[index] = updatedRecord;
      await saveToLocal();
    }
  }

  /// Очистить обед
  Future<void> clearLunch() async {
    final targetRecord = getTodayRecord(currentDate);
    final updatedRecord = targetRecord.copyWith(lunch: []);

    final index = records.indexWhere((r) => r.id == targetRecord.id);
    if (index != -1) {
      records[index] = updatedRecord;
      await saveToLocal();
    }
  }

  /// Очистить ужин
  Future<void> clearDinner() async {
    final targetRecord = getTodayRecord(currentDate);
    final updatedRecord = targetRecord.copyWith(dinner: []);

    final index = records.indexWhere((r) => r.id == targetRecord.id);
    if (index != -1) {
      records[index] = updatedRecord;
      await saveToLocal();
    }
  }

  /// Очистить перекусы
  Future<void> clearSnacks() async {
    final targetRecord = getTodayRecord(currentDate);
    final updatedRecord = targetRecord.copyWith(snacks: []);

    final index = records.indexWhere((r) => r.id == targetRecord.id);
    if (index != -1) {
      records[index] = updatedRecord;
      await saveToLocal();
    }
  }
}
