import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/data/repositories/daily_calories_repository.dart';
import 'package:tochka_balansa/presentation/pages/main/bloc/main_bloc.dart';
import 'package:tochka_balansa/data/repositories/daily_events_repository.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';
import 'package:tochka_balansa/data/models/health/daily_event.dart';

class DateNavigationController extends GetxController {
  final DailyCaloriesRepository _dailyCaloriesRepo =
      Get.find<DailyCaloriesRepository>();
  final DailyEventsRepository _eventsRepo = Get.find<DailyEventsRepository>();

  late PageController pageController;
  DateTime selectedDate = DateTime.now();
  int currentPage = 0;
  List<DateTime> availableDates = [];

  @override
  void onInit() {
    super.onInit();
    // Устанавливаем текущий день в репозиториях при инициализации
    _dailyCaloriesRepo.setCurrentDate(DateTime.now());
    _eventsRepo.setCurrentDate(DateTime.now());

    // Создаем запись на сегодня если пользователь зарегистрирован
    _createTodayRecordIfNeeded();

    _loadAvailableDates();
    // Загружаем калории для текущей даты
    _loadCaloriesForDate(DateTime.now());
  }

  void _loadAvailableDates() {
    final today = DateTime.now();
    availableDates = [];

    // Проверяем последние 7 дней (включая сегодня)
    for (int i = 0; i <= 7; i++) {
      final date = today.subtract(Duration(days: i));

      // Проверяем наличие событий за эту дату
      final events = _eventsRepo.getEventsForDate(date);
      final hasEvents = events.isNotEmpty;

      if (hasEvents) {
        availableDates.add(date);
        print(
          '✅ Найдена запись для ${date.toString().split(' ')[0]}: events=${events.length}',
        );
      } else {
        print(
          '❌ Нет данных для ${date.toString().split(' ')[0]}: events=${events.length}',
        );
      }
    }

    // Если нет записей, добавляем сегодняшний день
    if (availableDates.isEmpty) {
      final todayDate = DateTime(today.year, today.month, today.day);
      availableDates.add(todayDate);
      print('📅 Нет записей, добавляем сегодняшний день');
    }

    // Сортируем по возрастанию (самая старая дата первая, сегодня последняя)
    availableDates.sort((a, b) => a.compareTo(b));

    // Инициализируем PageController с правильным количеством страниц
    // Начинаем с последнего индекса (сегодня)
    currentPage = availableDates.isNotEmpty ? availableDates.length - 1 : 0;
    pageController = PageController(initialPage: currentPage);

    if (availableDates.isNotEmpty) {
      selectedDate = availableDates[currentPage];
      print(
        '🎯 Установлена начальная дата: ${selectedDate.toString().split(' ')[0]} (индекс $currentPage)',
      );
    }
  }

  void onPageChanged(int page) {
    print('🔄 onPageChanged: page=$page, currentPage=$currentPage');
    // СТРОГАЯ проверка - только существующие страницы
    if (page >= 0 && page < availableDates.length) {
      // Обновляем текущую страницу и выбранную дату
      currentPage = page;
      selectedDate = availableDates[page];
      update(); // Обновляем AppBar и дневник

      // Загружаем калории для выбранной даты
      _loadCaloriesForDate(selectedDate);

      // Определяем направление свайпа
      if (page > currentPage) {
        // Свайп вправо → завтра (больший индекс)
        print('👉 Свайп вправо → завтра');
        swipeRight();
      } else if (page < currentPage) {
        // Свайп влево → вчера (меньший индекс)
        print('👈 Свайп влево → вчера');
        swipeLeft();
      }
    } else {
      Logger.e(
        '❌ ОШИБКА: Попытка перехода к несуществующей странице $page! Возвращаемся к $currentPage',
      );
      // Если страница не существует, НЕМЕДЛЕННО возвращаемся к текущей позиции
      if (pageController.hasClients) {
        pageController.jumpToPage(currentPage);
      }
    }
  }

  void goToPreviousDay() {
    // Левая кнопка = вчера = меньший индекс = previousPage
    if (pageController.hasClients && canGoToPrevious()) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void goToNextDay() {
    // Правая кнопка = завтра = больший индекс = nextPage
    if (pageController.hasClients && canGoToNext()) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Универсальная функция для свайпа влево (к вчера)
  void swipeLeft() {
    print(
      '👈 swipeLeft: currentPage=$currentPage, canGoToPrevious=${canGoToPrevious()}',
    );
    if (canGoToPrevious()) {
      print('✅ Свайп влево → вчера');
      goToPreviousDay();
    } else {
      print('❌ Не можем свайпнуть влево');
    }
  }

  // Универсальная функция для свайпа вправо (к завтра)
  void swipeRight() {
    print(
      '👉 swipeRight: currentPage=$currentPage, canGoToNext=${canGoToNext()}',
    );
    if (canGoToNext()) {
      print('✅ Свайп вправо → завтра');
      goToNextDay();
    } else {
      print('❌ Не можем свайпнуть вправо');
    }
  }

  bool canGoToPrevious() {
    // Левая кнопка = вчера = меньший индекс
    return currentPage > 0;
  }

  bool canGoToNext() {
    // Правая кнопка = завтра = больший индекс
    return currentPage < availableDates.length - 1;
  }

  Future<void> _loadCaloriesForDate(DateTime date) async {
    try {
      // Устанавливаем текущий день в репозитории событий
      _eventsRepo.setCurrentDate(date);

      // Получаем калории из событий
      final consumedCalories = _eventsRepo.getTotalConsumedCalories(date);
      final burnedCalories = _eventsRepo.getTotalBurnedCalories(date);

      // Обновляем MainBloc с данными для выбранной даты
      try {
        final mainBloc = Get.find<MainBloc>();
        mainBloc.add(
          UpdateCaloriesEvent(
            consumedCalories: consumedCalories,
            burnedCalories: burnedCalories,
            maxCalories: 5000,
          ),
        );
      } catch (e) {
        print('MainBloc еще не готов: $e');
        // Повторяем попытку через небольшую задержку
        Future.delayed(const Duration(milliseconds: 100), () {
          try {
            final mainBloc = Get.find<MainBloc>();
            mainBloc.add(
              UpdateCaloriesEvent(
                consumedCalories: consumedCalories,
                burnedCalories: burnedCalories,
                maxCalories: 5000,
              ),
            );
          } catch (e2) {
            print('Ошибка повторной попытки обновления MainBloc: $e2');
          }
        });
      }

      print(
        '📊 Загружены калории для ${date.toString().split(' ')[0]}: consumed=$consumedCalories, burned=$burnedCalories',
      );
    } catch (e) {
      print(
        '❌ Ошибка загрузки калорий для ${date.toString().split(' ')[0]}: $e',
      );
    }
  }

  /// Обновить дневник для текущей выбранной даты
  void updateDiary() {
    update(); // Обновляем дневник через GetBuilder
  }

  /// Создать запись на сегодня если пользователь зарегистрирован
  Future<void> _createTodayRecordIfNeeded() async {
    try {
      final userRepository = Get.find<UserRepository>();
      final user = userRepository.user;

      // Проверяем, зарегистрирован ли пользователь
      if (!user.isReg) {
        print('Пользователь не зарегистрирован, запись не создается');
        return;
      }

      // Проверяем, есть ли уже BMR событие на сегодня
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final existingEvents = _eventsRepo.getEventsForDate(todayDate);
      final hasBMR = existingEvents.any(
        (event) => event is BurnedEvent && event.type == EventType.bmr,
      );

      // Если BMR события нет, добавляем его
      if (!hasBMR) {
        print('Добавляем BMR событие для сегодняшнего дня');
        await _eventsRepo.addBMRForNewDay(todayDate);
      } else {
        print('BMR событие уже существует для сегодняшнего дня');
      }
    } catch (e) {
      print('Ошибка создания записи на сегодня: $e');
    }
  }

  /// Обновить UI после изменения событий
  void refreshUI() {
    update(); // Обновляет GetBuilder виджеты
    _loadCaloriesForDate(selectedDate);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
