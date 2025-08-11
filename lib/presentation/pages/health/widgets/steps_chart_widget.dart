import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'chart_utils.dart';

class StepsChartWidget extends StatelessWidget {
  final List<HealthMetric> metrics;
  final int selectedTabIndex;

  const StepsChartWidget({
    super.key,
    required this.metrics,
    required this.selectedTabIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) {
      return Center(
        child: Text(
          'Нет данных для отображения графика',
          style: TextStyle(color: AppColor.greyText, fontSize: 16),
        ),
      );
    }

    return Container(
      height: 350,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: Column(children: [Expanded(child: _buildChart(context))]),
    );
  }

  Widget _buildChart(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final optimalPoints = ChartUtils.calculateOptimalPoints(screenWidth);

    final groupedMetrics = ChartUtils.groupMetricsByDate(metrics);
    final sortedDates = ChartUtils.sortDatesAscending(groupedMetrics);

    if (sortedDates.isEmpty) return const SizedBox.shrink();

    final keyDates = ChartUtils.selectKeyDates(sortedDates, optimalPoints);

    final stepsPoints = <FlSpot>[];

    for (int i = 0; i < keyDates.length; i++) {
      final date = keyDates[i];
      final dateMetrics = groupedMetrics[date]!;

      // Суммируем все шаги за день
      final totalSteps = dateMetrics
          .map((m) => int.tryParse(m.value) ?? 0)
          .reduce((a, b) => a + b);

      stepsPoints.add(FlSpot(i.toDouble(), totalSteps.toDouble()));
    }

    if (stepsPoints.isEmpty) return const SizedBox.shrink();

    final allValues = stepsPoints.map((p) => p.y).toList();
    final minY = allValues.reduce((a, b) => a < b ? a : b) - 200;
    final maxY = allValues.reduce((a, b) => a > b ? a : b) + 200;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1000,
          verticalInterval: 1.0,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white.withValues(alpha: 0.3),
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: Colors.white.withValues(alpha: 0.3),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < keyDates.length) {
                  return Text(
                    ChartUtils.formatDateShort(keyDates[value.toInt()]),
                    style: const TextStyle(color: Colors.white),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1000,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        minX: 0,
        maxX: (keyDates.length - 1).toDouble(),
        minY: minY < 0 ? 0 : minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: stepsPoints,
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
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                final date = keyDates[touchedSpot.x.toInt()];
                final steps = touchedSpot.y.toInt();
                return LineTooltipItem(
                  'Шаги: $steps\n${ChartUtils.formatDateFull(date)}',
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
