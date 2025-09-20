import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/data/datasources/hive_data.dart';
import 'package:tochka_balansa/data/models/health/daily_event.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';
import 'package:tochka_balansa/data/services/calories_calculator_service.dart';
import 'package:tochka_balansa/presentation/pages/main/bloc/main_bloc.dart';
import 'package:tochka_balansa/presentation/pages/home/date_navigation_controller.dart';

/// Репозиторий для управления событиями дня
class DailyEventsRepository {
  static final DailyEventsRepository _instance =
      DailyEventsRepository._internal();
  factory DailyEventsRepository() => _instance;

  DailyEventsRepository._internal();

  /// Списки событий по датам
  Map<String, List<DailyEvent>> eventsByDate = {};

  /// Текущая выбранная дата
  DateTime currentDate = DateTime.now();

  /// Установить текущую дату
  void setCurrentDate(DateTime date) {
    currentDate = date;
    print('📅 Установлена текущая дата: ${date.toString().split(' ')[0]}');
  }

  /// Получить ключ для даты
  String _getDateKey(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return dateOnly.toIso8601String().split('T')[0];
  }

  /// Добавить событие съедено
  Future<void> addConsumedEvent({
    required EventType type,
    required List<String> products,
    required int totalWeight,
    required int calories,
    String? note,
  }) async {
    // Проверяем, что это сегодняшний день
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final eventDate = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );

    if (!eventDate.isAtSameMomentAs(todayDate)) {
      print('❌ Нельзя добавлять события в прошлые дни');
      return;
    }

    final event = ConsumedEvent.create(
      type: type,
      products: products,
      totalWeight: totalWeight,
      calories: calories,
      note: note,
    );

    final dateKey = _getDateKey(currentDate);
    eventsByDate[dateKey] ??= [];
    eventsByDate[dateKey]!.add(event);

    await _saveToLocal();
    await _updateMainBloc();
    _updateDiary();

    print(
      '✅ Добавлено событие съедено: ${type.displayName} - $calories калорий',
    );
  }

  /// Добавить событие сожжено
  Future<void> addBurnedEvent({
    required EventType type,
    required int calories,
    int? quantity,
    String? unit,
    String? note,
  }) async {
    // Проверяем, что это сегодняшний день
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final eventDate = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );

    if (!eventDate.isAtSameMomentAs(todayDate)) {
      print('❌ Нельзя добавлять события в прошлые дни');
      return;
    }

    final event = BurnedEvent.create(
      type: type,
      calories: calories,
      quantity: quantity,
      unit: unit,
      note: note,
    );

    final dateKey = _getDateKey(currentDate);
    eventsByDate[dateKey] ??= [];
    eventsByDate[dateKey]!.add(event);

    await _saveToLocal();
    await _updateMainBloc();
    _updateDiary();

    print(
      '✅ Добавлено событие сожжено: ${type.displayName} - $calories калорий',
    );
  }

  /// Получить события за дату
  List<DailyEvent> getEventsForDate(DateTime date) {
    final dateKey = _getDateKey(date);
    return eventsByDate[dateKey] ?? [];
  }

  /// Получить события съедено за дату
  List<ConsumedEvent> getConsumedEventsForDate(DateTime date) {
    return getEventsForDate(date).whereType<ConsumedEvent>().toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Получить события сожжено за дату
  List<BurnedEvent> getBurnedEventsForDate(DateTime date) {
    return getEventsForDate(date).whereType<BurnedEvent>().toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Рассчитать общие калории съедено за дату
  int getTotalConsumedCalories(DateTime date) {
    return getConsumedEventsForDate(
      date,
    ).fold(0, (sum, event) => sum + event.calories);
  }

  /// Рассчитать общие калории сожжено за дату
  int getTotalBurnedCalories(DateTime date) {
    return getBurnedEventsForDate(
      date,
    ).fold(0, (sum, event) => sum + event.calories);
  }

  /// Инициализация - загрузка из локального хранилища
  Future<void> init() async {
    await _loadFromLocal();
  }

  /// Загрузить события из локального хранилища
  Future<void> _loadFromLocal() async {
    try {
      final eventsJson = await HiveData.loadListJson(
        key: HiveDataKey.dailyEvents,
      );
      eventsByDate.clear();

      for (final eventJson in eventsJson) {
        try {
          final event = _eventFromJson(eventJson);
          final dateKey = _getDateKey(event.timestamp);
          eventsByDate[dateKey] ??= [];
          eventsByDate[dateKey]!.add(event);
        } catch (e) {
          print('Ошибка загрузки события: $e');
        }
      }

      Logger.i(
        'Загружено событий: ${eventsByDate.values.fold(0, (sum, list) => sum + list.length)}',
      );
    } catch (e) {
      Logger.e('Ошибка загрузки событий: $e');
    }
  }

  /// Сохранить события в локальное хранилище
  Future<void> _saveToLocal() async {
    try {
      final allEvents = <Map<String, dynamic>>[];

      for (final events in eventsByDate.values) {
        for (final event in events) {
          if (event is ConsumedEvent) {
            allEvents.add(event.toJson());
          } else if (event is BurnedEvent) {
            allEvents.add(event.toJson());
          }
        }
      }

      await HiveData.saveListJson(
        key: HiveDataKey.dailyEvents,
        json: allEvents,
      );
      Logger.i('События сохранены: ${allEvents.length}');
    } catch (e) {
      Logger.e('Ошибка сохранения событий: $e');
    }
  }

  /// Создать событие из JSON
  DailyEvent _eventFromJson(Map<String, dynamic> json) {
    final type = EventType.values.firstWhere((e) => e.name == json['type']);

    if (type.isConsumed) {
      return ConsumedEvent.fromJson(json);
    } else {
      return BurnedEvent.fromJson(json);
    }
  }

  /// Обновить MainBloc
  Future<void> _updateMainBloc() async {
    try {
      final consumedCalories = getTotalConsumedCalories(currentDate);
      final burnedCalories = getTotalBurnedCalories(currentDate);

      final mainBloc = Get.find<MainBloc>();
      mainBloc.add(
        UpdateCaloriesEvent(
          consumedCalories: consumedCalories,
          burnedCalories: burnedCalories,
          maxCalories: 5000,
        ),
      );
    } catch (e) {
      print('Ошибка обновления MainBloc: $e');
    }
  }

  /// Обновить дневник
  void _updateDiary() {
    try {
      final dateController = Get.find<DateNavigationController>();
      dateController.updateDiary();
    } catch (e) {
      print('DateNavigationController не найден: $e');
    }
  }

  /// Добавить BMR событие для нового дня
  Future<void> addBMRForNewDay(DateTime date) async {
    final dateKey = _getDateKey(date);

    // Проверяем, есть ли уже BMR событие за этот день
    final existingBMR =
        eventsByDate[dateKey]?.any(
          (event) => event is BurnedEvent && event.type == EventType.bmr,
        ) ??
        false;

    if (existingBMR) return;

    try {
      final userRepository = Get.find<UserRepository>();
      final user = userRepository.user;

      if (!user.isReg) return;

      final bmr = CaloriesCalculatorService.calculateBMR(
        age: user.age,
        gender: user.gender.name,
        weight: user.initialWeight,
        height: user.height,
      );

      final event = BurnedEvent.create(
        type: EventType.bmr,
        calories: bmr,
        note: 'Базовый метаболизм',
      );

      eventsByDate[dateKey] ??= [];
      eventsByDate[dateKey]!.add(event);

      await _saveToLocal();
      print('✅ Добавлен BMR для дня: $dateKey - $bmr калорий');
    } catch (e) {
      print('Ошибка добавления BMR: $e');
    }
  }
}
