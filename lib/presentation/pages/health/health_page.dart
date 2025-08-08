import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';
import 'package:tochka_balansa/presentation/widgets/empty_state.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HealthBloc, HealthState>(
        bloc: Get.find<HealthBloc>(),
        builder: (context, state) {
          if (state.healthData.metrics.isEmpty) {
            return EmptyState(
              icon: Icons.health_and_safety,
              title: textLang('Нет данных о здоровье'),
              subtitle: textLang('Добавьте свой первый показатель здоровья'),
            );
          }

          // Группируем метрики по типу и берем последнюю запись для каждого типа
          final Map<HealthMetricType, HealthMetric> latestMetrics = {};
          for (var metric in state.healthData.metrics) {
            final existing = latestMetrics[metric.type];
            if (existing == null ||
                metric.timestamp.isAfter(existing.timestamp)) {
              latestMetrics[metric.type] = metric;
            }
          }

          // Сортируем все метрики по дате (новые сверху) для истории
          final sortedMetrics = List<HealthMetric>.from(
            state.healthData.metrics,
          )..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                ...latestMetrics.values.map(
                  (metric) => _buildMetricCard(metric),
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
                ...sortedMetrics.map((metric) => _buildHistoryItem(metric)),

                // Отступ снизу для FAB
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMetricDialog(context),
        backgroundColor: AppColor.darkBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMetricCard(HealthMetric metric) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.darkBlue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(metric.type.icon, color: AppColor.darkBlue, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metric.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${metric.displayValue} ${metric.displayUnit}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColor.darkBlue,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatDate(metric.timestamp),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(metric.timestamp),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(HealthMetric metric) {
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
        onTap: () => _showMetricDetailsDialog(context, metric),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showAddMetricDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddHealthMetricSheet(),
    );
  }

  void _showMetricDetailsDialog(BuildContext context, HealthMetric metric) {
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

  void _showDeleteConfirmationDialog(
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
}

class AddHealthMetricSheet extends StatefulWidget {
  const AddHealthMetricSheet({super.key});

  @override
  State<AddHealthMetricSheet> createState() => _AddHealthMetricSheetState();
}

class _AddHealthMetricSheetState extends State<AddHealthMetricSheet> {
  HealthMetricType _selectedType = HealthMetricType.weight;
  final _valueController = TextEditingController();
  final _secondaryValueController = TextEditingController();
  final _noteController = TextEditingController();
  final _customNameController = TextEditingController();
  final _customUnitController = TextEditingController();

  @override
  void dispose() {
    _valueController.dispose();
    _secondaryValueController.dispose();
    _noteController.dispose();
    _customNameController.dispose();
    _customUnitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              textLang('Добавить показатель'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Тип показателя
            Text(textLang('Тип показателя')),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<HealthMetricType>(
                  isExpanded: true,
                  value: _selectedType,
                  items: HealthMetricType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.title),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Поля для кастомного типа
            if (_selectedType == HealthMetricType.custom) ...[
              TextFormField(
                controller: _customNameController,
                decoration: InputDecoration(
                  labelText: textLang('Название показателя'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _customUnitController,
                decoration: InputDecoration(
                  labelText: textLang('Единица измерения'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Значение
            if (_selectedType == HealthMetricType.bloodPressure) ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _valueController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: textLang('Систолическое (верхнее)'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _secondaryValueController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: textLang('Диастолическое (нижнее)'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              TextFormField(
                controller: _valueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '${textLang('Значение')} (${_selectedType.unit})',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Примечание
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: textLang('Примечание (необязательно)'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Кнопка сохранения
            ElevatedButton(
              onPressed: _saveMetric,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.darkBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(textLang('Сохранить')),
            ),
          ],
        ),
      ),
    );
  }

  void _saveMetric() {
    // Валидация
    if (_valueController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(textLang('Введите значение'))));
      return;
    }

    if (_selectedType == HealthMetricType.bloodPressure &&
        _secondaryValueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(textLang('Введите оба значения давления'))),
      );
      return;
    }

    if (_selectedType == HealthMetricType.custom) {
      if (_customNameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(textLang('Введите название показателя'))),
        );
        return;
      }
      if (_customUnitController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(textLang('Введите единицу измерения'))),
        );
        return;
      }
    }

    // Создаем метрику
    final metric = HealthMetric(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selectedType,
      value: _valueController.text,
      secondaryValue: _selectedType == HealthMetricType.bloodPressure
          ? _secondaryValueController.text
          : null,
      timestamp: DateTime.now(),
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      customName: _selectedType == HealthMetricType.custom
          ? _customNameController.text
          : null,
      customUnit: _selectedType == HealthMetricType.custom
          ? _customUnitController.text
          : null,
    );

    // Добавляем в блок
    Get.find<HealthBloc>().add(AddHealthMetricEvent(metric));

    // Закрываем диалог
    Navigator.pop(context);
  }
}
