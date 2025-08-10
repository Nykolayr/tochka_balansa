import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';

class BloodPressureChartWidget extends StatelessWidget {
  final List<HealthMetric> metrics;
  final int selectedTabIndex;

  const BloodPressureChartWidget({
    super.key,
    required this.metrics,
    required this.selectedTabIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 300,
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
      child: _buildChart(context),
    );
  }

  Widget _buildChart(BuildContext context) {
    // Получаем ширину экрана
    final screenWidth = MediaQuery.of(context).size.width;
    final chartWidth = screenWidth - 32; // Учитываем padding

    // Вычисляем оптимальное количество точек
    // Предполагаем, что на каждую дату нужно минимум 60px
    final minDateWidth = 60.0;
    final maxPoints = (chartWidth / minDateWidth).floor();

    // Ограничиваем от 5 до 10 точек
    final optimalPoints = maxPoints.clamp(5, 10);

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

    // Сортируем даты по возрастанию (старые сначала)
    final sortedDates = groupedMetrics.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    if (sortedDates.isEmpty) return const SizedBox.shrink();

    // Выбираем ключевые даты для отображения
    final keyDates = <DateTime>[];
    if (sortedDates.length <= optimalPoints) {
      keyDates.addAll(sortedDates);
    } else {
      // Равномерно распределяем даты
      final step = (sortedDates.length - 1) / (optimalPoints - 1);
      for (int i = 0; i < optimalPoints; i++) {
        final index = (i * step).round();
        if (index < sortedDates.length) {
          keyDates.add(sortedDates[index]);
        }
      }
    }

    // Создаем точки для каждого типа измерения
    final systolicPoints = <FlSpot>[];
    final diastolicPoints = <FlSpot>[];
    final pulsePoints = <FlSpot>[];

    for (int i = 0; i < keyDates.length; i++) {
      final date = keyDates[i];
      final dateMetrics = groupedMetrics[date]!;

      // Вычисляем средние значения для каждого типа
      final systolicValues = <double>[];
      final diastolicValues = <double>[];
      final pulseValues = <double>[];

      for (final metric in dateMetrics) {
        if (metric.type == HealthMetricType.bloodPressureAndPulse) {
          final parts = metric.value.split('/');
          if (parts.length == 3) {
            final systolic = double.tryParse(parts[0]) ?? 0;
            final diastolic = double.tryParse(parts[1]) ?? 0;
            final pulse = double.tryParse(parts[2]) ?? 0;

            if (systolic > 0) systolicValues.add(systolic);
            if (diastolic > 0) diastolicValues.add(diastolic);
            if (pulse > 0) pulseValues.add(pulse);
          }
        }
      }

      if (systolicValues.isNotEmpty) {
        systolicPoints.add(
          FlSpot(
            i.toDouble(),
            systolicValues.reduce((a, b) => a + b) / systolicValues.length,
          ),
        );
      }

      if (diastolicValues.isNotEmpty) {
        diastolicPoints.add(
          FlSpot(
            i.toDouble(),
            diastolicValues.reduce((a, b) => a + b) / diastolicValues.length,
          ),
        );
      }

      if (pulseValues.isNotEmpty) {
        pulsePoints.add(
          FlSpot(
            i.toDouble(),
            pulseValues.reduce((a, b) => a + b) / pulseValues.length,
          ),
        );
      }
    }

    // Определяем диапазон значений для Y оси
    final allValues = [
      ...systolicPoints.map((p) => p.y),
      ...diastolicPoints.map((p) => p.y),
      ...pulsePoints.map((p) => p.y),
    ];

    if (allValues.isEmpty) {
      return const SizedBox.shrink();
    }

    final minY = allValues.reduce((a, b) => a < b ? a : b) - 10;
    final maxY = allValues.reduce((a, b) => a > b ? a : b) + 10;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 20,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white.withValues(alpha: 0.3),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.white.withValues(alpha: 0.3),
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
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= keyDates.length) {
                  return const SizedBox.shrink();
                }

                final date = keyDates[value.toInt()];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('dd.MM').format(date),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
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
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        minX: 0,
        maxX: (keyDates.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          // Систолическое давление (красная линия)
          LineChartBarData(
            spots: systolicPoints,
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
            belowBarData: BarAreaData(show: false),
          ),
          // Диастолическое давление (синяя линия)
          LineChartBarData(
            spots: diastolicPoints,
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.blue,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(show: false),
          ),
          // Пульс (зеленая линия)
          LineChartBarData(
            spots: pulsePoints,
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.green,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                final date = keyDates[touchedSpot.x.toInt()];
                String label = '';

                if (touchedSpot.barIndex == 0) {
                  label = 'Систолическое: ${touchedSpot.y.toInt()}';
                } else if (touchedSpot.barIndex == 1) {
                  label = 'Диастолическое: ${touchedSpot.y.toInt()}';
                } else if (touchedSpot.barIndex == 2) {
                  label = 'Пульс: ${touchedSpot.y.toInt()}';
                }

                return LineTooltipItem(
                  '$label\n${DateFormat('dd.MM.yyyy').format(date)}',
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
