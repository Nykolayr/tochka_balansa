import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';
import 'package:tochka_balansa/presentation/pages/health/widgets/add_blood_pressure_dialog.dart';
import 'package:tochka_balansa/presentation/pages/health/widgets/add_blood_sugar_dialog.dart'; // добавил
import 'package:tochka_balansa/presentation/pages/health/widgets/add_steps_dialog.dart'; // добавил

class AddMetricDialog {
  static void show(BuildContext context) {
    final List<Map<String, dynamic>> availableMetrics = [
      {
        'type': HealthMetricType.bloodPressureAndPulse,
        'title': textLang('Давление и пульс'),
        'icon': Icons.favorite,
        'color': Colors.red,
      },
      {
        'type': HealthMetricType.bloodSugar,
        'title': textLang('Сахар в крови'),
        'icon': Icons.bloodtype,
        'color': Colors.orange,
      },
      {
        'type': HealthMetricType.steps,
        'title': textLang('Шаги'),
        'icon': Icons.directions_walk,
        'color': Colors.green,
      },
      {
        'type': HealthMetricType.custom,
        'title': textLang('Свой показатель'),
        'icon': Icons.add_circle_outline,
        'color': AppColor.darkBlue,
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              textLang('Выберите показатель'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: availableMetrics.length,
              itemBuilder: (context, index) {
                final metric = availableMetrics[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    if (metric['type'] ==
                        HealthMetricType.bloodPressureAndPulse) {
                      // Используем новый диалог для давления и пульса
                      AddBloodPressureDialog.show(context);
                    } else if (metric['type'] == HealthMetricType.bloodSugar) {
                      // Используем специальный диалог для сахара в крови
                      AddBloodSugarDialog.show(context);
                    } else if (metric['type'] == HealthMetricType.steps) {
                      // Используем специальный диалог для шагов
                      AddStepsDialog.show(context);
                    } else if (metric['type'] == HealthMetricType.custom) {
                      // Показываем окно "В разработке"
                      _showInDevelopmentDialog(context);
                    } else {
                      _showSingleValueDialog(context, metric['type']);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: metric['color'].withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: metric['color'].withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(metric['icon'], size: 32, color: metric['color']),
                        const SizedBox(height: 8),
                        Text(
                          metric['title'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: metric['color'],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static void _showSingleValueDialog(
    BuildContext context,
    HealthMetricType type,
  ) {
    final valueController = TextEditingController();
    final noteController = TextEditingController();
    final customNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(type.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (type == HealthMetricType.custom) ...[
              TextField(
                controller: customNameController,
                decoration: InputDecoration(
                  labelText: textLang('Название показателя'),
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: valueController,
              keyboardType: _getKeyboardType(type),
              decoration: InputDecoration(
                labelText: textLang('Значение'),
                suffixText: type == HealthMetricType.custom ? null : type.unit,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: textLang('Заметка (необязательно)'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(textLang('Отмена')),
          ),
          TextButton(
            onPressed: () {
              final value = valueController.text.trim();
              if (value.isNotEmpty) {
                String finalValue = value;
                if (type == HealthMetricType.custom &&
                    customNameController.text.trim().isNotEmpty) {
                  finalValue = '${customNameController.text.trim()}: $value';
                }

                final metric = HealthMetric(
                  id: const Uuid().v4(),
                  type: type,
                  value: finalValue,
                  timestamp: DateTime.now(),
                  note: noteController.text.trim().isEmpty
                      ? null
                      : noteController.text.trim(),
                );

                Get.find<HealthBloc>().add(AddHealthMetricEvent(metric));
                Navigator.pop(context);
              }
            },
            child: Text(textLang('Добавить')),
          ),
        ],
      ),
    );
  }

  static void _showInDevelopmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.construction,
              color: AppColor.darkBlue,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(textLang('В разработке')),
          ],
        ),
        content: Text(
          textLang('Функция "Свой показатель" находится в разработке и будет доступна в следующих обновлениях приложения.'),
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(textLang('Понятно')),
          ),
        ],
      ),
    );
  }

  static TextInputType _getKeyboardType(HealthMetricType type) {
    switch (type) {
      case HealthMetricType.bloodSugar:
        return const TextInputType.numberWithOptions(decimal: true);
      case HealthMetricType.steps:
        return TextInputType.number;
      default:
        return TextInputType.text;
    }
  }
}
