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
    // Находим минимальное и максимальное значение для оси Y
    double minY = double.infinity;
    double maxY = 0;

    // Создаем списки точек для каждой линии
    List<FlSpot> systolicSpots = [];
    List<FlSpot> diastolicSpots = [];
    List<FlSpot> pulseSpots = [];

    for (int i = 0; i < metrics.length; i++) {
      final metric = metrics[i];
      final value = metric.value;

      if (value.contains('/')) {
        final parts = value.split('/');
        if (parts.length == 3) {
          final systolic = double.tryParse(parts[0]) ?? 0;
          final diastolic = double.tryParse(parts[1]) ?? 0;
          final pulse = double.tryParse(parts[2]) ?? 0;

          // Используем индекс как x-координату для равномерного распределения
          final x = i.toDouble();

          systolicSpots.add(FlSpot(x, systolic));
          diastolicSpots.add(FlSpot(x, diastolic));
          pulseSpots.add(FlSpot(x, pulse));

          // Обновляем границы оси Y
          if (systolic < minY) minY = systolic;
          if (systolic > maxY) maxY = systolic;
          if (diastolic < minY) minY = diastolic;
          if (diastolic > maxY) maxY = diastolic;
          if (pulse < minY) minY = pulse;
          if (pulse > maxY) maxY = pulse;
        }
      }
    }

    // Добавляем отступ для оси Y
    minY = (minY - 20).clamp(0, double.infinity);
    maxY = maxY + 20;

    // Определяем интервал для меток на оси X
    int interval = 1;
    if (metrics.length > 10) interval = 2;
    if (metrics.length > 20) interval = 3;
    if (metrics.length > 30) interval = 5;

    return LineChart(
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
                final index = value.toInt();
                if (index < 0 ||
                    index >= metrics.length ||
                    index % interval != 0) {
                  return const SizedBox.shrink();
                }

                final date = metrics[index].timestamp;
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
              interval: 20,
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
        maxX: (metrics.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index < 0 || index >= metrics.length) return null;

                final date = metrics[index].timestamp;
                final metric = metrics[index];
                final parts = metric.value.split('/');

                String label = '';
                Color color = Colors.white;

                if (spot.barIndex == 0) {
                  label = 'Систолическое: ${parts[0]} мм рт.ст.';
                  color = Colors.red;
                } else if (spot.barIndex == 1) {
                  label = 'Диастолическое: ${parts[1]} мм рт.ст.';
                  color = Colors.orange;
                } else if (spot.barIndex == 2) {
                  label = 'Пульс: ${parts[2]} уд/мин';
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
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
