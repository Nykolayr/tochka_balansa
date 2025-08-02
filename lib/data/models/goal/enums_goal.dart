import 'package:tochka_balansa/core/l10n/language_manager.dart';

enum GoalType {
  loseWeight,
  gainWeight,
  maintain,

  none;

  String get title => switch (this) {
    loseWeight => textLang('Сбросить вес'),
    gainWeight => textLang('Набрать вес'),
    maintain => textLang('Поддерживать вес'),

    none => textLang('Без цели'),
  };

  String get description => switch (this) {
    loseWeight => textLang('Постепенно снижать вес до целевого значения'),
    gainWeight => textLang('Набирать мышечную массу и вес'),
    maintain => textLang('Сохранять текущий вес в стабильном состоянии'),
    none => textLang('Не устанавливать цель по весу'),
  };
}

enum DeadlineType {
  fixed,
  flexible;

  String get title => switch (this) {
    fixed => textLang('Фиксированная'),
    flexible => textLang('Неограниченная'),
  };

  String get description => switch (this) {
    fixed => textLang('Установить конкретную дату достижения цели'),
    flexible => textLang('Достигать цель в удобном для вас темпе'),
  };
}

enum TimeInterval {
  twoWeeks,
  oneMonth,
  twoMonths,
  threeMonths,
  fourMonths,
  fiveMonths,
  sixMonths,
  sevenMonths,
  eightMonths,
  nineMonths,
  twelveMonths,
  twentyFourMonths;

  String get title => switch (this) {
    twoWeeks => textLang('2 недели'),
    oneMonth => textLang('1 месяц'),
    twoMonths => textLang('2 месяца'),
    threeMonths => textLang('3 месяца'),
    fourMonths => textLang('4 месяца'),
    fiveMonths => textLang('5 месяцев'),
    sixMonths => textLang('6 месяцев'),
    sevenMonths => textLang('7 месяцев'),
    eightMonths => textLang('8 месяцев'),
    nineMonths => textLang('9 месяцев'),
    twelveMonths => textLang('12 месяцев'),
    twentyFourMonths => textLang('24 месяца'),
  };

  int get days => switch (this) {
    twoWeeks => 14,
    oneMonth => 30,
    twoMonths => 60,
    threeMonths => 90,
    fourMonths => 120,
    fiveMonths => 150,
    sixMonths => 180,
    sevenMonths => 210,
    eightMonths => 240,
    nineMonths => 270,
    twelveMonths => 365,
    twentyFourMonths => 730,
  };

  Duration get duration => Duration(days: days);

  String get shortTitle => switch (this) {
    twoWeeks => '2 нед',
    oneMonth => '1 мес',
    twoMonths => '2 мес',
    threeMonths => '3 мес',
    fourMonths => '4 мес',
    fiveMonths => '5 мес',
    sixMonths => '6 мес',
    sevenMonths => '7 мес',
    eightMonths => '8 мес',
    nineMonths => '9 мес',
    twelveMonths => '12 мес',
    twentyFourMonths => '24 мес',
  };
}
