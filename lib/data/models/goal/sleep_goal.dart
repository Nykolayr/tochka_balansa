import 'package:flutter/material.dart';
import 'package:tochka_balansa/data/models/goal/additional_goal.dart';

class SleepGoal extends AdditionalGoal {
  final TimeOfDay bedtime;
  final TimeOfDay wakeupTime;

  SleepGoal({
    required this.bedtime,
    required this.wakeupTime,
    String? id,
    String? title,
    String? description,
    bool? isActive,
    List<Reminder>? reminders,
  }) : super(
         id: id ?? 'sleep_goal',
         title: title ?? 'Режим сна',
         description:
             description ??
             'С ${bedtime.hour.toString().padLeft(2, '0')}:${bedtime.minute.toString().padLeft(2, '0')} до ${wakeupTime.hour.toString().padLeft(2, '0')}:${wakeupTime.minute.toString().padLeft(2, '0')}',
         isActive: isActive ?? true,
         reminders:
             reminders ??
             [
               Reminder(time: bedtime, repeatDays: [1, 2, 3, 4, 5, 6, 7]),
             ],
       );

  factory SleepGoal.init() {
    return SleepGoal(
      bedtime: const TimeOfDay(hour: 22, minute: 0),
      wakeupTime: const TimeOfDay(hour: 7, minute: 0),
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
  }) {
    return SleepGoal(
      id: id,
      title: title,
      description: description,
      isActive: isActive,
      reminders: reminders ?? this.reminders,
      bedtime: bedtime ?? this.bedtime,
      wakeupTime: wakeupTime ?? this.wakeupTime,
    );
  }

  @override
  List<Object?> get props => [...super.props, bedtime, wakeupTime];
}
