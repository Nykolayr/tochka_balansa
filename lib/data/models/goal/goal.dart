import 'package:tochka_balansa/core/l10n/language_manager.dart';

/// Цель пользователя по весу
class WeightGoal {
  final GoalType goalType; // Тип цели
  final DeadlineType deadlineType; // Тип срока
  final DateTime? deadline; // Срок
  final double targetWeight; // Цель по весу
  final String ourGoal; // Своя цель

  WeightGoal({
    required this.goalType,
    required this.deadlineType,
    required this.deadline,
    required this.targetWeight,
    required this.ourGoal,
  });

  factory WeightGoal.fromJson(Map<String, dynamic> json) {
    return WeightGoal(
      goalType: json['goalType'],
      deadlineType: json['deadlineType'],
      deadline: json['deadline'],
      targetWeight: json['targetWeight'],
      ourGoal: json['ourGoal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goalType': goalType,
      'deadlineType': deadlineType,
      'deadline': deadline,
      'targetWeight': targetWeight,
      'ourGoal': ourGoal,
    };
  }

  factory WeightGoal.init() {
    return WeightGoal(
      goalType: GoalType.none,
      deadlineType: DeadlineType.fixed,
      deadline: null,
      targetWeight: 0,
      ourGoal: '',
    );
  }
}

/// Тип цели
enum GoalType {
  loseWeight,
  gainWeight,
  maintain,
  none;

  String get title => switch (this) {
    GoalType.loseWeight => textLang('Сбросить вес'),
    GoalType.gainWeight => textLang('Набрать вес'),
    GoalType.maintain => textLang('Поддерживать вес'),
    GoalType.none => textLang('Не выбрано'),
  };

  String get description => switch (this) {
    GoalType.loseWeight => textLang('Сбросить вес'),
    GoalType.gainWeight => textLang('Набрать вес'),
    GoalType.maintain => textLang('Поддерживать вес'),
    GoalType.none => textLang('Не выбрано'),
  };
}

/// Тип срока
enum DeadlineType {
  fixed,
  flexible;

  String get title => switch (this) {
    DeadlineType.fixed => textLang('Фиксированная'),
    DeadlineType.flexible => textLang('Не ограниченная'),
  };

  String get deadlineTitle => switch (this) {
    DeadlineType.fixed => textLang('Фиксированная'),
    DeadlineType.flexible => textLang('Не ограниченная'),
  };
}
