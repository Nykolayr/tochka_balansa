/// Сервис для расчета калорий от шагов
class StepsCaloriesCalculatorService {
  /// Рассчитать калории от шагов
  /// Формула: калории = (вес в кг × 0.04 × количество шагов) / 1000
  /// Это приблизительная формула для ходьбы в среднем темпе
  static int calculateCaloriesFromSteps({
    required double weight, // вес в кг
    required int steps, // количество шагов
  }) {
    if (weight <= 0 || steps <= 0) return 0;
    
    // Формула: калории = (вес × 0.04 × шаги) / 1000
    // Коэффициент 0.04 - это средний расход калорий на шаг для человека
    final calories = (weight * 0.04 * steps) / 1000;
    
    return calories.round();
  }

  /// Рассчитать калории от шагов с учетом темпа ходьбы
  static int calculateCaloriesFromStepsWithPace({
    required double weight, // вес в кг
    required int steps, // количество шагов
    required WalkingPace pace, // темп ходьбы
  }) {
    if (weight <= 0 || steps <= 0) return 0;
    
    // Базовый коэффициент для медленной ходьбы
    double baseCoefficient = 0.04;
    
    // Множитель в зависимости от темпа
    final paceMultiplier = switch (pace) {
      WalkingPace.slow => 0.8,      // Медленная ходьба
      WalkingPace.normal => 1.0,    // Обычная ходьба
      WalkingPace.fast => 1.3,      // Быстрая ходьба
      WalkingPace.veryFast => 1.6,  // Очень быстрая ходьба
    };
    
    final calories = (weight * baseCoefficient * steps * paceMultiplier) / 1000;
    
    return calories.round();
  }
}

/// Темп ходьбы
enum WalkingPace {
  slow,      // Медленная ходьба
  normal,    // Обычная ходьба
  fast,      // Быстрая ходьба
  veryFast;  // Очень быстрая ходьба

  String get title => switch (this) {
    slow => 'Медленно',
    normal => 'Обычно',
    fast => 'Быстро',
    veryFast => 'Очень быстро',
  };

  double get multiplier => switch (this) {
    slow => 0.8,
    normal => 1.0,
    fast => 1.3,
    veryFast => 1.6,
  };
} 