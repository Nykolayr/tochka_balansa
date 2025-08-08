import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';
import 'package:tochka_balansa/presentation/pages/health/widgets/add_metric_dialog.dart';
import 'package:tochka_balansa/presentation/pages/health/widgets/add_weight_dialog.dart';
import 'package:tochka_balansa/presentation/pages/health/widgets/history_item_widget.dart';
import 'package:tochka_balansa/presentation/pages/health/widgets/metric_card_widget.dart';
import 'package:tochka_balansa/presentation/pages/health/widgets/weight_block_widget.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  final UserRepository userRepository = Get.find<UserRepository>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HealthBloc, HealthState>(
        bloc: Get.find<HealthBloc>(),
        builder: (context, state) {
          // Получаем последнее измерение веса
          HealthMetric? latestWeight;
          if (state.healthData.metrics.isNotEmpty) {
            final weightMetrics = state.healthData.metrics
                .where((m) => m.type == HealthMetricType.weight)
                .toList();
            if (weightMetrics.isNotEmpty) {
              weightMetrics.sort((a, b) => b.timestamp.compareTo(a.timestamp));
              latestWeight = weightMetrics.first;
            }
          }

          // Сортируем все метрики по дате (новые сверху) для истории
          final sortedMetrics = List<HealthMetric>.from(
            state.healthData.metrics,
          )..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          // Группируем метрики по типу и берем последнюю запись для каждого типа
          final Map<HealthMetricType, HealthMetric> latestMetrics = {};
          for (var metric in state.healthData.metrics) {
            final existing = latestMetrics[metric.type];
            if (existing == null ||
                metric.timestamp.isAfter(existing.timestamp)) {
              latestMetrics[metric.type] = metric;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Блок о весе
                WeightBlockWidget(
                  latestWeight: latestWeight,
                  onAddWeightPressed: () => AddWeightDialog.show(context),
                ),

                const SizedBox(height: 24),

                // Секция текущих показателей
                Text(
                  textLang('Текущие показатели'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkBlue,
                  ),
                ),
                const SizedBox(height: 16),
                if (latestMetrics.isNotEmpty)
                  ...latestMetrics.values
                      .where((metric) => metric.type != HealthMetricType.weight)
                      .map((metric) => MetricCardWidget(metric: metric))
                else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        textLang('Добавьте свой первый показатель здоровья'),
                        style: TextStyle(
                          color: AppColor.greyText.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),

                // Место для графиков (будет добавлено позже)
                const SizedBox(height: 24),
                Text(
                  textLang('Графики'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkBlue,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColor.greyLine.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      textLang('Здесь будут графики показателей здоровья'),
                      style: TextStyle(
                        color: AppColor.greyText.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),

                // Секция рекомендаций (будет добавлена позже)
                const SizedBox(height: 24),
                Text(
                  textLang('Рекомендации'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkBlue,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColor.darkBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColor.darkBlue.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    textLang(
                      'Здесь будут персональные рекомендации на основе ваших показателей здоровья',
                    ),
                    style: const TextStyle(color: AppColor.darkBlue),
                  ),
                ),

                // Секция истории
                const SizedBox(height: 24),
                Text(
                  textLang('История измерений'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkBlue,
                  ),
                ),
                const SizedBox(height: 16),
                if (sortedMetrics.isNotEmpty)
                  ...sortedMetrics.map(
                    (metric) => HistoryItemWidget(metric: metric),
                  )
                else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        textLang('История измерений пуста'),
                        style: TextStyle(
                          color: AppColor.greyText.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),

                // Отступ снизу для FAB
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddMetricDialog.show(context),
        backgroundColor: AppColor.darkBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
