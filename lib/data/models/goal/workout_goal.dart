import 'package:tochka_balansa/data/models/goal/additional_goal.dart';

/// Цель по тренировкам
class WorkoutGoal extends AdditionalGoal {
  final String activityType;
  final int targetSessionsPerWeek;

  WorkoutGoal({
    required this.activityType,
    required this.targetSessionsPerWeek,
    required super.reminders,
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
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    activityType,
    targetSessionsPerWeek,
  ];
}
