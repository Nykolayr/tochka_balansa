import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart';

class AddFoodDialog extends StatelessWidget {
  const AddFoodDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Заголовок с полоской
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Заголовок
          const Text(
            'Добавить еду',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),

          // Сетка кнопок
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                final mealType = MealType.values[index];
                return _buildMealButton(context, mealType);
              },
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildMealButton(BuildContext context, MealType mealType) {
    final iconData = switch (mealType) {
      MealType.breakfast => Icons.wb_sunny,
      MealType.lunch => Icons.restaurant,
      MealType.dinner => Icons.nights_stay,
      MealType.snack => Icons.coffee,
    };

    final color = switch (mealType) {
      MealType.breakfast => Colors.orange,
      MealType.lunch => Colors.green,
      MealType.dinner => Colors.blue,
      MealType.snack => Colors.purple,
    };

    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop(); // Закрываем sheet

        // ИСПРАВЛЕНО: пути без слешей, так как это дочерние роуты к home
        switch (mealType) {
          case MealType.breakfast:
            context.push('/main/home/breakfast'); // полный путь
            break;
          case MealType.lunch:
            context.push('/main/home/lunch');
            break;
          case MealType.dinner:
            context.push('/main/home/dinner');
            break;
          case MealType.snack:
            context.push('/main/home/snack');
            break;
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.all(16),
        elevation: 2,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(iconData, size: 32),
          const SizedBox(height: 8),
          Text(
            mealType.title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
