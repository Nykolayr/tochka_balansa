import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/data/repositories/daily_calories_repository.dart';
import 'package:tochka_balansa/presentation/pages/main/bloc/main_bloc.dart';

class DateNavigationController extends GetxController {
  final DailyCaloriesRepository _dailyCaloriesRepo =
      Get.find<DailyCaloriesRepository>();

  late PageController pageController;
  DateTime selectedDate = DateTime.now();
  int currentPage = 0;
  List<DateTime> availableDates = [];

  @override
  void onInit() {
    super.onInit();
    _loadAvailableDates();
  }

  void _loadAvailableDates() {
    final today = DateTime.now();
    availableDates = [];

    // Проверяем последние 7 дней (включая сегодня)
    for (int i = 0; i <= 7; i++) {
      final date = today.subtract(Duration(days: i));
      final record = _dailyCaloriesRepo.getTodayRecord(date);

      // Добавляем дату только если есть РЕАЛЬНЫЕ данные (еда или активность)
      // BMR по умолчанию (1500) не считается реальными данными
      final hasRealData =
          record.consumedCalories > 0 ||
          (record.burnedCalories > 0 && record.burnedCalories != 1500);

      if (hasRealData) {
        availableDates.add(date);
      } else {
        Logger.e(
          '❌ Нет данных для ${date.toString().split(' ')[0]}: consumed=${record.consumedCalories}, burned=${record.burnedCalories} (только BMR по умолчанию)',
        );
      }
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
      update(); // Обновляем AppBar

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
      final record = _dailyCaloriesRepo.getTodayRecord(date);

      // Обновляем MainBloc с данными для выбранной даты
      final mainBloc = Get.find<MainBloc>();
      mainBloc.add(
        UpdateCaloriesEvent(
          consumedCalories: record.consumedCalories,
          burnedCalories: record.burnedCalories,
          maxCalories: record.maxCalories,
        ),
      );

      print(
        '📊 Загружены калории для ${date.toString().split(' ')[0]}: consumed=${record.consumedCalories}, burned=${record.burnedCalories}',
      );
    } catch (e) {
      print(
        '❌ Ошибка загрузки калорий для ${date.toString().split(' ')[0]}: $e',
      );
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
