import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';

class AddMetricDialog {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              textLang('Выберите показатель'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: HealthMetricType.values
                  .where((type) => type != HealthMetricType.weight)
                  .map((type) => _buildMetricButton(context, type))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  static Widget _buildMetricButton(
    BuildContext context,
    HealthMetricType type,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _showAddSpecificMetricDialog(context, type);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: MediaQuery.of(context).size.width / 2 - 24,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.darkBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.darkBlue.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(type.icon, size: 32, color: AppColor.darkBlue),
            const SizedBox(height: 8),
            Text(
              type.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  static void _showAddSpecificMetricDialog(
    BuildContext context,
    HealthMetricType type,
  ) {
    final valueController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(textLang('Добавить ${type.title.toLowerCase()}')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: valueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '${textLang('Значение')} (${type.unit})',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: textLang('Примечание (необязательно)'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(textLang('Отмена')),
          ),
          TextButton(
            onPressed: () {
              if (valueController.text.isNotEmpty) {
                final value = double.tryParse(valueController.text);
                if (value != null) {
                  // Создаем метрику
                  final metric = HealthMetric(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    type: type,
                    value: value.toString(),
                    timestamp: DateTime.now(),
                    note: noteController.text.isEmpty
                        ? null
                        : noteController.text,
                  );

                  // Добавляем в блок
                  Get.find<HealthBloc>().add(AddHealthMetricEvent(metric));
                  Navigator.of(context).pop();
                }
              }
            },
            child: Text(textLang('Сохранить')),
          ),
        ],
      ),
    );
  }
}
