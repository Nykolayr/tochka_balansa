import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';

class AddBloodPressureDialog {
  static void show(BuildContext context) {
    // Получаем последнее измерение давления и пульса
    final healthBloc = Get.find<HealthBloc>();
    final pressureMetrics = healthBloc.state.healthData.metrics
        .where((m) => m.type == HealthMetricType.bloodPressureAndPulse)
        .toList();

    // Значения по умолчанию
    int defaultSystolic = 120;
    int defaultDiastolic = 80;
    int defaultPulse = 60;

    if (pressureMetrics.isNotEmpty) {
      pressureMetrics.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final lastMeasurement = pressureMetrics.first.value;

      if (lastMeasurement.contains('/')) {
        final parts = lastMeasurement.split('/');
        if (parts.length == 3) {
          defaultSystolic = int.tryParse(parts[0]) ?? 120;
          defaultDiastolic = int.tryParse(parts[1]) ?? 80;
          defaultPulse = int.tryParse(parts[2]) ?? 60;
        }
      }
    }

    // Создаем ValueNotifier для отслеживания изменений
    final systolicValue = ValueNotifier<int>(defaultSystolic);
    final diastolicValue = ValueNotifier<int>(defaultDiastolic);
    final pulseValue = ValueNotifier<int>(defaultPulse);
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(textLang('Добавить давление и пульс')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Систолическое давление
              _buildPressureRow(
                label: '${textLang('Систолическое (верхнее)')} мм рт.ст.',
                unit: '',
                valueNotifier: systolicValue,
                minValue: 60,
                maxValue: 250,
                step: 1,
              ),

              const SizedBox(height: 16),

              // Диастолическое давление
              _buildPressureRow(
                label: '${textLang('Диастолическое (нижнее)')} мм рт.ст.',
                unit: '',
                valueNotifier: diastolicValue,
                minValue: 40,
                maxValue: 150,
                step: 1,
              ),

              const SizedBox(height: 16),

              // Пульс
              _buildPressureRow(
                label: '${textLang('Пульс')} уд/мин',
                unit: '',
                valueNotifier: pulseValue,
                minValue: 30,
                maxValue: 200,
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(textLang('Отмена')),
          ),
          ValueListenableBuilder<int>(
            valueListenable: systolicValue,
            builder: (context, systolic, child) {
              return ValueListenableBuilder<int>(
                valueListenable: diastolicValue,
                builder: (context, diastolic, child) {
                  return ValueListenableBuilder<int>(
                    valueListenable: pulseValue,
                    builder: (context, pulse, child) {
                      return TextButton(
                        onPressed: () {
                          final metric = HealthMetric(
                            id: const Uuid().v4(),
                            type: HealthMetricType.bloodPressureAndPulse,
                            value: '$systolic/$diastolic/$pulse',
                            timestamp: DateTime.now(),
                            note: noteController.text.trim().isEmpty
                                ? null
                                : noteController.text.trim(),
                          );

                          Get.find<HealthBloc>().add(
                            AddHealthMetricEvent(metric),
                          );
                          Navigator.pop(context);
                        },
                        child: Text(textLang('Добавить')),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  static Widget _buildPressureRow({
    required String label,
    required String unit,
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
                // Кнопка -5
                _buildSmallButton(
                  icon: Icons.keyboard_double_arrow_down,
                  onPressed: () {
                    valueNotifier.value = (valueNotifier.value - 5).clamp(
                      minValue,
                      maxValue,
                    );
                  },
                ),

                const SizedBox(width: 4),

                // Кнопка -1
                _buildSmallButton(
                  icon: Icons.remove,
                  onPressed: () {
                    valueNotifier.value = (valueNotifier.value - 1).clamp(
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
                      fontSize: 14, // уменьшил размер текста
                    ),
                    decoration: InputDecoration(
                      // убрал suffixText: unit,
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

                // Кнопка +1
                _buildSmallButton(
                  icon: Icons.add,
                  onPressed: () {
                    valueNotifier.value = (valueNotifier.value + 1).clamp(
                      minValue,
                      maxValue,
                    );
                  },
                ),

                const SizedBox(width: 4),

                // Кнопка +5
                _buildSmallButton(
                  icon: Icons.keyboard_double_arrow_up,
                  onPressed: () {
                    valueNotifier.value = (valueNotifier.value + 5).clamp(
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
