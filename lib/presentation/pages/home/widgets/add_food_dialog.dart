import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';

class AddFoodDialog {
  static void show(BuildContext context) {
    final List<Map<String, dynamic>> mealTypes = [
      {
        'title': textLang('Завтрак'),
        'icon': Icons.wb_sunny,
        'color': Colors.orange,
      },
      {
        'title': textLang('Обед'),
        'icon': Icons.restaurant,
        'color': Colors.red,
      },
      {
        'title': textLang('Ужин'),
        'icon': Icons.nights_stay,
        'color': Colors.indigo,
      },
      {
        'title': textLang('Перекус'),
        'icon': Icons.coffee,
        'color': Colors.brown,
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              textLang('Выберите прием пищи'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: mealTypes.length,
              itemBuilder: (context, index) {
                final meal = mealTypes[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    // Пока просто закрываем, потом добавим логику
                    _showMealDialog(context, meal);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: meal['color'].withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: meal['color'].withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(meal['icon'], size: 32, color: meal['color']),
                        const SizedBox(height: 8),
                        Text(
                          meal['title'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: meal['color'],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static void _showMealDialog(BuildContext context, Map<String, dynamic> meal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(meal['icon'], color: meal['color'], size: 24),
            const SizedBox(width: 8),
            Text(meal['title']),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              textLang(
                'Функция добавления ${meal['title'].toString().toLowerCase()} находится в разработке',
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(textLang('Понятно')),
          ),
        ],
      ),
    );
  }
}
