import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';

class AddStepsDialog {
  static void show(BuildContext context) {
    // Получаем последнее измерение шагов за сегодня
    final healthBloc = Get.find<HealthBloc>();
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final todayStepsMetrics = healthBloc.state.healthData.metrics
        .where(
          (m) =>
              m.type == HealthMetricType.steps &&
              m.timestamp.isAfter(todayStart) &&
              m.timestamp.isBefore(todayEnd),
        )
        .toList();

    // Значение по умолчанию: 5000 шагов или существующее значение за сегодня
    int defaultSteps = 5000;
    String? existingMetricId;

    if (todayStepsMetrics.isNotEmpty) {
      // Если есть записи за сегодня, берем последнюю
      todayStepsMetrics.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final lastMetric = todayStepsMetrics.first;
      defaultSteps = int.tryParse(lastMetric.value) ?? 5000;
      existingMetricId = lastMetric.id;
    }

    // Создаем ValueNotifier для отслеживания изменений
    final stepsValue = ValueNotifier<int>(defaultSteps);
    final noteController = TextEditingController();

    // Если есть существующая запись, заполняем заметку
    if (existingMetricId != null && todayStepsMetrics.isNotEmpty) {
      noteController.text = todayStepsMetrics.first.note ?? '';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(textLang('Добавить шаги')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Строка с кнопками и полем ввода
            _buildStepsRow(
              label: textLang('Количество шагов'),
              valueNotifier: stepsValue,
              minValue: 0,
              maxValue: 999999,
              step: 1,
            ),

            const SizedBox(height: 16),

            // Заметка
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: textLang('Заметка (необязательно)'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 2,
            ),

            // Информация о том, что будет добавлено к существующему значению
            if (existingMetricId != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.darkBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColor.darkBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        textLang(
                          'Шаги будут добавлены к существующему значению за сегодня',
                        ),
                        style: TextStyle(
                          color: AppColor.darkBlue,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(textLang('Отмена')),
          ),
          ValueListenableBuilder<int>(
            valueListenable: stepsValue,
            builder: (context, value, child) {
              return TextButton(
                onPressed: () {
                  if (existingMetricId != null) {
                    // Обновляем существующую запись
                    final existingMetric = todayStepsMetrics.first;
                    final currentSteps =
                        int.tryParse(existingMetric.value) ?? 0;
                    final newTotalSteps = currentSteps + value;

                    final updatedMetric = existingMetric.copyWith(
                      value: newTotalSteps.toString(),
                      note: noteController.text.trim().isEmpty
                          ? existingMetric.note
                          : noteController.text.trim(),
                    );

                    Get.find<HealthBloc>().add(
                      UpdateHealthMetricEvent(updatedMetric),
                    );
                  } else {
                    // Создаем новую запись
                    final metric = HealthMetric(
                      id: const Uuid().v4(),
                      type: HealthMetricType.steps,
                      value: value.toString(),
                      timestamp: DateTime.now(),
                      note: noteController.text.trim().isEmpty
                          ? null
                          : noteController.text.trim(),
                    );

                    Get.find<HealthBloc>().add(AddHealthMetricEvent(metric));
                  }

                  Navigator.pop(context);
                },
                child: Text(
                  existingMetricId != null
                      ? textLang('Обновить')
                      : textLang('Добавить'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static Widget _buildStepsRow({
    required String label,
    required ValueNotifier<int> valueNotifier,
    required int minValue,
    required int maxValue,
    required int step,
  }) {
    final controller = TextEditingController();

    return ValueListenableBuilder<int>(
      valueListenable: valueNotifier,
      builder: (context, value, child) {
        controller.text = value.toString();
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Кнопка -200
                _buildSmallButton(
                  icon: Icons.keyboard_double_arrow_down,
                  onPressed: () {
                    valueNotifier.value = (valueNotifier.value - 200).clamp(
                      minValue,
                      maxValue,
                    );
                  },
                ),

                const SizedBox(width: 4),

                // Кнопка -50
                _buildSmallButton(
                  icon: Icons.remove,
                  onPressed: () {
                    valueNotifier.value = (valueNotifier.value - 50).clamp(
                      minValue,
                      maxValue,
                    );
                  },
                ),

                const SizedBox(width: 8),

                // Поле ввода
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (text) {
                      final newValue = int.tryParse(text);
                      if (newValue != null) {
                        valueNotifier.value = newValue.clamp(
                          minValue,
                          maxValue,
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(width: 8),

                // Кнопка +50
                _buildSmallButton(
                  icon: Icons.add,
                  onPressed: () {
                    valueNotifier.value = (valueNotifier.value + 50).clamp(
                      minValue,
                      maxValue,
                    );
                  },
                ),

                const SizedBox(width: 4),

                // Кнопка +200
                _buildSmallButton(
                  icon: Icons.keyboard_double_arrow_up,
                  onPressed: () {
                    valueNotifier.value = (valueNotifier.value + 200).clamp(
                      minValue,
                      maxValue,
                    );
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _buildSmallButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColor.darkBlue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColor.darkBlue, size: 16),
        ),
      ),
    );
  }
}
