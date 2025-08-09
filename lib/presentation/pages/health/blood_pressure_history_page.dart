import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';

class BloodPressureHistoryPage extends StatelessWidget {
  const BloodPressureHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(title: textLang('История давления'), isBack: true),
      body: BlocBuilder<HealthBloc, HealthState>(
        bloc: Get.find<HealthBloc>(),
        builder: (context, state) {
          // Получаем все измерения давления и пульса
          final pressureMetrics = state.healthData.metrics
              .where((m) => m.type == HealthMetricType.bloodPressureAndPulse)
              .toList();

          // Сортируем по дате (новые сверху)
          pressureMetrics.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return pressureMetrics.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: AppColor.greyText,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        textLang('История измерений давления пуста'),
                        style: TextStyle(
                          color: AppColor.greyText,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        textLang('Добавьте первое измерение давления'),
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
                  itemCount: pressureMetrics.length,
                  itemBuilder: (context, index) {
                    final metric = pressureMetrics[index];
                    final isLast = index == pressureMetrics.length - 1;

                    // Разбираем значение давления и пульса
                    String systolic = '--';
                    String diastolic = '--';
                    String pulse = '--';
                    
                    if (metric.value.contains('/')) {
                      final parts = metric.value.split('/');
                      if (parts.length == 3) {
                        systolic = parts[0];
                        diastolic = parts[1];
                        pulse = parts[2];
                      }
                    }

                    // Определяем разницу с предыдущим измерением
                    Map<String, int>? differences;
                    if (!isLast) {
                      final previousMetric = pressureMetrics[index + 1];
                      if (previousMetric.value.contains('/')) {
                        final prevParts = previousMetric.value.split('/');
                        if (prevParts.length == 3) {
                          final currentSys = int.tryParse(systolic) ?? 0;
                          final currentDia = int.tryParse(diastolic) ?? 0;
                          final currentPul = int.tryParse(pulse) ?? 0;
                          
                          final prevSys = int.tryParse(prevParts[0]) ?? 0;
                          final prevDia = int.tryParse(prevParts[1]) ?? 0;
                          final prevPul = int.tryParse(prevParts[2]) ?? 0;
                          
                          differences = {
                            'systolic': currentSys - prevSys,
                            'diastolic': currentDia - prevDia,
                            'pulse': currentPul - prevPul,
                          };
                        }
                      }
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
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
                          // Информация о давлении и пульсе
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Основные показатели
                                Row(
                                  children: [
                                    // Систолическое
                                    Text(
                                      systolic,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      '/',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppColor.greyText,
                                      ),
                                    ),
                                    // Диастолическое
                                    Text(
                                      diastolic,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'мм рт.ст.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColor.greyText.withValues(alpha: 0.7),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Пульс
                                    Text(
                                      pulse,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: AppColor.darkBlue,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'уд/мин',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColor.greyText.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),

                                // Изменения по сравнению с предыдущим измерением
                                if (differences != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      _buildDifference(
                                        differences['systolic']!,
                                        'сист.',
                                      ),
                                      const SizedBox(width: 12),
                                      _buildDifference(
                                        differences['diastolic']!,
                                        'диаст.',
                                      ),
                                      const SizedBox(width: 12),
                                      _buildDifference(
                                        differences['pulse']!,
                                        'пульс',
                                      ),
                                    ],
                                  ),
                                ],

                                const SizedBox(height: 4),

                                // Дата и время
                                Text(
                                  '${_formatDate(metric.timestamp)} в ${_formatTime(metric.timestamp)}',
                                  style: TextStyle(
                                    color: AppColor.greyText,
                                    fontSize: 14,
                                  ),
                                ),

                                // Заметка (если есть)
                                if (metric.note != null && metric.note!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    metric.note!,
                                    style: TextStyle(
                                      color: AppColor.greyText.withValues(alpha: 0.8),
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
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

  Widget _buildDifference(int difference, String label) {
    if (difference == 0) return const SizedBox.shrink();
    
    return Text(
      '$label ${difference > 0 ? '+' : ''}$difference',
      style: TextStyle(
        color: difference > 0 ? Colors.red : Colors.green,
        fontSize: 12,
        fontWeight: FontWeight.w500,
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
            'Вы уверены, что хотите удалить эту запись давления? Это действие нельзя отменить.',
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