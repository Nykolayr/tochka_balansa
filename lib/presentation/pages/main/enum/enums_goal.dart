enum GoalType {
  loseWeight,
  gainWeight,
  maintain,
  none;

  String get title => switch (this) {
    loseWeight => 'Сбросить вес',
    gainWeight => 'Набрать вес',
    maintain => 'Поддерживать вес',
    none => 'Без цели',
  };
}

enum DeadlineType {
  fixed,
  flexible;

  String get title => switch (this) {
    fixed => 'Фиксированная',
    flexible => 'Неограниченная',
  };
}
