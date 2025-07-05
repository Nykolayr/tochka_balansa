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
}

enum DeadlineType {
  fixed,
  flexible;

  String get title => switch (this) {
    fixed => textLang('Фиксированная'),
    flexible => textLang('Неограниченная'),
  };
}
