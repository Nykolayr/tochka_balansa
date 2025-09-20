import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/data/repositories/daily_calories_repository.dart';

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

    // Сортируем по убыванию (сегодня первым)
    availableDates.sort((a, b) => b.compareTo(a));

    // Инициализируем PageController с правильным количеством страниц
    pageController = PageController(initialPage: 0);
    currentPage = 0;

    if (availableDates.isNotEmpty) {
      selectedDate = availableDates[0];
    }
  }

  void onPageChanged(int page) {
    // СТРОГАЯ проверка - только существующие страницы
    if (page >= 0 && page < availableDates.length) {
      currentPage = page;
      selectedDate = availableDates[page];
      update(); // Обновляем UI
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
    if (pageController.hasClients && canGoToPrevious()) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void goToNextDay() {
    if (pageController.hasClients && canGoToNext()) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool canGoToPrevious() {
    return currentPage > 0;
  }

  bool canGoToNext() {
    return currentPage < availableDates.length - 1;
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
