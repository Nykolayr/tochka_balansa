import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';
import 'package:tochka_balansa/presentation/pages/health/widgets/add_steps_dialog.dart';
import 'package:go_router/go_router.dart';

class StepsBlockWidget extends StatelessWidget {
  const StepsBlockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HealthBloc, HealthState>(
      bloc: Get.find<HealthBloc>(),
      builder: (context, state) {
        final stepsMetrics = state.healthData.metrics
            .where((m) => m.type == HealthMetricType.steps)
            .toList();

        if (stepsMetrics.isEmpty) {
          return const SizedBox.shrink();
        }

        stepsMetrics.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        // Получаем предыдущее измерение для сравнения
        int? previousSteps;
        if (stepsMetrics.length > 1) {
          previousSteps = int.tryParse(stepsMetrics[1].value);
        }

        // Получаем общее количество шагов за сегодня
        final today = DateTime.now();
        final todayStart = DateTime(today.year, today.month, today.day);
        final todayEnd = todayStart.add(const Duration(days: 1));

        final todayStepsMetrics = stepsMetrics
            .where(
              (m) =>
                  m.timestamp.isAfter(todayStart) &&
                  m.timestamp.isBefore(todayEnd),
            )
            .toList();

        int totalStepsToday = 0;
        if (todayStepsMetrics.isNotEmpty) {
          totalStepsToday = todayStepsMetrics
              .map((m) => int.tryParse(m.value) ?? 0)
              .reduce((a, b) => a + b);
        }

        // Определяем статус по количеству шагов
        final stepsStatus = _getStepsStatus(totalStepsToday);

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
                      textLang('Мониторинг шагов'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColor.darkBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ROW с двумя COLUMN'ами и виджетом
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Первый COLUMN: "Шаги сегодня" + значение
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          textLang('Шаги сегодня'),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColor.greyText.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              totalStepsToday.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'шагов',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColor.greyText.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(width: 16),

                    // Второй COLUMN: стрелка + значение изменения
                    if (previousSteps != null &&
                        totalStepsToday != previousSteps) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 16,
                          ), // выравнивание с первым column
                          Icon(
                            totalStepsToday > previousSteps
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: totalStepsToday > previousSteps
                                ? Colors.green
                                : Colors.red,
                            size: 16,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            (totalStepsToday - previousSteps).abs().toString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: totalStepsToday > previousSteps
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                    ],

                    // Виджет состояния (растягивается по оставшейся ширине)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: stepsStatus.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          stepsStatus.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: stepsStatus.color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Кнопки добавления и просмотра
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => AddStepsDialog.show(context),
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
                        onPressed: () => context.push('/main/health/steps'),
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

  StepsStatus _getStepsStatus(int steps) {
    if (steps >= 10000) {
      return StepsStatus(title: textLang('Отлично!'), color: Colors.green);
    } else if (steps >= 8000) {
      return StepsStatus(title: textLang('Хорошо'), color: Colors.lightGreen);
    } else if (steps >= 6000) {
      return StepsStatus(title: textLang('Нормально'), color: Colors.orange);
    } else if (steps >= 4000) {
      return StepsStatus(
        title: textLang('Маловато'),
        color: Colors.orange[700]!,
      );
    } else {
      return StepsStatus(title: textLang('Очень мало'), color: Colors.red);
    }
  }
}

class StepsStatus {
  final String title;
  final Color color;

  StepsStatus({required this.title, required this.color});
}
