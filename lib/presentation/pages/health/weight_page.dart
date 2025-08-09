import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
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
      backgroundColor: const Color(0xFF1A1E2E), // Темный фон как на скриншоте
      appBar: AppBarWidget(title: textLang('Вес'), isBack: true),
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
              TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: AppColor.greyText,
                indicatorColor: AppColor.darkBlue,
                tabs: [
                  Tab(text: textLang('ПО ДНЯМ')),
                  Tab(text: textLang('ПО НЕДЕЛЯМ')),
                  Tab(text: textLang('ПО МЕСЯЦАМ')),
                ],
              ),

              // Заголовок периода
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  periodText,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
                      Colors.white,
                    ),
                    _buildBulletPoint(
                      textLang('Желаемый вес'),
                      '$targetWeight кг',
                      AppColor.green,
                    ),
                    _buildBulletPoint(
                      textLang('Сейчас'),
                      '$currentWeight кг',
                      Colors.white,
                    ),
                    _buildBulletPoint(
                      textLang('Разница'),
                      '$weightDifferenceText кг',
                      weightDifference <= 0 ? AppColor.green : AppColor.red,
                    ),
                  ],
                ),
              ),

              // График веса
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 250,
                  child: filteredMetrics.isEmpty
                      ? Center(
                          child: Text(
                            textLang('Нет данных для отображения графика'),
                            style: TextStyle(color: AppColor.greyText),
                          ),
                        )
                      : _buildWeightChart(filteredMetrics, targetWeight),
                ),
              ),

              // Заголовок истории
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  textLang('История'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              // Список измерений веса
              Expanded(
                child: weightMetrics.isEmpty
                    ? Center(
                        child: Text(
                          textLang('История измерений веса пуста'),
                          style: TextStyle(color: AppColor.greyText),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: weightMetrics.length,
                        itemBuilder: (context, index) {
                          final metric = weightMetrics[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _formatDate(metric.timestamp),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      textLang(
                                        'время измерения: ${_formatTime(metric.timestamp)}',
                                      ),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColor.greyText,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '${double.parse(metric.value).toStringAsFixed(1)} кг',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: AppColor.greyText,
                                      ),
                                      onPressed: () => _showDeleteConfirmation(
                                        context,
                                        metric,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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

  Widget _buildBulletPoint(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: Colors.white)),
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
              color: AppColor.greyText.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: AppColor.greyText.withValues(alpha: 0.2),
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
                if (value.toInt() % interval != 0)
                  return const SizedBox.shrink();

                final date = firstDate.add(Duration(days: value.toInt()));
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}',
                    style: TextStyle(color: AppColor.greyText, fontSize: 10),
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
                  style: TextStyle(color: AppColor.greyText, fontSize: 10),
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
            color: AppColor.darkBlue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColor.darkBlue,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColor.darkBlue.withValues(alpha: 0.2),
            ),
          ),
          // Линия целевого веса
          LineChartBarData(
            spots: targetLine,
            isCurved: false,
            color: AppColor.green,
            barWidth: 1,
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
