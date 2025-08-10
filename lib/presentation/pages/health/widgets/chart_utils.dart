import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';

class ChartUtils {
  /// Группирует метрики по датам
  static Map<DateTime, List<HealthMetric>> groupMetricsByDate(
    List<HealthMetric> metrics,
  ) {
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

    return groupedMetrics;
  }

  /// Сортирует даты по возрастанию
  static List<DateTime> sortDatesAscending(
    Map<DateTime, List<HealthMetric>> groupedMetrics,
  ) {
    return groupedMetrics.keys.toList()..sort((a, b) => a.compareTo(b));
  }

  /// Вычисляет оптимальное количество точек на основе ширины экрана
  static int calculateOptimalPoints(double screenWidth) {
    final chartWidth = screenWidth - 32; // Учитываем padding
    final minDateWidth = 60.0; // Минимальная ширина для одной даты
    final maxPoints = (chartWidth / minDateWidth).floor();

    // Ограничиваем от 5 до 10 точек
    return maxPoints.clamp(5, 10);
  }

  /// Выбирает ключевые даты для отображения
  static List<DateTime> selectKeyDates(
    List<DateTime> sortedDates,
    int optimalPoints,
  ) {
    final keyDates = <DateTime>[];

    if (sortedDates.length <= optimalPoints) {
      // Если точек мало - показываем все
      keyDates.addAll(sortedDates);
    } else {
      // Выбираем равномерно распределенные даты
      final step = (sortedDates.length - 1) / (optimalPoints - 1);
      for (int i = 0; i < optimalPoints; i++) {
        final index = (i * step).round();
        if (index < sortedDates.length) {
          keyDates.add(sortedDates[index]);
        }
      }
    }

    return keyDates;
  }

  /// Создает базовую конфигурацию сетки для графика
  static FlGridData createGridData() {
    return FlGridData(
      show: true,
      drawVerticalLine: true,
      drawHorizontalLine: true,
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
    );
  }

  /// Создает базовую конфигурацию границ для графика
  static FlBorderData createBorderData() {
    return FlBorderData(
      show: true,
      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
    );
  }

  /// Создает базовую конфигурацию заголовков для графика
  static FlTitlesData createTitlesData(
    List<DateTime> keyDates,
    String Function(DateTime) dateFormatter,
  ) {
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                dateFormatter(date),
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
    );
  }

  /// Форматирует дату в формате dd.MM
  static String formatDateShort(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}';
  }

  /// Форматирует дату в формате dd.MM.yyyy
  static String formatDateFull(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
