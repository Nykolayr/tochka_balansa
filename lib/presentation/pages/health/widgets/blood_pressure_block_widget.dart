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
        // Получаем данные о давлении и пульсе (теперь одна метрика)
        final pressureAndPulseMetrics = state.healthData.metrics
            .where((m) => m.type == HealthMetricType.bloodPressureAndPulse)
            .toList();

        // Если нет данных - не показываем виджет
        if (pressureAndPulseMetrics.isEmpty) {
          return const SizedBox.shrink();
        }

        // Сортируем по дате (новые сверху)
        pressureAndPulseMetrics.sort(
          (a, b) => b.timestamp.compareTo(a.timestamp),
        );

        // Получаем последние значения
        final lastMeasurement = pressureAndPulseMetrics.first.value;

        // Разбираем значение в формате "систолическое/диастолическое/пульс"
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          textLang('Систолическое'),
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
                              systolic,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'мм рт.ст.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColor.greyText.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Диастолическое давление
                    Column(
                      children: [
                        Text(
                          textLang('Диастолическое'),
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
                              diastolic,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'мм рт.ст.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColor.greyText.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Пульс
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          textLang('Пульс'),
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
                              pulse,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColor.darkBlue,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'уд/мин',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColor.greyText.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
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
