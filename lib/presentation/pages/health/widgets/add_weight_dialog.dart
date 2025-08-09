import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';

class AddWeightDialog {
  static void show(BuildContext context) {
    // Получаем текущий вес пользователя
    final userRepository = Get.find<UserRepository>();
    final initialWeight = userRepository.user.initialWeight;

    // Получаем последнее измерение веса из блока
    final healthBloc = Get.find<HealthBloc>();
    final weightMetrics = healthBloc.state.healthData.metrics
        .where((m) => m.type == HealthMetricType.weight)
        .toList();

    double currentWeight = initialWeight;
    if (weightMetrics.isNotEmpty) {
      weightMetrics.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      currentWeight =
          double.tryParse(weightMetrics.first.value) ?? initialWeight;
    }

    // Форматируем вес до одного десятичного знака
    final formattedWeight = currentWeight.toStringAsFixed(1);

    // Создаем контроллер с отформатированным текущим весом
    final weightController = TextEditingController(text: formattedWeight);

    // Создаем ValueNotifier для отслеживания изменений веса
    final weightValue = ValueNotifier<double>(currentWeight);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(textLang('Добавить текущий вес')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Строка с кнопками и полем ввода
            ValueListenableBuilder<double>(
              valueListenable: weightValue,
              builder: (context, value, child) {
                // Форматируем значение до одного десятичного знака
                weightController.text = value.toStringAsFixed(1);
                weightController.selection = TextSelection.fromPosition(
                  TextPosition(offset: weightController.text.length),
                );

                return Row(
                  children: [
                    // Кнопка минус
                    IconButton(
                      onPressed: () {
                        // Уменьшаем вес на 0.1 кг (100 грамм)
                        weightValue.value = (weightValue.value - 0.1).clamp(
                          0.1,
                          300.0,
                        );
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColor.darkBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.remove,
                          color: AppColor.darkBlue,
                          size: 20,
                        ),
                      ),
                    ),

                    // Поле ввода
                    Expanded(
                      child: TextField(
                        controller: weightController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: textLang('Вес (кг)'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          final newWeight = double.tryParse(value);
                          if (newWeight != null && newWeight > 0) {
                            weightValue.value = newWeight;
                          }
                        },
                      ),
                    ),

                    // Кнопка плюс
                    IconButton(
                      onPressed: () {
                        // Увеличиваем вес на 0.1 кг (100 грамм)
                        weightValue.value = (weightValue.value + 0.1).clamp(
                          0.1,
                          300.0,
                        );
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColor.darkBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: AppColor.darkBlue,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                );
              },
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
              final weight = double.tryParse(weightController.text);
              if (weight != null && weight > 0) {
                // Создаем метрику веса с форматированным значением
                final metric = HealthMetric(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  type: HealthMetricType.weight,
                  value: weight.toStringAsFixed(
                    1,
                  ), // Форматируем до одного знака
                  timestamp: DateTime.now(),
                );

                // Добавляем в блок
                Get.find<HealthBloc>().add(AddHealthMetricEvent(metric));
                Navigator.of(context).pop();
              }
            },
            child: Text(textLang('Сохранить')),
          ),
        ],
      ),
    );
  }
}
