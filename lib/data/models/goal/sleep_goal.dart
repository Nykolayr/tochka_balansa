import 'package:flutter/material.dart';
import 'package:tochka_balansa/data/models/goal/additional_goal.dart';
import 'package:tochka_balansa/data/models/goal/enums_goal.dart';

class SleepGoal extends AdditionalGoal {
  final TimeOfDay bedtime;
  final TimeOfDay wakeupTime;

  SleepGoal({
    required this.bedtime,
    required this.wakeupTime,
    required super.reminders,
    required super.deadlineType,
    super.targetDate,
    String? id,
    String? title,
    String? description,
    bool? isActive,
  }) : super(
         id: id ?? 'sleep_goal',
         title: title ?? 'Режим сна',
         description:
             description ??
             'С ${bedtime.hour.toString().padLeft(2, '0')}:${bedtime.minute.toString().padLeft(2, '0')} до ${wakeupTime.hour.toString().padLeft(2, '0')}:${wakeupTime.minute.toString().padLeft(2, '0')}',
         isActive: isActive ?? true,
       );

  factory SleepGoal.init() {
    return SleepGoal(
      bedtime: const TimeOfDay(hour: 22, minute: 0),
      wakeupTime: const TimeOfDay(hour: 7, minute: 0),
      reminders: const [],
      deadlineType: DeadlineType.flexible,
    );
  }

  factory SleepGoal.fromJson(Map<String, dynamic> json) {
    final bedtimeStr = json['bedtime'] as String? ?? '22:00';
    final wakeupTimeStr = json['wakeupTime'] as String? ?? '07:00';

    final bedtimeParts = bedtimeStr.split(':');
    final wakeupTimeParts = wakeupTimeStr.split(':');

    final bedtime = TimeOfDay(
      hour: int.parse(bedtimeParts[0]),
      minute: int.parse(bedtimeParts[1]),
    );

    final wakeupTime = TimeOfDay(
      hour: int.parse(wakeupTimeParts[0]),
      minute: int.parse(wakeupTimeParts[1]),
    );

    final reminders =
        (json['reminders'] as List<dynamic>?)
            ?.map((e) => Reminder.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [
          Reminder(time: bedtime, repeatDays: [1, 2, 3, 4, 5, 6, 7]),
        ];

    return SleepGoal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isActive: json['isActive'] ?? true,
      bedtime: bedtime,
      wakeupTime: wakeupTime,
      reminders: reminders,
      deadlineType: DeadlineType.values.firstWhere(
        (e) => e.name == json['deadlineType'],
        orElse: () => DeadlineType.flexible,
      ),
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'sleep',
    'id': id,
    'title': title,
    'description': description,
    'isActive': isActive,
    'bedtime':
        '${bedtime.hour.toString().padLeft(2, '0')}:${bedtime.minute.toString().padLeft(2, '0')}',
    'wakeupTime':
        '${wakeupTime.hour.toString().padLeft(2, '0')}:${wakeupTime.minute.toString().padLeft(2, '0')}',
    'reminders': reminders.map((r) => r.toJson()).toList(),
    'deadlineType': deadlineType.name,
    'targetDate': targetDate?.toIso8601String(),
  };

  @override
  SleepGoal copyWith({
    String? id,
    String? title,
    String? description,
    bool? isActive,
    List<Reminder>? reminders,
    TimeOfDay? bedtime,
    TimeOfDay? wakeupTime,
    DeadlineType? deadlineType,
    DateTime? targetDate,
  }) {
    return SleepGoal(
      id: id,
      title: title,
      description: description,
      isActive: isActive,
      reminders: reminders ?? this.reminders,
      bedtime: bedtime ?? this.bedtime,
      wakeupTime: wakeupTime ?? this.wakeupTime,
      deadlineType: deadlineType ?? this.deadlineType,
      targetDate: targetDate ?? this.targetDate,
    );
  }

  @override
  double get progressPercentage {
    if (deadlineType == DeadlineType.flexible) return 0.0;

    // TODO: Реализовать логику подсчета дней с правильным режимом сна
    // Пока возвращаем заглушку
    return 0.0;
  }

  @override
  List<Object?> get props => [...super.props, bedtime, wakeupTime];
}
