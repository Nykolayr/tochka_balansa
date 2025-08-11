import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';

class StepsHistoryPage extends StatelessWidget {
  const StepsHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(title: textLang('История шагов'), isBack: true),
      body: BlocBuilder<HealthBloc, HealthState>(
        bloc: Get.find<HealthBloc>(),
        builder: (context, state) {
          final stepsMetrics = state.healthData.metrics
              .where((m) => m.type == HealthMetricType.steps)
              .toList();

          if (stepsMetrics.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_walk,
                    size: 64,
                    color: AppColor.greyText.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    textLang('Нет записей о шагах'),
                    style: TextStyle(fontSize: 18, color: AppColor.greyText),
                  ),
                ],
              ),
            );
          }

          // Сортируем по дате (новые сначала)
          stepsMetrics.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: stepsMetrics.length,
            itemBuilder: (context, index) {
              final metric = stepsMetrics[index];
              final steps = int.tryParse(metric.value) ?? 0;
              final date = metric.timestamp;

              // Вычисляем разность с предыдущим измерением
              String differenceText = '';
              Color differenceColor = Colors.grey;
              IconData differenceIcon = Icons.remove;

              if (index < stepsMetrics.length - 1) {
                final previousMetric = stepsMetrics[index + 1];
                final previousSteps = int.tryParse(previousMetric.value) ?? 0;
                final difference = steps - previousSteps;

                if (difference != 0) {
                  differenceText = '${difference > 0 ? '+' : ''}$difference';
                  differenceColor = difference > 0 ? Colors.green : Colors.red;
                  differenceIcon = difference > 0
                      ? Icons.arrow_upward
                      : Icons.arrow_downward;
                }
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColor.darkBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.directions_walk,
                      color: AppColor.darkBlue,
                      size: 24,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        steps.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColor.darkBlue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        textLang('шагов'),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColor.greyText,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: AppColor.greyText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}',
                            style: TextStyle(
                              color: AppColor.greyText,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppColor.greyText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: AppColor.greyText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (metric.note != null && metric.note!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          metric.note!,
                          style: TextStyle(
                            color: AppColor.greyText,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing: differenceText.isNotEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              differenceIcon,
                              color: differenceColor,
                              size: 20,
                            ),
                            Text(
                              differenceText,
                              style: TextStyle(
                                color: differenceColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
