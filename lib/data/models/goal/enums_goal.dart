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
