/// Цель пользователя
class UserGoal {
  final GoalType goalType; // Тип цели
  final DeadlineType deadlineType; // Тип срока
  final DateTime? deadline; // Срок
  final double targetWeight; // Цель по весу
  final String ourGoal; // Своя цель

  UserGoal({
    required this.goalType,
    required this.deadlineType,
    required this.deadline,
    required this.targetWeight,
    required this.ourGoal,
  });

  factory UserGoal.fromJson(Map<String, dynamic> json) {
    return UserGoal(
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

  factory UserGoal.init() {
    return UserGoal(
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
  none,
  our;

  String get title => switch (this) {
    GoalType.loseWeight => 'Сбросить вес',
    GoalType.gainWeight => 'Набрать вес',
    GoalType.maintain => 'Поддерживать вес',
    GoalType.none => 'Не выбрано',
    GoalType.our => 'Своя цель',
  };

  String get description => switch (this) {
    GoalType.loseWeight => 'Сбросить вес',
    GoalType.gainWeight => 'Набрать вес',
    GoalType.maintain => 'Поддерживать вес',
    GoalType.none => 'Не выбрано',
    GoalType.our => 'Своя цель',
  };
}

/// Тип срока
enum DeadlineType {
  fixed,
  flexible;

  String get title => switch (this) {
    DeadlineType.fixed => 'Фиксированная',
    DeadlineType.flexible => 'Не ограниченная',
  };
}
