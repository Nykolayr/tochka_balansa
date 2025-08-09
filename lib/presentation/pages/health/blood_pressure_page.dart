import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';
import 'package:tochka_balansa/presentation/pages/health/widgets/blood_pressure_chart_widget.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';

class BloodPressurePage extends StatefulWidget {
  const BloodPressurePage({super.key});

  @override
  State<BloodPressurePage> createState() => _BloodPressurePageState();
}

class _BloodPressurePageState extends State<BloodPressurePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddPressureDialog() {
    final systolicController = TextEditingController();
    final diastolicController = TextEditingController();
    final pulseController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(textLang('Давление и пульс')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: systolicController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: textLang('Систолическое (верхнее)'),
                suffixText: 'мм рт.ст.',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: diastolicController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: textLang('Диастолическое (нижнее)'),
                suffixText: 'мм рт.ст.',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pulseController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: textLang('Пульс'),
                suffixText: 'уд/мин',
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
              final systolic = systolicController.text.trim();
              final diastolic = diastolicController.text.trim();
              final pulse = pulseController.text.trim();

              if (systolic.isNotEmpty &&
                  diastolic.isNotEmpty &&
                  pulse.isNotEmpty) {
                final metric = HealthMetric(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  type: HealthMetricType.bloodPressureAndPulse,
                  value: '$systolic/$diastolic/$pulse',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(
        title: textLang('Давление и пульс'),
        isBack: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddPressureDialog,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/main/health/pressure/history'),
          ),
        ],
      ),
      body: BlocBuilder<HealthBloc, HealthState>(
        bloc: Get.find<HealthBloc>(),
        builder: (context, state) {
          // Получаем все измерения давления и пульса
          final pressureMetrics = state.healthData.metrics
              .where((m) => m.type == HealthMetricType.bloodPressureAndPulse)
              .toList();

          // Сортируем по дате (новые сверху)
          pressureMetrics.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          // Получаем последние значения
          String currentSystolic = '--';
          String currentDiastolic = '--';
          String currentPulse = '--';

          if (pressureMetrics.isNotEmpty) {
            final lastMeasurement = pressureMetrics.first.value;
            if (lastMeasurement.contains('/')) {
              final parts = lastMeasurement.split('/');
              if (parts.length == 3) {
                currentSystolic = parts[0];
                currentDiastolic = parts[1];
                currentPulse = parts[2];
              }
            }
          }

          // Определяем период для отображения
          DateTime startDate;
          String periodText;

          switch (_selectedTabIndex) {
            case 0:
              startDate = DateTime.now().subtract(const Duration(days: 30));
              periodText = textLang('За последние 30 дней');
              break;
            case 1:
              startDate = DateTime.now().subtract(const Duration(days: 84));
              periodText = textLang('За последние 12 недель');
              break;
            case 2:
              startDate = DateTime.now().subtract(const Duration(days: 365));
              periodText = textLang('За последние 12 месяцев');
              break;
            default:
              startDate = DateTime.now().subtract(const Duration(days: 30));
              periodText = textLang('За последние 30 дней');
          }

          // Фильтруем измерения по выбранному периоду
          final filteredMetrics = pressureMetrics
              .where((metric) => metric.timestamp.isAfter(startDate))
              .toList();

          // Сортируем для графика (старые сначала)
          filteredMetrics.sort((a, b) => a.timestamp.compareTo(b.timestamp));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Табы для переключения периодов
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColor.darkBlue,
                  unselectedLabelColor: AppColor.greyText,
                  indicatorColor: AppColor.darkBlue,
                  tabs: [
                    Tab(text: textLang('ПО ДНЯМ')),
                    Tab(text: textLang('ПО НЕДЕЛЯМ')),
                    Tab(text: textLang('ПО МЕСЯЦАМ')),
                  ],
                ),
              ),

              // Заголовок периода
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  periodText,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              // Информация о текущих показателях
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBulletPoint(
                      textLang('Систолическое'),
                      '$currentSystolic мм рт.ст.',
                      Colors.black,
                    ),
                    _buildBulletPoint(
                      textLang('Диастолическое'),
                      '$currentDiastolic мм рт.ст.',
                      Colors.black,
                    ),
                    _buildBulletPoint(
                      textLang('Пульс'),
                      '$currentPulse уд/мин',
                      AppColor.darkBlue,
                    ),
                    _buildBulletPoint(
                      textLang('Общее количество измерений'),
                      '${pressureMetrics.length}',
                      AppColor.greyText,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // График давления и пульса
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: BloodPressureChartWidget(metrics: filteredMetrics),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBulletPoint(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColor.darkBlue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: Colors.black)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }
}
