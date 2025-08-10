import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';

class BloodSugarHistoryPage extends StatelessWidget {
  const BloodSugarHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(
        title: textLang('История сахара в крови'),
        isBack: true,
      ),
      body: BlocBuilder<HealthBloc, HealthState>(
        bloc: Get.find<HealthBloc>(),
        builder: (context, state) {
          final sugarMetrics = state.healthData.metrics
              .where((m) => m.type == HealthMetricType.bloodSugar)
              .toList();

          sugarMetrics.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return sugarMetrics.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bloodtype_outlined,
                        size: 64,
                        color: AppColor.greyText,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        textLang('История измерений сахара пуста'),
                        style: TextStyle(
                          color: AppColor.greyText,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        textLang('Добавьте первое измерение сахара'),
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
                  itemCount: sugarMetrics.length,
                  itemBuilder: (context, index) {
                    final metric = sugarMetrics[index];
                    final isLast = index == sugarMetrics.length - 1;

                    double? difference;
                    if (!isLast) {
                      final current = double.tryParse(metric.value);
                      final previous = double.tryParse(
                        sugarMetrics[index + 1].value,
                      );
                      if (current != null && previous != null) {
                        difference = current - previous;
                      }
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      metric.value,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'ммоль/л',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColor.greyText.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (difference != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '${difference > 0 ? '+' : ''}${difference.toStringAsFixed(1)}',
                                    style: TextStyle(
                                      color: difference > 0
                                          ? Colors.red
                                          : Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  '${_formatDate(metric.timestamp)} в ${_formatTime(metric.timestamp)}',
                                  style: TextStyle(
                                    color: AppColor.greyText,
                                    fontSize: 14,
                                  ),
                                ),
                                if (metric.note != null &&
                                    metric.note!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    metric.note!,
                                    style: TextStyle(
                                      color: AppColor.greyText.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
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
          textLang('Вы уверены, что хотите удалить это измерение сахара?'),
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
