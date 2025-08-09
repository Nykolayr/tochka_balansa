import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';

class WeightForecastWidget extends StatelessWidget {
  final List<HealthMetric> weightMetrics;
  final double targetWeight;
  final double initialWeight;

  const WeightForecastWidget({
    super.key,
    required this.weightMetrics,
    required this.targetWeight,
    required this.initialWeight,
  });

  @override
  Widget build(BuildContext context) {
    final forecastData = _calculateForecast();

    return Row(
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
        Text(
          '${textLang('Прогноз')}: ',
          style: const TextStyle(color: Colors.black),
        ),
        Text(
          forecastData['text']!,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: forecastData['color'] as Color,
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _calculateForecast() {
    // Используем примерную дату начала цели (месяц назад)
    final goalCreatedDate = DateTime.now().subtract(const Duration(days: 30));

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
          return _calculateForecastFromTrend(weightChangePerDay, currentWeight);
        }
      }

      // Если есть несколько измерений и они не в один день
      if (recentMetrics.length >= 2 && daysDifference > 0) {
        final weightChangePerDay = (lastWeight - firstWeight) / daysDifference;
        return _calculateForecastFromTrend(weightChangePerDay, lastWeight);
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
        return _calculateForecastFromTrend(weightChangePerDay, currentWeight);
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
}
