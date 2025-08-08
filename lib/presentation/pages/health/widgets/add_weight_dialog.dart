import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';

class AddWeightDialog {
  static void show(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(textLang('Добавить текущий вес')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: textLang('Вес (кг)'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(textLang('Отмена')),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final weight = double.tryParse(controller.text);
                if (weight != null && weight > 0) {
                  // Создаем метрику веса
                  final metric = HealthMetric(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    type: HealthMetricType.weight,
                    value: weight.toString(),
                    timestamp: DateTime.now(),
                  );

                  // Добавляем в блок
                  Get.find<HealthBloc>().add(AddHealthMetricEvent(metric));
                  Navigator.of(context).pop();
                }
              }
            },
            child: Text(textLang('Сохранить')),
          ),
        ],
      ),
    );
  }
}
