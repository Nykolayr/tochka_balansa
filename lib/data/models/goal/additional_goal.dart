import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:tochka_balansa/data/models/goal/enums_goal.dart';

/// Дополнительная цель
abstract class AdditionalGoal extends Equatable {
  final String id;
  final String title;
  final String description;
  final bool isActive;
  final List<Reminder> reminders;
  final DeadlineType deadlineType;
  final DateTime? targetDate;

  const AdditionalGoal({
    required this.id,
    required this.title,
    required this.description,
    this.isActive = true,
    required this.reminders,
    required this.deadlineType,
    this.targetDate,
  });

  Map<String, dynamic> toJson();

  AdditionalGoal copyWith({
    String? id,
    String? title,
    String? description,
    bool? isActive,
    List<Reminder>? reminders,
    DeadlineType? deadlineType,
    DateTime? targetDate,
  });

  // Количество дней до цели
  int get daysUntilTarget {
    if (targetDate == null) return 0;
    final now = DateTime.now();
    final difference = targetDate!.difference(now);
    return difference.inDays;
  }

  // Процент прогресса (базовая реализация, переопределяется в наследниках)
  double get progressPercentage {
    if (deadlineType == DeadlineType.flexible) return 0.0;
    // TODO: Реализовать в наследниках
    return 0.0;
  }

  @override
  List<Object?> get props => [id, title, description, isActive, reminders, deadlineType, targetDate];
}

class Reminder extends Equatable {
  final TimeOfDay time;
  final List<int> repeatDays; // 1-7 (пн-вс)

  const Reminder({required this.time, this.repeatDays = const []});

  Map<String, dynamic> toJson() {
    return {
      'time':
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      'repeatDays': repeatDays,
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    final timeStr = json['time'] as String;
    final timeParts = timeStr.split(':');
    final time = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    final repeatDays =
        (json['repeatDays'] as List<dynamic>?)?.map((e) => e as int).toList() ??
        [];

    return Reminder(time: time, repeatDays: repeatDays);
  }

  Reminder copyWith({TimeOfDay? time, List<int>? repeatDays}) {
    return Reminder(
      time: time ?? this.time,
      repeatDays: repeatDays ?? this.repeatDays,
    );
  }

  @override
  List<Object?> get props => [time, repeatDays];
}
