import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';
import 'package:tochka_balansa/presentation/pages/health/widgets/add_weight_dialog.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';

class WeightPage extends StatefulWidget {
  const WeightPage({super.key});

  @override
  State<WeightPage> createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage>
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(
        title: textLang('Вес'),
        isBack: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => AddWeightDialog.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/main/health/weight/history'),
          ),
        ],
      ),
      body: BlocBuilder<HealthBloc, HealthState>(
        bloc: Get.find<HealthBloc>(),
        builder: (context, state) {
          // Получаем все измерения веса
          final weightMetrics = state.healthData.metrics
              .where((m) => m.type == HealthMetricType.weight)
              .toList();

          // Сортируем по дате (новые сверху для списка, старые сверху для графика)
          weightMetrics.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          // Получаем желаемый вес из главной цели пользователя
          final userRepository = Get.find<UserRepository>();
          final initialWeight = userRepository.user.initialWeight;
          final targetWeight = userRepository.user.mainGoal.targetWeight;

          // Получаем текущий вес (последнее измерение)
          final currentWeight = weightMetrics.isNotEmpty
              ? double.tryParse(weightMetrics.first.value) ?? initialWeight
              : initialWeight;

          // Разница между текущим и начальным весом
          final weightDifference = currentWeight - initialWeight;
          final weightDifferenceText = weightDifference >= 0
              ? '+${weightDifference.toStringAsFixed(1)}'
              : weightDifference.toStringAsFixed(1);

          // Расчет прогноза - используем примерную дату начала цели
          final forecastData = _calculateForecast(
            weightMetrics,
            targetWeight,
            initialWeight,
            DateTime.now().subtract(
              const Duration(days: 30),
            ), // Предполагаем, что цель создана месяц назад
          );

          // Определяем период для отображения (30 дней, 12 недель, 12 месяцев)
          DateTime startDate;
          String periodText;

          switch (_selectedTabIndex) {
            case 0:
              startDate = DateTime.now().subtract(const Duration(days: 30));
              periodText = textLang('За последние 30 дней');
              break;
            case 1:
              startDate = DateTime.now().subtract(
                const Duration(days: 84),
              ); // 12 недель
              periodText = textLang('За последние 12 недель');
              break;
            case 2:
              startDate = DateTime.now().subtract(
                const Duration(days: 365),
              ); // 12 месяцев
              periodText = textLang('За последние 12 месяцев');
              break;
            default:
              startDate = DateTime.now().subtract(const Duration(days: 30));
              periodText = textLang('За последние 30 дней');
          }

          // Фильтруем измерения по выбранному периоду
          final filteredMetrics = weightMetrics
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

              // Информация о весе
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBulletPoint(
                      textLang('Исходный вес'),
                      '$initialWeight кг',
                      Colors.black,
                    ),
                    _buildBulletPoint(
                      textLang('Желаемый вес'),
                      '$targetWeight кг',
                      AppColor.green,
                    ),
                    _buildBulletPoint(
                      textLang('Сейчас'),
                      '${currentWeight.toStringAsFixed(1)} кг',
                      Colors.black,
                    ),
                    _buildBulletPoint(
                      textLang('Разница'),
                      '$weightDifferenceText кг',
                      weightDifference <= 0 ? AppColor.green : Colors.red,
                    ),
                    // Прогноз - обязательно отображаем
                    _buildBulletPoint(
                      textLang('Прогноз'),
                      forecastData != null
                          ? forecastData['text']!
                          : textLang('Недостаточно данных'),
                      forecastData != null
                          ? forecastData['color'] as Color
                          : AppColor.greyText,
                    ),
                  ],
                ),
              ),

              // График веса
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppColor.darkBlue,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: filteredMetrics.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.show_chart,
                                  size: 64,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  textLang(
                                    'Нет данных для отображения графика',
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  textLang(
                                    'Добавьте измерения веса для просмотра динамики',
                                  ),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : _buildWeightChart(filteredMetrics, targetWeight),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Map<String, dynamic>? _calculateForecast(
    List<HealthMetric> weightMetrics,
    double targetWeight,
    double initialWeight,
    DateTime goalCreatedDate,
  ) {
    // Если есть измерения веса, используем их
    if (weightMetrics.isNotEmpty) {
      // Берем последние 30 дней или все доступные данные
      final recentMetrics = weightMetrics.take(30).toList();

      // Сортируем по дате (старые сначала для расчета тренда)
      recentMetrics.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      final firstWeight = double.tryParse(recentMetrics.first.value) ?? 0;
      final lastWeight = double.tryParse(recentMetrics.last.value) ?? 0;
      final daysDifference = recentMetrics.last.timestamp
          .difference(recentMetrics.first.timestamp)
          .inDays;

      // Если есть только одно измерение, сравниваем с изначальным весом
      if (recentMetrics.length == 1) {
        final currentWeight = double.tryParse(recentMetrics.first.value) ?? 0;
        final daysSinceGoalCreated = recentMetrics.first.timestamp
            .difference(goalCreatedDate)
            .inDays;

        if (daysSinceGoalCreated > 0) {
          final weightChangePerDay =
              (currentWeight - initialWeight) / daysSinceGoalCreated;
          return _calculateForecastFromTrend(
            weightChangePerDay,
            currentWeight,
            targetWeight,
          );
        }
      }

      // Если есть несколько измерений и они не в один день
      if (recentMetrics.length >= 2 && daysDifference > 0) {
        final weightChangePerDay = (lastWeight - firstWeight) / daysDifference;
        return _calculateForecastFromTrend(
          weightChangePerDay,
          lastWeight,
          targetWeight,
        );
      }
    }

    // Если измерений нет совсем, но есть изначальный и текущий вес
    final currentWeight = weightMetrics.isNotEmpty
        ? double.tryParse(weightMetrics.first.value) ?? initialWeight
        : initialWeight;

    // Если текущий вес отличается от изначального, значит есть прогресс
    if ((currentWeight - initialWeight).abs() > 0.1) {
      // Рассчитываем изменение с момента создания цели
      final daysSinceGoalCreated = DateTime.now()
          .difference(goalCreatedDate)
          .inDays;
      if (daysSinceGoalCreated > 0) {
        final weightChangePerDay =
            (currentWeight - initialWeight) / daysSinceGoalCreated;
        return _calculateForecastFromTrend(
          weightChangePerDay,
          currentWeight,
          targetWeight,
        );
      }
    }

    // Если вес не изменился
    return {
      'text': textLang('Добавьте измерения для прогноза'),
      'color': AppColor.greyText,
    };
  }

  Map<String, dynamic> _calculateForecastFromTrend(
    double weightChangePerDay,
    double currentWeight,
    double targetWeight,
  ) {
    // Если нет изменений
    if (weightChangePerDay.abs() < 0.01) {
      return {'text': textLang('Вес стабилен'), 'color': AppColor.greyText};
    }

    // Рассчитываем, сколько нужно сбросить/набрать до цели
    final weightToTarget = targetWeight - currentWeight;

    // Если уже достигли цели
    if (weightToTarget.abs() < 0.5) {
      return {'text': textLang('Цель достигнута!'), 'color': AppColor.green};
    }

    // Проверяем, движемся ли в правильном направлении
    final movingTowardsTarget =
        (weightToTarget > 0 && weightChangePerDay > 0) ||
        (weightToTarget < 0 && weightChangePerDay < 0);

    if (!movingTowardsTarget) {
      final direction = weightToTarget > 0
          ? textLang('набирать')
          : textLang('снижать');
      return {'text': textLang('Нужно $direction вес'), 'color': Colors.red};
    }

    // Рассчитываем дни до достижения цели
    final daysToTarget = (weightToTarget / weightChangePerDay).abs().round();
    final targetDate = DateTime.now().add(Duration(days: daysToTarget));

    // Получаем целевую дату из главной цели пользователя
    final userRepository = Get.find<UserRepository>();
    final goalTargetDate = userRepository.user.mainGoal.targetDate;

    // Определяем цвет на основе сравнения с целевой датой
    Color forecastColor;
    if (goalTargetDate != null) {
      if (targetDate.isBefore(goalTargetDate) ||
          targetDate.isAtSameMomentAs(goalTargetDate)) {
        // Прогноз достижения раньше или в срок - зеленый
        forecastColor = AppColor.green;
      } else {
        final daysDifference = targetDate.difference(goalTargetDate).inDays;
        if (daysDifference <= 7) {
          // Опоздание до недели - оранжевый
          forecastColor = Colors.orange;
        } else {
          // Опоздание больше недели - красный
          forecastColor = Colors.red;
        }
      }
    } else {
      // Если целевая дата не установлена - синий (нейтральный)
      forecastColor = AppColor.darkBlue;
    }

    // Форматируем дату - только дни и месяцы
    String formattedText;
    if (daysToTarget < 30) {
      formattedText = textLang(
        'через $daysToTarget дн. (${_formatTargetDate(targetDate)})',
      );
    } else {
      final months = (daysToTarget / 30).round();
      formattedText = textLang(
        'через $months мес. (${_formatTargetDate(targetDate)})',
      );
    }

    return {'text': formattedText, 'color': forecastColor};
  }

  String _formatTargetDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
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

  Widget _buildWeightChart(List<HealthMetric> metrics, double targetWeight) {
    // Находим минимальное и максимальное значение для оси Y
    double minY = double.infinity;
    double maxY = 0;

    // Добавляем целевой вес в расчет
    if (targetWeight < minY) minY = targetWeight;
    if (targetWeight > maxY) maxY = targetWeight;

    // Добавляем веса из измерений
    for (final metric in metrics) {
      final weight = double.tryParse(metric.value) ?? 0;
      if (weight < minY) minY = weight;
      if (weight > maxY) maxY = weight;
    }

    // Добавляем отступ для оси Y
    minY = (minY - 10).clamp(0, double.infinity);
    maxY = maxY + 10;

    // Создаем точки для графика
    final spots = metrics.map((metric) {
      final weight = double.tryParse(metric.value) ?? 0;
      // Используем timestamp как x-координату (в днях от начала периода)
      final days = metric.timestamp
          .difference(metrics.first.timestamp)
          .inDays
          .toDouble();
      return FlSpot(days, weight);
    }).toList();

    // Создаем горизонтальную линию для целевого веса
    final targetLine = [
      FlSpot(0, targetWeight),
      FlSpot(
        metrics.last.timestamp
            .difference(metrics.first.timestamp)
            .inDays
            .toDouble(),
        targetWeight,
      ),
    ];

    // Определяем даты для оси X
    final firstDate = metrics.first.timestamp;
    final lastDate = metrics.last.timestamp;
    final daysDifference = lastDate.difference(firstDate).inDays;

    // Определяем интервал для меток на оси X
    int interval = 5;
    if (daysDifference > 60) interval = 10;
    if (daysDifference > 120) interval = 20;
    if (daysDifference > 240) interval = 30;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          horizontalInterval: 10,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.white.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                // Показываем даты на оси X
                if (value.toInt() % interval != 0) {
                  return const SizedBox.shrink();
                }

                final date = firstDate.add(Duration(days: value.toInt()));
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 10,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: daysDifference.toDouble(),
        minY: minY,
        maxY: maxY,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final date = firstDate.add(Duration(days: spot.x.toInt()));
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)} кг\n${_formatDate(date)}',
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          // Линия веса
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.white,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: AppColor.darkBlue,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          // Линия целевого веса
          LineChartBarData(
            spots: targetLine,
            isCurved: false,
            color: AppColor.green,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            dashArray: [5, 5], // Пунктирная линия
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
