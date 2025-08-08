import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/presentation/pages/health/widgets/metric_details_dialog.dart';

class HistoryItemWidget extends StatelessWidget {
  final HealthMetric metric;

  const HistoryItemWidget({super.key, required this.metric});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(metric.type.icon, color: AppColor.darkBlue),
        title: Text(metric.displayName),
        subtitle: Text('${metric.displayValue} ${metric.displayUnit}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatDate(metric.timestamp),
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              _formatTime(metric.timestamp),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        onTap: () => MetricDetailsDialog.show(context, metric),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
