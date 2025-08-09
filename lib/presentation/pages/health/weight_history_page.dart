import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';

class WeightHistoryPage extends StatelessWidget {
  const WeightHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(title: textLang('История веса'), isBack: true),
      body: BlocBuilder<HealthBloc, HealthState>(
        bloc: Get.find<HealthBloc>(),
        builder: (context, state) {
          // Получаем все измерения веса
          final weightMetrics = state.healthData.metrics
              .where((m) => m.type == HealthMetricType.weight)
              .toList();

          // Сортируем по дате (новые сверху)
          weightMetrics.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return weightMetrics.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.monitor_weight_outlined,
                        size: 64,
                        color: AppColor.greyText,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        textLang('История измерений веса пуста'),
                        style: TextStyle(
                          color: AppColor.greyText,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        textLang('Добавьте первое измерение веса'),
                        style: TextStyle(
                          color: AppColor.greyText.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: weightMetrics.length,
                  itemBuilder: (context, index) {
                    final metric = weightMetrics[index];
                    final isLast = index == weightMetrics.length - 1;

                    // Определяем разницу с предыдущим измерением
                    double? difference;
                    if (!isLast) {
                      final previousMetric = weightMetrics[index + 1];
                      final currentWeight = double.tryParse(metric.value) ?? 0;
                      final previousWeight =
                          double.tryParse(previousMetric.value) ?? 0;
                      difference = currentWeight - previousWeight;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 5.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Информация о весе
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Вес и прогресс в одной строке
                                Row(
                                  children: [
                                    Text(
                                      '${double.parse(metric.value).toStringAsFixed(1)} кг',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                    if (difference != null) ...[
                                      const SizedBox(width: 12),
                                      Text(
                                        difference > 0
                                            ? '+${difference.toStringAsFixed(1)} кг'
                                            : '${difference.toStringAsFixed(1)} кг',
                                        style: TextStyle(
                                          color: difference > 0
                                              ? Colors.red
                                              : difference < 0
                                              ? AppColor.green
                                              : AppColor.greyText,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),

                                // Дата и время
                                Text(
                                  '${_formatDate(metric.timestamp)} в ${_formatTime(metric.timestamp)}',
                                  style: TextStyle(
                                    color: AppColor.greyText,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Кнопка удаления
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: AppColor.greyText,
                              size: 20,
                            ),
                            onPressed: () =>
                                _showDeleteConfirmation(context, metric),
                          ),
                        ],
                      ),
                    );
                  },
                );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteConfirmation(BuildContext context, HealthMetric metric) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(textLang('Удалить запись?')),
        content: Text(
          textLang(
            'Вы уверены, что хотите удалить эту запись веса? Это действие нельзя отменить.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(textLang('Отмена')),
          ),
          TextButton(
            onPressed: () {
              Get.find<HealthBloc>().add(DeleteHealthMetricEvent(metric.id));
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(textLang('Удалить')),
          ),
        ],
      ),
    );
  }
}
