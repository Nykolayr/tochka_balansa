import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';

class BloodPressureBlockWidget extends StatelessWidget {
  const BloodPressureBlockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HealthBloc, HealthState>(
      bloc: Get.find<HealthBloc>(),
      builder: (context, state) {
        final pressureAndPulseMetrics = state.healthData.metrics
            .where((m) => m.type == HealthMetricType.bloodPressureAndPulse)
            .toList();

        if (pressureAndPulseMetrics.isEmpty) {
          return const SizedBox.shrink();
        }

        pressureAndPulseMetrics.sort(
          (a, b) => b.timestamp.compareTo(a.timestamp),
        );

        final lastMeasurement = pressureAndPulseMetrics.first.value;

        // Получаем предыдущее измерение для сравнения
        String? previousMeasurement;
        if (pressureAndPulseMetrics.length > 1) {
          previousMeasurement = pressureAndPulseMetrics[1].value;
        }

        // Разбираем текущие значения
        String systolic = '--';
        String diastolic = '--';
        String pulse = '--';

        if (lastMeasurement.contains('/')) {
          final parts = lastMeasurement.split('/');
          if (parts.length == 3) {
            systolic = parts[0];
            diastolic = parts[1];
            pulse = parts[2];
          }
        }

        // Разбираем предыдущие значения для сравнения
        int? previousSystolic;
        int? previousDiastolic;
        int? previousPulse;

        if (previousMeasurement != null && previousMeasurement.contains('/')) {
          final parts = previousMeasurement.split('/');
          if (parts.length == 3) {
            previousSystolic = int.tryParse(parts[0]);
            previousDiastolic = int.tryParse(parts[1]);
            previousPulse = int.tryParse(parts[2]);
          }
        }

        // Вычисляем изменения
        final currentSystolic = int.tryParse(systolic);
        final currentDiastolic = int.tryParse(diastolic);
        final currentPulseValue = int.tryParse(pulse);

        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок по центру
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      textLang('Мониторинг давления и пульса'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColor.darkBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Строка с показателями
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Систолическое давление
                    _buildPressureColumn(
                      label: textLang('Систолическое'),
                      value: systolic,
                      unit: 'мм рт.ст.',
                      currentValue: currentSystolic,
                      previousValue: previousSystolic,
                      alignment: CrossAxisAlignment.start,
                    ),

                    // Диастолическое давление
                    _buildPressureColumn(
                      label: textLang('Диастолическое'),
                      value: diastolic,
                      unit: 'мм рт.ст.',
                      currentValue: currentDiastolic,
                      previousValue: previousDiastolic,
                      alignment: CrossAxisAlignment.center,
                    ),

                    // Пульс
                    _buildPressureColumn(
                      label: textLang('Пульс'),
                      value: pulse,
                      unit: 'уд/мин',
                      currentValue: currentPulseValue,
                      previousValue: previousPulse,
                      alignment: CrossAxisAlignment.end,
                      isPulse: true,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Кнопки добавления и просмотра
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showAddPressureDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.darkBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(textLang('Добавить')),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Переход на страницу истории давления
                        },
                        icon: const Icon(Icons.bar_chart, size: 18),
                        label: Text(textLang('Просмотр')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.greyText.withValues(
                            alpha: 0.2,
                          ),
                          foregroundColor: AppColor.darkBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPressureColumn({
    required String label,
    required String value,
    required String unit,
    required int? currentValue,
    required int? previousValue,
    required CrossAxisAlignment alignment,
    bool isPulse = false,
  }) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColor.greyText.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isPulse ? AppColor.darkBlue : null,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: TextStyle(
                fontSize: 12,
                color: AppColor.greyText.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),

        // Стрелка изменения - показываем только если есть предыдущее измерение
        if (currentValue != null &&
            previousValue != null &&
            currentValue != previousValue) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                currentValue > previousValue
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                color: currentValue > previousValue ? Colors.red : Colors.green,
                size: 16,
              ),
              const SizedBox(width: 2),
              Text(
                (currentValue - previousValue).abs().toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: currentValue > previousValue
                      ? Colors.red
                      : Colors.green,
                ),
              ),
            ],
          ),
        ],
        // Убрал else блок с пустым SizedBox - теперь просто ничего не показываем
      ],
    );
  }

  void _showAddPressureDialog(BuildContext context) {
    final systolicController = TextEditingController();
    final diastolicController = TextEditingController();
    final pulseController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(textLang('Давление и пульс')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: systolicController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: textLang('Систолическое (верхнее)'),
                suffixText: 'мм рт.ст.',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: diastolicController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: textLang('Диастолическое (нижнее)'),
                suffixText: 'мм рт.ст.',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pulseController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: textLang('Пульс'),
                suffixText: 'уд/мин',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: textLang('Заметка (необязательно)'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(textLang('Отмена')),
          ),
          TextButton(
            onPressed: () {
              final systolic = systolicController.text.trim();
              final diastolic = diastolicController.text.trim();
              final pulse = pulseController.text.trim();

              if (systolic.isNotEmpty &&
                  diastolic.isNotEmpty &&
                  pulse.isNotEmpty) {
                // Сохраняем одной метрикой в формате "систолическое/диастолическое/пульс"
                final metric = HealthMetric(
                  id: const Uuid().v4(),
                  type: HealthMetricType.bloodPressureAndPulse,
                  value: '$systolic/$diastolic/$pulse',
                  timestamp: DateTime.now(),
                  note: noteController.text.trim().isEmpty
                      ? null
                      : noteController.text.trim(),
                );

                Get.find<HealthBloc>().add(AddHealthMetricEvent(metric));
                Navigator.pop(context);
              }
            },
            child: Text(textLang('Добавить')),
          ),
        ],
      ),
    );
  }
}
