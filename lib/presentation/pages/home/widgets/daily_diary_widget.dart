import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/theme/colors.dart';
import 'package:tochka_balansa/data/models/health/daily_calories_record.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';
import 'package:tochka_balansa/data/services/calories_calculator_service.dart';
import 'package:tochka_balansa/data/services/steps_calories_calculator_service.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';

class DailyDiaryWidget extends StatelessWidget {
  final DailyCaloriesRecord record;

  const DailyDiaryWidget({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final events = _buildEventsList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок с кнопкой "Подробнее"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Дневник дня',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColor.darkBlue,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Переход на страницу подробного дневника
                      print('Переход на подробный дневник');
                    },
                    child: Text(
                      'Подробнее',
                      style: TextStyle(fontSize: 16, color: AppColor.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Черта под заголовком
              Container(height: 1, color: AppColor.greyLine),
            ],
          ),
        ),
        // Список событий
        SizedBox(
          height: 120, // Компактная высота
          child: events.isEmpty
              ? const Center(
                  child: Text(
                    'Нет событий за день',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: events[index],
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<Widget> _buildEventsList() {
    final events = <Widget>[];

    // 1. События по приемам пищи
    _addMealEvents(events, record.breakfast, 'Завтрак', Icons.breakfast_dining);
    _addMealEvents(events, record.lunch, 'Обед', Icons.lunch_dining);
    _addMealEvents(events, record.dinner, 'Ужин', Icons.dinner_dining);
    _addMealEvents(events, record.snacks, 'Перекус', Icons.cookie);

    // 2. События активности (шаги, упражнения)
    _addActivityEvents(events, record);

    // 3. BMR событие (всегда в конце списка)
    final bmr = _calculateBMR();
    if (record.burnedCalories >= bmr) {
      events.add(
        _buildEventItem(
          'Расходы организма',
          bmr, // Показываем рассчитанный BMR
          AppColor.green,
          Icons.local_fire_department,
          isBMR: true, // Флаг для BMR
        ),
      );
    }

    return events;
  }

  void _addMealEvents(
    List<Widget> events,
    List<FoodProduct> products,
    String mealName,
    IconData icon,
  ) {
    if (products.isNotEmpty) {
      // Группируем продукты по приему пищи
      final totalCalories = products.fold<int>(
        0,
        (sum, product) => sum + product.totalCalories,
      );

      // Сортируем продукты по времени добавления (последние сверху)
      final sortedProducts = List<FoodProduct>.from(products);
      sortedProducts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      events.add(
        _buildEventItem(
          mealName,
          totalCalories,
          AppColor.vesselBlue,
          icon,
          products: sortedProducts,
        ),
      );
    }
  }

  void _addActivityEvents(List<Widget> events, DailyCaloriesRecord record) {
    // Получаем отдельные записи о шагах за выбранную дату
    final stepsMetrics = _getStepsForDate(record.date);

    // Добавляем каждую запись о шагах отдельно
    for (final metric in stepsMetrics) {
      final steps = int.tryParse(metric.value) ?? 0;
      if (steps > 0) {
        // Рассчитываем калории для этого количества шагов
        final calories = _calculateCaloriesFromSteps(steps);

        events.add(
          _buildEventItem(
            'Шаги',
            calories,
            AppColor.green,
            Icons.directions_walk,
            timeText: _formatTime(metric.timestamp),
          ),
        );
      }
    }
  }

  /// Получить записи о шагах за конкретную дату
  List<HealthMetric> _getStepsForDate(DateTime date) {
    try {
      final healthBloc = Get.find<HealthBloc>();
      final targetDate = DateTime(date.year, date.month, date.day);
      final nextDay = targetDate.add(const Duration(days: 1));

      return healthBloc.state.healthData.metrics
          .where(
            (metric) =>
                metric.type == HealthMetricType.steps &&
                metric.timestamp.isAfter(targetDate) &&
                metric.timestamp.isBefore(nextDay),
          )
          .toList()
        ..sort(
          (a, b) => b.timestamp.compareTo(a.timestamp),
        ); // Сортируем по времени (новые сверху)
    } catch (e) {
      print('Ошибка получения шагов: $e');
      return [];
    }
  }

  /// Рассчитать калории от шагов
  int _calculateCaloriesFromSteps(int steps) {
    try {
      final userRepository = Get.find<UserRepository>();
      final user = userRepository.user;

      if (!user.isReg) {
        return 0;
      }

      return StepsCaloriesCalculatorService.calculateCaloriesFromSteps(
        weight: user.initialWeight,
        steps: steps,
      );
    } catch (e) {
      return 0;
    }
  }

  /// Форматировать время в HH:MM
  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  /// Рассчитать BMR для текущего пользователя
  int _calculateBMR() {
    try {
      final userRepository = Get.find<UserRepository>();
      final user = userRepository.user;

      if (!user.isReg) {
        return 1500; // Значение по умолчанию
      }

      return CaloriesCalculatorService.calculateBMR(
        age: user.age,
        gender: user.gender.name,
        weight: user.initialWeight,
        height: user.height,
      );
    } catch (e) {
      return 1500; // Значение по умолчанию при ошибке
    }
  }

  Widget _buildEventItem(
    String title,
    int calories,
    Color color,
    IconData icon, {
    List<FoodProduct>? products,
    bool isBMR = false,
    String? timeText,
  }) {
    // Получаем время для события
    String? eventTimeText;
    if (timeText != null) {
      // Время передано явно
      eventTimeText = timeText;
    } else if (products != null && products.isNotEmpty) {
      // Берем время последнего добавленного продукта
      final latestProduct = products.first;
      final time = latestProduct.timestamp;
      eventTimeText =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (isBMR) {
      eventTimeText = '00:00'; // BMR считается на весь день
    }

    // Формируем текст в формате "Завтрак (12:34) +119"
    final timePart = eventTimeText != null ? ' ($eventTimeText)' : '';
    final caloriesText = isBMR
        ? '+$calories' // BMR с плюсом
        : '+$calories'; // Все остальные тоже с плюсом

    return Container(
      key: title == 'Расходы организма' ? const ValueKey('bmr') : null,
      margin: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          // Иконка
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),

          // Название события с временем
          Expanded(
            child: Text(
              '$title$timePart',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColor.darkBlue,
              ),
            ),
          ),

          // Калории
          Text(
            caloriesText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
