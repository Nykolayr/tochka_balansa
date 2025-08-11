/// Уровни активности и их коэффициенты
enum ActivityLevel {
  sedentary, // Сидячий образ жизни
  lightlyActive, // Легкая активность
  moderatelyActive, // Умеренная активность
  veryActive, // Высокая активность
  extremelyActive; // Очень высокая активность

  double get multiplier => switch (this) {
    sedentary => 1.2, // Работа за столом, минимум движения
    lightlyActive => 1.375, // Легкие упражнения 1-3 раза в неделю
    moderatelyActive => 1.55, // Умеренные упражнения 3-5 раз в неделю
    veryActive => 1.725, // Интенсивные упражнения 6-7 раз в неделю
    extremelyActive => 1.9, // Очень интенсивные упражнения, физическая работа
  };

  String get title => switch (this) {
    sedentary => 'Сидячий образ жизни',
    lightlyActive => 'Легкая активность',
    moderatelyActive => 'Умеренная активность',
    veryActive => 'Высокая активность',
    extremelyActive => 'Очень высокая активность',
  };
}
