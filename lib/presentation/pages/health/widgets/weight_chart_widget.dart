import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';

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
      child: metrics.isEmpty ? _buildEmptyState() : _buildChart(),
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

  Widget _buildChart() {
    // Группируем измерения по дням и вычисляем среднее
    final groupedMetrics = <DateTime, List<HealthMetric>>{};

    for (final metric in metrics) {
      final date = DateTime(
        metric.timestamp.year,
        metric.timestamp.month,
        metric.timestamp.day,
      );

      if (!groupedMetrics.containsKey(date)) {
        groupedMetrics[date] = [];
      }
      groupedMetrics[date]!.add(metric);
    }

    // Создаем список дней с усредненными значениями
    final sortedDates = groupedMetrics.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    // Находим минимальное и максимальное значение для оси Y
    double minY = double.infinity;
    double maxY = 0;

    // Добавляем целевой вес в расчет
    if (targetWeight < minY) minY = targetWeight;
    if (targetWeight > maxY) maxY = targetWeight;

    // Создаем списки точек для графика
    List<FlSpot> weightSpots = [];

    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final dayMetrics = groupedMetrics[date]!;

      // Вычисляем среднее значение для этого дня
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

        // Используем дни от первого измерения как x-координату
        final daysDiff = date.difference(sortedDates.first).inDays.toDouble();

        weightSpots.add(FlSpot(daysDiff, avgWeight));

        // Обновляем границы оси Y
        if (avgWeight < minY) minY = avgWeight;
        if (avgWeight > maxY) maxY = avgWeight;
      }
    }

    // Добавляем отступ для оси Y
    minY = (minY - 10).clamp(0, double.infinity);
    maxY = maxY + 10;

    // Создаем горизонтальную линию для целевого веса
    final targetLine = [
      FlSpot(0, targetWeight),
      FlSpot((sortedDates.length - 1).toDouble(), targetWeight),
    ];

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
                // Показываем даты для первой и последней точки
                if (value <= 0.1) {
                  // Первая дата (индекс 0)
                  final date = sortedDates[0];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  );
                } else if (value >= 0.9) {
                  // Последняя дата (индекс 1)
                  final date = sortedDates[1];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  );
                }
                return const SizedBox.shrink();
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
        maxX: (sortedDates.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final date = sortedDates.first.add(
                  Duration(days: spot.x.toInt()),
                );
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
            spots: weightSpots,
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
