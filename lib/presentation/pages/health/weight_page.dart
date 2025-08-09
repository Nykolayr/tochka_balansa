import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';
import 'package:tochka_balansa/presentation/pages/health/widgets/add_weight_dialog.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';

class WeightPage extends StatefulWidget {
  const WeightPage({super.key});

  @override
  State<WeightPage> createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: textLang('Вес'), isBack: true),
      body: BlocBuilder<HealthBloc, HealthState>(
        bloc: Get.find<HealthBloc>(),
        builder: (context, state) {
          // Получаем все измерения веса
          final weightMetrics = state.healthData.metrics
              .where((m) => m.type == HealthMetricType.weight)
              .toList();

          // Сортируем по дате (новые сверху)
          weightMetrics.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return Column(
            children: [
              // Здесь будет график веса
              Container(
                width: double.infinity,
                height: 250,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor.greyLine.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    textLang('Здесь будет график изменения веса'),
                    style: TextStyle(
                      color: AppColor.greyText.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),

              // Список измерений веса
              Expanded(
                child: weightMetrics.isEmpty
                    ? Center(
                        child: Text(
                          textLang('История измерений веса пуста'),
                          style: TextStyle(
                            color: AppColor.greyText.withValues(alpha: 0.7),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: weightMetrics.length,
                        itemBuilder: (context, index) {
                          final metric = weightMetrics[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(
                                Icons.monitor_weight_outlined,
                                color: AppColor.darkBlue,
                              ),
                              title: Text(
                                '${double.parse(metric.value).toStringAsFixed(1)} кг', // Форматируем до одного знака
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(_formatDateTime(metric.timestamp)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () =>
                                    _showDeleteConfirmation(context, metric),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddWeightDialog.show(context),
        backgroundColor: AppColor.darkBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
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
