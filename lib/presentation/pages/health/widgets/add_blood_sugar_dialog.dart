import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';

class AddBloodSugarDialog {
  static void show(BuildContext context) {
    // Получаем последнее измерение сахара в крови из блока
    final healthBloc = Get.find<HealthBloc>();
    final sugarMetrics = healthBloc.state.healthData.metrics
        .where((m) => m.type == HealthMetricType.bloodSugar)
        .toList();

    // Нормальное значение сахара в крови (если измерений еще нет)
    double currentSugar = 5.5; // ммоль/л - нормальное значение
    if (sugarMetrics.isNotEmpty) {
      sugarMetrics.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      currentSugar = double.tryParse(sugarMetrics.first.value) ?? 5.5;
    }

    // Форматируем значение до одного десятичного знака
    final formattedSugar = currentSugar.toStringAsFixed(1);

    // Создаем контроллер с отформатированным текущим значением
    final sugarController = TextEditingController(text: formattedSugar);

    // Создаем ValueNotifier для отслеживания изменений
    final sugarValue = ValueNotifier<double>(currentSugar);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(textLang('Добавить сахар в крови')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Строка с кнопками и полем ввода
            ValueListenableBuilder<double>(
              valueListenable: sugarValue,
              builder: (context, value, child) {
                // Форматируем значение до одного десятичного знака
                sugarController.text = value.toStringAsFixed(1);
                sugarController.selection = TextSelection.fromPosition(
                  TextPosition(offset: sugarController.text.length),
                );

                return Row(
                  children: [
                    // Кнопка минус
                    IconButton(
                      onPressed: () {
                        // Уменьшаем значение на 0.1 ммоль/л
                        sugarValue.value = (sugarValue.value - 0.1).clamp(
                          1.0,
                          30.0,
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
                        controller: sugarController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: textLang('Сахар (ммоль)'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          final newSugar = double.tryParse(value);
                          if (newSugar != null && newSugar > 0) {
                            sugarValue.value = newSugar;
                          }
                        },
                      ),
                    ),

                    // Кнопка плюс
                    IconButton(
                      onPressed: () {
                        // Увеличиваем значение на 0.1 ммоль/л
                        sugarValue.value = (sugarValue.value + 0.1).clamp(
                          1.0,
                          30.0,
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
              final sugar = double.tryParse(sugarController.text);
              if (sugar != null && sugar > 0) {
                // Создаем метрику сахара в крови с форматированным значением
                final metric = HealthMetric(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  type: HealthMetricType.bloodSugar,
                  value: sugar.toStringAsFixed(
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
