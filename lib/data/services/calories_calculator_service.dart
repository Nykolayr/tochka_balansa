import 'package:tochka_balansa/data/models/health/activity_level.dart';

/// Сервис для расчета калорий
class CaloriesCalculatorService {
  /// Рассчитать базовый обмен веществ (BMR) по формуле Миффлина-Сан Жеора
  /// Это количество калорий, которое организм тратит в состоянии покоя
  static int calculateBMR({
    required int age,
    required String gender,
    required double weight, // в кг
    required double height, // в см
  }) {
    // Формула Миффлина-Сан Жеора (более точная чем Харриса-Бенедикта)
    double bmr;

    if (gender == 'male') {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }

    return bmr.round();
  }

  /// Рассчитать общий расход калорий с учетом уровня активности
  static int calculateTotalCalories({
    required int bmr,
    required ActivityLevel activityLevel,
  }) {
    return (bmr * activityLevel.multiplier).round();
  }

  /// Получить рекомендуемый уровень активности по умолчанию
  static ActivityLevel getDefaultActivityLevel() {
    return ActivityLevel.sedentary; // По умолчанию сидячий
  }
}
