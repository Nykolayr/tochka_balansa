import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/theme/colors.dart';
import 'package:tochka_balansa/data/models/health/daily_calories_record.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart';

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

    // 1. BMR событие (если есть сожженные калории)
    if (record.burnedCalories > 0) {
      events.add(
        _buildEventItem(
          'Расходы организма',
          record.burnedCalories,
          AppColor.green,
          Icons.local_fire_department,
        ),
      );
    }

    // 2. События по приемам пищи
    _addMealEvents(events, record.breakfast, 'Завтрак', Icons.breakfast_dining);
    _addMealEvents(events, record.lunch, 'Обед', Icons.lunch_dining);
    _addMealEvents(events, record.dinner, 'Ужин', Icons.dinner_dining);
    _addMealEvents(events, record.snacks, 'Перекус', Icons.cookie);

    // Сортируем по времени (последние сверху)
    events.sort((a, b) {
      // BMR всегда первый
      if (a.key == const ValueKey('bmr')) return -1;
      if (b.key == const ValueKey('bmr')) return 1;

      // Остальные по времени добавления (последние сверху)
      return 0; // Пока без сортировки по времени
    });

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

  Widget _buildEventItem(
    String title,
    int calories,
    Color color,
    IconData icon, {
    List<FoodProduct>? products,
  }) {
    // Получаем время для события
    String? timeText;
    if (products != null && products.isNotEmpty) {
      // Берем время последнего добавленного продукта
      final latestProduct = products.first;
      final time = latestProduct.timestamp;
      timeText =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (title == 'Расходы организма') {
      timeText = '00:00'; // BMR считается на весь день
    }

    // Формируем текст в формате "Завтрак (12:34) +119"
    final timePart = timeText != null ? ' ($timeText)' : '';
    final caloriesText = title == 'Расходы организма'
        ? '-$calories'
        : '+$calories';

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
