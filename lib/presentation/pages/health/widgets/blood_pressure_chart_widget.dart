import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';

class BloodPressureChartWidget extends StatelessWidget {
  final List<HealthMetric> metrics;

  const BloodPressureChartWidget({super.key, required this.metrics});

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
          const Icon(Icons.favorite, size: 64, color: Colors.white),
          const SizedBox(height: 16),
          Text(
            textLang('Нет данных для отображения графика'),
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            textLang(
              'Добавьте измерения давления и пульса для просмотра динамики',
            ),
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

    // Создаем списки точек для каждой линии
    List<FlSpot> systolicSpots = [];
    List<FlSpot> diastolicSpots = [];
    List<FlSpot> pulseSpots = [];

    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final dayMetrics = groupedMetrics[date]!;

      // Вычисляем среднее значение для этого дня
      double totalSystolic = 0;
      double totalDiastolic = 0;
      double totalPulse = 0;
      int validCount = 0;

      for (final metric in dayMetrics) {
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

      if (validCount > 0) {
        final avgSystolic = totalSystolic / validCount;
        final avgDiastolic = totalDiastolic / validCount;
        final avgPulse = totalPulse / validCount;

        // Используем дни от первого измерения как x-координату
        final daysDiff = date.difference(sortedDates.first).inDays.toDouble();

        systolicSpots.add(FlSpot(daysDiff, avgSystolic));
        diastolicSpots.add(FlSpot(daysDiff, avgDiastolic));
        pulseSpots.add(FlSpot(daysDiff, avgPulse));

        // Обновляем границы оси Y
        if (avgSystolic < minY) minY = avgSystolic;
        if (avgSystolic > maxY) maxY = avgSystolic;
        if (avgDiastolic < minY) minY = avgDiastolic;
        if (avgDiastolic > maxY) maxY = avgDiastolic;
        if (avgPulse < minY) minY = avgPulse;
        if (avgPulse > maxY) maxY = avgPulse;
      }
    }

    // Добавляем отступ для оси Y
    minY = (minY - 20).clamp(0, double.infinity);
    maxY = maxY + 20;

    // Определяем интервал для меток на оси X
    final totalDays = sortedDates.last.difference(sortedDates.first).inDays;
    int interval = 5;
    if (totalDays > 60) interval = 10;
    if (totalDays > 120) interval = 20;
    if (totalDays > 240) interval = 30;

    return Column(
      children: [
        // График
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                drawHorizontalLine: true,
                horizontalInterval: 20,
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
                      if (value.toInt() % interval != 0) {
                        return const SizedBox.shrink();
                      }

                      final date = sortedDates.first.add(
                        Duration(days: value.toInt()),
                      );
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 20,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: totalDays.toDouble(),
              minY: minY,
              maxY: maxY,
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final date = sortedDates.first.add(
                        Duration(days: spot.x.toInt()),
                      );

                      String label = '';
                      Color color = Colors.white;

                      if (spot.barIndex == 0) {
                        label =
                            'Систолическое: ${spot.y.toStringAsFixed(1)} мм рт.ст.';
                        color = Colors.red;
                      } else if (spot.barIndex == 1) {
                        label =
                            'Диастолическое: ${spot.y.toStringAsFixed(1)} мм рт.ст.';
                        color = Colors.orange;
                      } else if (spot.barIndex == 2) {
                        label = 'Пульс: ${spot.y.toStringAsFixed(1)} уд/мин';
                        color = AppColor.green;
                      }

                      return LineTooltipItem(
                        '$label\n${_formatDate(date)}',
                        TextStyle(color: color),
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: [
                // Линия систолического давления (красная)
                LineChartBarData(
                  spots: systolicSpots,
                  isCurved: true,
                  color: Colors.red,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: Colors.red,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                ),
                // Линия диастолического давления (оранжевая)
                LineChartBarData(
                  spots: diastolicSpots,
                  isCurved: true,
                  color: Colors.orange,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: Colors.orange,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                ),
                // Линия пульса (зеленая)
                LineChartBarData(
                  spots: pulseSpots,
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
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Легенда
        const SizedBox(height: 16),
        _buildLegend(),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem(color: Colors.red, label: textLang('Систолическое')),
        _buildLegendItem(
          color: Colors.orange,
          label: textLang('Диастолическое'),
        ),
        _buildLegendItem(color: AppColor.green, label: textLang('Пульс')),
      ],
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
