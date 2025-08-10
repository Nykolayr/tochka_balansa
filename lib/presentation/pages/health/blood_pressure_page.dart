import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/data/models/health/blood_pressure_category.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';
import 'package:tochka_balansa/presentation/pages/health/widgets/blood_pressure_chart_widget.dart';
import 'package:tochka_balansa/presentation/pages/health/widgets/add_blood_pressure_dialog.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';
import 'package:tochka_balansa/core/constants/test_data.dart';

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
    _tabController = TabController(length: 4, vsync: this); // Изменил с 3 на 4
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
    AddBloodPressureDialog.show(context);
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
          // ВРЕМЕННО: используем тестовые данные вместо реальных
          // final bloodPressureMetrics = state.healthData.metrics
          //     .where((m) => m.type == HealthMetricType.bloodPressureSystolic ||
          //                    m.type == HealthMetricType.bloodPressureDiastolic ||
          //                    m.type == HealthMetricType.heartRate)
          //     .toList();
          final bloodPressureMetrics = _generateTestBloodPressureData();

          // Сортируем по дате (новые сверху)
          bloodPressureMetrics.sort(
            (a, b) => b.timestamp.compareTo(a.timestamp),
          );

          // Получаем последние значения
          String currentSystolic = '--';
          String currentDiastolic = '--';
          String currentPulse = '--';

          if (bloodPressureMetrics.isNotEmpty) {
            final lastMeasurement = bloodPressureMetrics.first.value;
            if (lastMeasurement.contains('/')) {
              final parts = lastMeasurement.split('/');
              if (parts.length == 3) {
                currentSystolic = parts[0];
                currentDiastolic = parts[1];
                currentPulse = parts[2];
              }
            }
          }

          // Определяем период для отображения (всегда фиксированный)
          DateTime startDate;
          String periodText = '';

          switch (_selectedTabIndex) {
            case 0: // 7 ДНЕЙ
              startDate = DateTime.now().subtract(const Duration(days: 7));
              periodText = textLang('За последние 7 дней');
              break;
            case 1: // ПО ДНЯМ
              startDate = DateTime.now().subtract(const Duration(days: 30));
              periodText = textLang('За последние 30 дней');
              break;
            case 2: // ПО НЕДЕЛЯМ
              startDate = DateTime.now().subtract(
                const Duration(days: 84),
              ); // 12 недель
              periodText = textLang('За последние 12 недель');
              break;
            case 3: // ПО МЕСЯЦАМ
              startDate = DateTime.now().subtract(
                const Duration(days: 180),
              ); // 6 месяцев
              periodText = textLang('За последние 6 месяцев');
              break;
            default:
              startDate = DateTime.now().subtract(const Duration(days: 7));
              periodText = textLang('За последние 7 дней');
          }

          // Фильтруем измерения по выбранному периоду
          final filteredMetrics = bloodPressureMetrics
              .where(
                (metric) => metric.timestamp.isAfter(
                  startDate.subtract(const Duration(days: 1)),
                ),
              )
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
                  labelStyle: const TextStyle(fontSize: 10), // Уменьшил шрифт
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 10,
                  ), // Уменьшил шрифт
                  tabs: [
                    Tab(text: textLang('7 ДНЕЙ')),
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

              // Информация о показателях
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Текущие значения
                    Center(
                      child: Text(
                        textLang('Текущие значения'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Цифры текущих значений
                    if (bloodPressureMetrics.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Систолическое
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                currentSystolic,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'мм рт.ст.',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColor.greyText.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Диастолическое
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                currentDiastolic,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'мм рт.ст.',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColor.greyText.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Пульс
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                currentPulse,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'уд/мин',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColor.greyText.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                    const SizedBox(height: 8),

                    // Средние значения за период
                    Center(
                      child: Text(
                        '${textLang('Среднее за период')} (${filteredMetrics.length} ${_getPluralForm(filteredMetrics.length)})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildAverageValuesSimple(filteredMetrics),

                    const SizedBox(height: 8),

                    // Рекомендации
                    _buildRecommendations(filteredMetrics),
                  ],
                ),
              ),

              // График давления и пульса
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: BloodPressureChartWidget(
                    metrics: filteredMetrics,
                    selectedTabIndex: _selectedTabIndex,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildAverageValues(List<HealthMetric> metrics) {
    if (metrics.isEmpty) {
      return Text(
        textLang('Нет данных за период'),
        style: TextStyle(
          fontSize: 14,
          color: AppColor.greyText.withValues(alpha: 0.7),
        ),
      );
    }

    final averages = _calculateAverageValues(metrics);
    if (averages == null) {
      return Text(
        textLang('Нет валидных данных'),
        style: TextStyle(
          fontSize: 14,
          color: AppColor.greyText.withValues(alpha: 0.7),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Систолическое
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              textLang('Систолическое'),
              style: TextStyle(
                fontSize: 12,
                color: AppColor.greyText.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  averages['systolic'].toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  'мм рт.ст.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColor.greyText.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
        // Диастолическое
        Column(
          children: [
            Text(
              textLang('Диастолическое'),
              style: TextStyle(
                fontSize: 12,
                color: AppColor.greyText.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  averages['diastolic'].toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  'мм рт.ст.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColor.greyText.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
        // Пульс
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              textLang('Пульс'),
              style: TextStyle(
                fontSize: 12,
                color: AppColor.greyText.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  averages['pulse'].toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkBlue,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  'уд/мин',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColor.greyText.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Map<String, int>? _calculateAverageValues(List<HealthMetric> metrics) {
    double totalSystolic = 0;
    double totalDiastolic = 0;
    double totalPulse = 0;
    int validCount = 0;

    for (final metric in metrics) {
      if (metric.value.contains('/')) {
        final parts = metric.value.split('/');
        if (parts.length == 3) {
          final systolic = double.tryParse(parts[0]);
          final diastolic = double.tryParse(parts[1]);
          final pulse = double.tryParse(parts[2]);

          if (systolic != null && diastolic != null && pulse != null) {
            totalSystolic += systolic;
            totalDiastolic += diastolic;
            totalPulse += pulse;
            validCount++;
          }
        }
      }
    }

    if (validCount == 0) return null;

    return {
      'systolic': (totalSystolic / validCount).round(),
      'diastolic': (totalDiastolic / validCount).round(),
      'pulse': (totalPulse / validCount).round(),
    };
  }

  Widget _buildAverageValuesSimple(List<HealthMetric> metrics) {
    final averages = _calculateAverageValues(metrics);
    if (averages == null) {
      return Center(
        child: Text(
          textLang('Нет данных'),
          style: TextStyle(
            fontSize: 14,
            color: AppColor.greyText.withValues(alpha: 0.7),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Систолическое
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              averages['systolic'].toString(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 2),
            Text(
              'мм рт.ст.',
              style: TextStyle(
                fontSize: 10,
                color: AppColor.greyText.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        // Диастолическое
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              averages['diastolic'].toString(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 2),
            Text(
              'мм рт.ст.',
              style: TextStyle(
                fontSize: 10,
                color: AppColor.greyText.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        // Пульс
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              averages['pulse'].toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColor.darkBlue,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              'уд/мин',
              style: TextStyle(
                fontSize: 10,
                color: AppColor.greyText.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecommendations(List<HealthMetric> metrics) {
    final averages = _calculateAverageValues(metrics);
    if (averages == null) {
      return const SizedBox.shrink();
    }

    final bpCategory = BloodPressureCategory.getCategory(
      averages['systolic']!,
      averages['diastolic']!,
    );
    final pulseCategory = PulseCategory.getCategory(averages['pulse']!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Рекомендация по давлению
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8), // уменьшил с 12 до 8
          decoration: BoxDecoration(
            color: bpCategory.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: bpCategory.color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${textLang('Давление')}: ${bpCategory.title}',
                style: TextStyle(
                  fontSize: 12, // уменьшил с 14 до 12
                  fontWeight: FontWeight.bold,
                  color: bpCategory.color,
                ),
              ),
              const SizedBox(height: 2), // уменьшил с 4 до 2
              Text(
                bpCategory.recommendation,
                style: TextStyle(
                  fontSize: 11, // уменьшил с 12 до 11
                  color: bpCategory.color,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6), // уменьшил с 8 до 6
        // Рекомендация по пульсу
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8), // уменьшил с 12 до 8
          decoration: BoxDecoration(
            color: pulseCategory.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: pulseCategory.color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${textLang('Пульс')}: ${pulseCategory.title}',
                style: TextStyle(
                  fontSize: 12, // уменьшил с 14 до 12
                  fontWeight: FontWeight.bold,
                  color: pulseCategory.color,
                ),
              ),
              const SizedBox(height: 2), // уменьшил с 4 до 2
              Text(
                pulseCategory.recommendation,
                style: TextStyle(
                  fontSize: 11, // уменьшил с 12 до 11
                  color: pulseCategory.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getPluralForm(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return textLang('измерение');
    } else if ((count % 10 >= 2 && count % 10 <= 4) &&
        (count % 100 < 10 || count % 100 >= 20)) {
      return textLang('измерения');
    } else {
      return textLang('измерений');
    }
  }

  // ВРЕМЕННАЯ ФУНКЦИЯ ДЛЯ ТЕСТИРОВАНИЯ - УБРАТЬ ПОСЛЕ ПРОВЕРКИ!
  List<HealthMetric> _generateTestBloodPressureData() {
    final now = DateTime.now();

    // Создаем HealthMetric объекты
    final testMetrics = <HealthMetric>[];

    for (final data in TestData.bloodPressureData) {
      final date = now.subtract(Duration(days: data['daysOffset'] as int));

      // Давление и пульс в одном значении: "систолическое/диастолическое/пульс"
      testMetrics.add(
        HealthMetric(
          id: 'test_bp_${date.millisecondsSinceEpoch}',
          type: HealthMetricType.bloodPressureAndPulse,
          value: '${data['systolic']}/${data['diastolic']}/${data['pulse']}',
          timestamp: date,
          note: 'Тестовые данные',
        ),
      );
    }

    return testMetrics;
  }
}
