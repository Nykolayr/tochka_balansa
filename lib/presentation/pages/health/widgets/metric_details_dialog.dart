import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';

class MetricDetailsDialog {
  static void show(BuildContext context, HealthMetric metric) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(metric.displayName),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${textLang('Значение')}: ${metric.displayValue} ${metric.displayUnit}',
            ),
            const SizedBox(height: 8),
            Text('${textLang('Дата')}: ${_formatDate(metric.timestamp)}'),
            Text('${textLang('Время')}: ${_formatTime(metric.timestamp)}'),
            if (metric.note != null && metric.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('${textLang('Примечание')}: ${metric.note}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(textLang('Закрыть')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showDeleteConfirmationDialog(context, metric);
            },
            child: Text(textLang('Удалить')),
          ),
        ],
      ),
    );
  }

  static void _showDeleteConfirmationDialog(
    BuildContext context,
    HealthMetric metric,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(textLang('Удалить запись?')),
        content: Text(
          textLang(
            'Вы уверены, что хотите удалить эту запись? Это действие нельзя отменить.',
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

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  static String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
