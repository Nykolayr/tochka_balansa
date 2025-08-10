import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'chart_utils.dart';

class WeightChartWidget extends StatelessWidget {
  final List<HealthMetric> metrics;
  final double targetWeight;

  const WeightChartWidget({
    super.key,
    required this.metrics,
    required this.targetWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: metrics.isEmpty ? _buildEmptyState() : _buildChart(context),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.show_chart, size: 64, color: Colors.white),
          const SizedBox(height: 16),
          Text(
            textLang('Нет данных для отображения графика'),
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            textLang('Добавьте измерения веса для просмотра динамики'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    // Получаем ширину экрана
    final screenWidth = MediaQuery.of(context).size.width;
    final optimalPoints = ChartUtils.calculateOptimalPoints(screenWidth);

    // Группируем измерения по дням и вычисляем среднее
    final groupedMetrics = ChartUtils.groupMetricsByDate(metrics);
    final sortedDates = ChartUtils.sortDatesAscending(groupedMetrics);

    if (sortedDates.isEmpty) return const SizedBox.shrink();

    // Выбираем ключевые даты для отображения
    final keyDates = ChartUtils.selectKeyDates(sortedDates, optimalPoints);

    // Создаем точки для графика только из ключевых дат
    List<FlSpot> weightSpots = [];

    for (int i = 0; i < keyDates.length; i++) {
      final date = keyDates[i];
      final dayMetrics = groupedMetrics[date]!;

      double totalWeight = 0;
      int validCount = 0;

      for (final metric in dayMetrics) {
        final weight = double.tryParse(metric.value);
        if (weight != null) {
          totalWeight += weight;
          validCount++;
        }
      }

      if (validCount > 0) {
        final avgWeight = totalWeight / validCount;
        weightSpots.add(FlSpot(i.toDouble(), avgWeight));
      }
    }

    if (weightSpots.isEmpty) return const SizedBox.shrink();

    // Находим границы для оси Y
    double minY = double.infinity;
    double maxY = 0;

    for (final spot in weightSpots) {
      if (spot.y < minY) minY = spot.y;
      if (spot.y > maxY) maxY = spot.y;
    }

    if (targetWeight < minY) minY = targetWeight;
    if (targetWeight > maxY) maxY = targetWeight;

    minY = (minY - 2).clamp(0, double.infinity);
    maxY = maxY + 2;

    // Создаем линию целевого веса
    final targetLine = [
      FlSpot(0, targetWeight),
      FlSpot((weightSpots.length - 1).toDouble(), targetWeight),
    ];

    return LineChart(
      LineChartData(
        gridData: ChartUtils.createGridData(),
        titlesData: ChartUtils.createTitlesData(
          keyDates,
          ChartUtils.formatDateShort,
        ),
        borderData: ChartUtils.createBorderData(),
        minX: 0,
        maxX: (keyDates.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: weightSpots,
            isCurved: true,
            color: AppColor.green,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColor.green,
                  strokeWidth: 2,
                  strokeColor: AppColor.darkBlue,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColor.green.withValues(alpha: 0.2),
            ),
          ),
          LineChartBarData(
            spots: targetLine,
            isCurved: false,
            color: AppColor.green,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            dashArray: [5, 5],
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final date = keyDates[spot.x.toInt()];
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)} кг\n${ChartUtils.formatDateFull(date)}',
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
