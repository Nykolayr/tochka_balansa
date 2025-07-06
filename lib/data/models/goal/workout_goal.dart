import 'package:tochka_balansa/data/models/goal/additional_goal.dart';
import 'package:tochka_balansa/data/models/goal/enums_goal.dart';

/// Цель по тренировкам
class WorkoutGoal extends AdditionalGoal {
  final String activityType;
  final int targetSessionsPerWeek;

  WorkoutGoal({
    required this.activityType,
    required this.targetSessionsPerWeek,
    required super.reminders,
    required super.deadlineType,
    super.targetDate,
    String? id,
    String? title,
    String? description,
    bool? isActive,
  }) : super(
         id: id ?? 'workout_${activityType.toLowerCase()}',
         title: title ?? 'Тренировки ($activityType)',
         description: description ?? '$targetSessionsPerWeek раз в неделю',
         isActive: isActive ?? true,
       );

  factory WorkoutGoal.init() {
    return WorkoutGoal(
      activityType: 'Кардио',
      targetSessionsPerWeek: 3,
      reminders: const [],
      deadlineType: DeadlineType.fixed,
    );
  }

  factory WorkoutGoal.fromJson(Map<String, dynamic> json) {
    final reminders =
        (json['reminders'] as List<dynamic>?)
            ?.map((e) => Reminder.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return WorkoutGoal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isActive: json['isActive'] ?? true,
      activityType: json['activityType'] ?? 'Кардио',
      targetSessionsPerWeek: json['targetSessionsPerWeek'] ?? 3,
      reminders: reminders,
      deadlineType: DeadlineType.values.firstWhere(
        (e) => e.name == json['deadlineType'],
        orElse: () => DeadlineType.fixed,
      ),
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'workout',
    'id': id,
    'title': title,
    'description': description,
    'isActive': isActive,
    'activityType': activityType,
    'targetSessionsPerWeek': targetSessionsPerWeek,
    'reminders': reminders.map((r) => r.toJson()).toList(),
    'deadlineType': deadlineType.name,
    'targetDate': targetDate?.toIso8601String(),
  };

  @override
  WorkoutGoal copyWith({
    String? id,
    String? title,
    String? description,
    bool? isActive,
    List<Reminder>? reminders,
    String? activityType,
    int? targetSessionsPerWeek,
    DeadlineType? deadlineType,
    DateTime? targetDate,
  }) {
    return WorkoutGoal(
      id: id,
      title: title,
      description: description,
      isActive: isActive,
      reminders: reminders ?? this.reminders,
      activityType: activityType ?? this.activityType,
      targetSessionsPerWeek:
          targetSessionsPerWeek ?? this.targetSessionsPerWeek,
      deadlineType: deadlineType ?? this.deadlineType,
      targetDate: targetDate ?? this.targetDate,
    );
  }

  @override
  double get progressPercentage {
    if (deadlineType == DeadlineType.flexible) return 0.0;

    // TODO: Реализовать логику подсчета выполненных тренировок
    // Пока возвращаем заглушку
    return 0.0;
  }

  @override
  List<Object?> get props => [
    ...super.props,
    activityType,
    targetSessionsPerWeek,
  ];
}
