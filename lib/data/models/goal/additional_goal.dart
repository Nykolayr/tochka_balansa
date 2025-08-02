import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:tochka_balansa/data/models/goal/enums_goal.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';

/// Дополнительная цель
abstract class AdditionalGoal extends Equatable {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime? completionDate;
  final DateTime createdAt;
  final DateTime? deadline;
  final List<Reminder> reminders;
  final DeadlineType deadlineType;
  final DateTime? targetDate;

  const AdditionalGoal({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.completionDate,
    required this.createdAt,
    this.deadline,
    this.reminders = const [],
    required this.deadlineType,
    this.targetDate,
  });

  bool get isActive => !isCompleted;
  bool get isOverdue =>
      deadline != null && DateTime.now().isAfter(deadline!) && !isCompleted;

  Map<String, dynamic> toJson();

  AdditionalGoal copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? completionDate,
    DateTime? deadline,
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
  List<Object?> get props => [
    id,
    title,
    description,
    isCompleted,
    completionDate,
    createdAt,
    deadline,
    reminders,
    deadlineType,
    targetDate,
  ];
}

// Подцель для любой дополнительной цели
class SubGoal extends Equatable {
  final String id;
  final String title;
  final int targetCount;
  final int currentCount;
  final String? reminderText;
  final List<DateTime> reminderTimes;
  final bool isCompleted;
  final DateTime createdAt;

  const SubGoal({
    required this.id,
    required this.title,
    required this.targetCount,
    this.currentCount = 0,
    this.reminderText,
    this.reminderTimes = const [],
    this.isCompleted = false,
    required this.createdAt,
  });

  // Обновление прогресса
  SubGoal copyWith({
    int? currentCount,
    bool? isCompleted,
    String? reminderText,
    List<DateTime>? reminderTimes,
  }) {
    return SubGoal(
      id: id,
      title: title,
      targetCount: targetCount,
      currentCount: currentCount ?? this.currentCount,
      reminderText: reminderText ?? this.reminderText,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }

  // Проверка завершения подцели
  bool checkCompletion() => currentCount >= targetCount;

  // Процент выполнения
  double get progressPercentage =>
      targetCount > 0 ? (currentCount / targetCount).clamp(0.0, 1.0) : 0.0;

  // Метод для сериализации в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetCount': targetCount,
      'currentCount': currentCount,
      'reminderText': reminderText,
      'reminderTimes': reminderTimes
          .map((time) => time.toIso8601String())
          .toList(),
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SubGoal.fromJson(Map<String, dynamic> json) {
    return SubGoal(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      targetCount: json['targetCount'] ?? 0,
      currentCount: json['currentCount'] ?? 0,
      reminderText: json['reminderText'],
      reminderTimes:
          (json['reminderTimes'] as List<dynamic>?)
              ?.map((time) => DateTime.parse(time))
              .toList() ??
          [],
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    targetCount,
    currentCount,
    reminderText,
    reminderTimes,
    isCompleted,
    createdAt,
  ];
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

// Цель: Прием лекарств
class MedicationGoal extends AdditionalGoal {
  final List<SubGoal> subGoals;

  const MedicationGoal({
    required String id,
    required String title,
    required String description,
    required this.subGoals,
    bool isCompleted = false,
    DateTime? completionDate,
    required DateTime createdAt,
    DateTime? deadline,
    List<Reminder> reminders = const [],
    required DeadlineType deadlineType,
    DateTime? targetDate,
  }) : super(
         id: id,
         title: title,
         description: description,
         isCompleted: isCompleted,
         completionDate: completionDate,
         createdAt: createdAt,
         deadline: deadline,
         reminders: reminders,
         deadlineType: deadlineType,
         targetDate: targetDate,
       );

  // Проверка завершения всей цели
  @override
  bool get isActive =>
      !isCompleted && subGoals.any((subGoal) => !subGoal.isCompleted);

  // Обновление прогресса подцели
  MedicationGoal updateSubGoalProgress(String subGoalId, int newCount) {
    final updatedSubGoals = subGoals.map((subGoal) {
      if (subGoal.id == subGoalId) {
        return subGoal.copyWith(
          currentCount: newCount,
          isCompleted: newCount >= subGoal.targetCount,
        );
      }
      return subGoal;
    }).toList();

    return copyWith(
      subGoals: updatedSubGoals,
      isCompleted: updatedSubGoals.every((subGoal) => subGoal.isCompleted),
      completionDate: updatedSubGoals.every((subGoal) => subGoal.isCompleted)
          ? DateTime.now()
          : null,
    );
  }

  // Добавление новой подцели
  MedicationGoal addSubGoal(SubGoal subGoal) {
    return copyWith(subGoals: [...subGoals, subGoal]);
  }

  // Удаление подцели
  MedicationGoal removeSubGoal(String subGoalId) {
    return copyWith(
      subGoals: subGoals.where((subGoal) => subGoal.id != subGoalId).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'medication',
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'completionDate': completionDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'reminders': reminders.map((reminder) => reminder.toJson()).toList(),
      'deadlineType': deadlineType.name,
      'targetDate': targetDate?.toIso8601String(),
      'subGoals': subGoals.map((goal) => goal.toJson()).toList(),
    };
  }

  factory MedicationGoal.fromJson(Map<String, dynamic> json) {
    return MedicationGoal(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      subGoals:
          (json['subGoals'] as List<dynamic>?)
              ?.map((goal) => SubGoal.fromJson(goal))
              .toList() ??
          [],
      isCompleted: json['isCompleted'] ?? false,
      completionDate: json['completionDate'] != null
          ? DateTime.parse(json['completionDate'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : null,
      reminders:
          (json['reminders'] as List<dynamic>?)
              ?.map((reminder) => Reminder.fromJson(reminder))
              .toList() ??
          [],
      deadlineType: DeadlineType.values.firstWhere(
        (type) => type.name == json['deadlineType'],
        orElse: () => DeadlineType.fixed,
      ),
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'])
          : null,
    );
  }

  @override
  MedicationGoal copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? completionDate,
    DateTime? deadline,
    List<Reminder>? reminders,
    DeadlineType? deadlineType,
    DateTime? targetDate,
    List<SubGoal>? subGoals,
  }) {
    return MedicationGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subGoals: subGoals ?? this.subGoals,
      isCompleted: isCompleted ?? this.isCompleted,
      completionDate: completionDate ?? this.completionDate,
      createdAt: createdAt,
      deadline: deadline ?? this.deadline,
      reminders: reminders ?? this.reminders,
      deadlineType: deadlineType ?? this.deadlineType,
      targetDate: targetDate ?? this.targetDate,
    );
  }

  @override
  List<Object?> get props => [...super.props, subGoals];
}

// Цель: Чтение книги
class ReadingGoal extends AdditionalGoal {
  final int totalPages;
  final int currentPages;
  final int dailyTarget;
  final String reminderText;

  const ReadingGoal({
    required String id,
    required String title,
    required String description,
    required this.totalPages,
    this.currentPages = 0,
    required this.dailyTarget,
    required this.reminderText,
    bool isCompleted = false,
    DateTime? completionDate,
    required DateTime createdAt,
    DateTime? deadline,
    List<Reminder> reminders = const [],
    required DeadlineType deadlineType,
    DateTime? targetDate,
  }) : super(
         id: id,
         title: title,
         description: description,
         isCompleted: isCompleted,
         completionDate: completionDate,
         createdAt: createdAt,
         deadline: deadline,
         reminders: reminders,
         deadlineType: deadlineType,
         targetDate: targetDate,
       );

  // Обновление прогресса
  ReadingGoal updateProgress(int pagesRead) {
    final newPages = currentPages + pagesRead;
    return copyWith(
      currentPages: newPages,
      isCompleted: newPages >= totalPages,
      completionDate: newPages >= totalPages ? DateTime.now() : null,
    );
  }

  // Процент выполнения
  @override
  double get progressPercentage =>
      totalPages > 0 ? (currentPages / totalPages).clamp(0.0, 1.0) : 0.0;

  // Осталось страниц
  int get remainingPages => (totalPages - currentPages).clamp(0, totalPages);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'reading',
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'completionDate': completionDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'reminders': reminders.map((reminder) => reminder.toJson()).toList(),
      'deadlineType': deadlineType.name,
      'targetDate': targetDate?.toIso8601String(),
      'totalPages': totalPages,
      'currentPages': currentPages,
      'dailyTarget': dailyTarget,
      'reminderText': reminderText,
    };
  }

  factory ReadingGoal.fromJson(Map<String, dynamic> json) {
    return ReadingGoal(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      totalPages: json['totalPages'] ?? 0,
      currentPages: json['currentPages'] ?? 0,
      dailyTarget: json['dailyTarget'] ?? 0,
      reminderText: json['reminderText'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      completionDate: json['completionDate'] != null
          ? DateTime.parse(json['completionDate'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : null,
      reminders:
          (json['reminders'] as List<dynamic>?)
              ?.map((reminder) => Reminder.fromJson(reminder))
              .toList() ??
          [],
      deadlineType: DeadlineType.values.firstWhere(
        (type) => type.name == json['deadlineType'],
        orElse: () => DeadlineType.fixed,
      ),
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'])
          : null,
    );
  }

  @override
  ReadingGoal copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? completionDate,
    DateTime? deadline,
    List<Reminder>? reminders,
    DeadlineType? deadlineType,
    DateTime? targetDate,
    int? currentPages,
  }) {
    return ReadingGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      totalPages: totalPages,
      currentPages: currentPages ?? this.currentPages,
      dailyTarget: dailyTarget,
      reminderText: reminderText,
      isCompleted: isCompleted ?? this.isCompleted,
      completionDate: completionDate ?? this.completionDate,
      createdAt: createdAt,
      deadline: deadline ?? this.deadline,
      reminders: reminders ?? this.reminders,
      deadlineType: deadlineType ?? this.deadlineType,
      targetDate: targetDate ?? this.targetDate,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    totalPages,
    currentPages,
    dailyTarget,
    reminderText,
  ];
}

// Цель: Упражнения
class ExerciseGoal extends AdditionalGoal {
  final int targetCount;
  final int currentCount;
  final String reminderText;
  final String exerciseType; // Тип упражнения (подтягивания, отжимания и т.д.)

  const ExerciseGoal({
    required String id,
    required String title,
    required String description,
    required this.targetCount,
    this.currentCount = 0,
    required this.reminderText,
    required this.exerciseType,
    bool isCompleted = false,
    DateTime? completionDate,
    required DateTime createdAt,
    DateTime? deadline,
    List<Reminder> reminders = const [],
    required DeadlineType deadlineType,
    DateTime? targetDate,
  }) : super(
         id: id,
         title: title,
         description: description,
         isCompleted: isCompleted,
         completionDate: completionDate,
         createdAt: createdAt,
         deadline: deadline,
         reminders: reminders,
         deadlineType: deadlineType,
         targetDate: targetDate,
       );

  // Обновление прогресса
  ExerciseGoal updateProgress(int count) {
    final newCount = currentCount + count;
    return copyWith(
      currentCount: newCount,
      isCompleted: newCount >= targetCount,
      completionDate: newCount >= targetCount ? DateTime.now() : null,
    );
  }

  // Процент выполнения
  @override
  double get progressPercentage =>
      targetCount > 0 ? (currentCount / targetCount).clamp(0.0, 1.0) : 0.0;

  // Осталось повторений
  int get remainingCount => (targetCount - currentCount).clamp(0, targetCount);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'exercise',
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'completionDate': completionDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'reminders': reminders.map((reminder) => reminder.toJson()).toList(),
      'deadlineType': deadlineType.name,
      'targetDate': targetDate?.toIso8601String(),
      'targetCount': targetCount,
      'currentCount': currentCount,
      'reminderText': reminderText,
      'exerciseType': exerciseType,
    };
  }

  factory ExerciseGoal.fromJson(Map<String, dynamic> json) {
    return ExerciseGoal(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      targetCount: json['targetCount'] ?? 0,
      currentCount: json['currentCount'] ?? 0,
      reminderText: json['reminderText'] ?? '',
      exerciseType: json['exerciseType'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      completionDate: json['completionDate'] != null
          ? DateTime.parse(json['completionDate'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : null,
      reminders:
          (json['reminders'] as List<dynamic>?)
              ?.map((reminder) => Reminder.fromJson(reminder))
              .toList() ??
          [],
      deadlineType: DeadlineType.values.firstWhere(
        (type) => type.name == json['deadlineType'],
        orElse: () => DeadlineType.fixed,
      ),
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'])
          : null,
    );
  }

  @override
  ExerciseGoal copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? completionDate,
    DateTime? deadline,
    List<Reminder>? reminders,
    DeadlineType? deadlineType,
    DateTime? targetDate,
    int? currentCount,
  }) {
    return ExerciseGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetCount: targetCount,
      currentCount: currentCount ?? this.currentCount,
      reminderText: reminderText,
      exerciseType: exerciseType,
      isCompleted: isCompleted ?? this.isCompleted,
      completionDate: completionDate ?? this.completionDate,
      createdAt: createdAt,
      deadline: deadline ?? this.deadline,
      reminders: reminders ?? this.reminders,
      deadlineType: deadlineType ?? this.deadlineType,
      targetDate: targetDate ?? this.targetDate,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    targetCount,
    currentCount,
    reminderText,
    exerciseType,
  ];
}

// Цель: Пить воду
class WaterGoal extends AdditionalGoal {
  final int targetLiters;
  final int currentLiters;
  final String reminderText;

  const WaterGoal({
    required String id,
    required String title,
    required String description,
    required this.targetLiters,
    this.currentLiters = 0,
    required this.reminderText,
    bool isCompleted = false,
    DateTime? completionDate,
    required DateTime createdAt,
    DateTime? deadline,
    List<Reminder> reminders = const [],
    required DeadlineType deadlineType,
    DateTime? targetDate,
  }) : super(
         id: id,
         title: title,
         description: description,
         isCompleted: isCompleted,
         completionDate: completionDate,
         createdAt: createdAt,
         deadline: deadline,
         reminders: reminders,
         deadlineType: deadlineType,
         targetDate: targetDate,
       );

  // Обновление прогресса
  WaterGoal updateProgress(int liters) {
    final newLiters = currentLiters + liters;
    return copyWith(
      currentLiters: newLiters,
      isCompleted: newLiters >= targetLiters,
      completionDate: newLiters >= targetLiters ? DateTime.now() : null,
    );
  }

  // Процент выполнения
  @override
  double get progressPercentage =>
      targetLiters > 0 ? (currentLiters / targetLiters).clamp(0.0, 1.0) : 0.0;

  // Осталось литров
  int get remainingLiters =>
      (targetLiters - currentLiters).clamp(0, targetLiters);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'water',
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'completionDate': completionDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'reminders': reminders.map((reminder) => reminder.toJson()).toList(),
      'deadlineType': deadlineType.name,
      'targetDate': targetDate?.toIso8601String(),
      'targetLiters': targetLiters,
      'currentLiters': currentLiters,
      'reminderText': reminderText,
    };
  }

  factory WaterGoal.fromJson(Map<String, dynamic> json) {
    return WaterGoal(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      targetLiters: json['targetLiters'] ?? 0,
      currentLiters: json['currentLiters'] ?? 0,
      reminderText: json['reminderText'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      completionDate: json['completionDate'] != null
          ? DateTime.parse(json['completionDate'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : null,
      reminders:
          (json['reminders'] as List<dynamic>?)
              ?.map((reminder) => Reminder.fromJson(reminder))
              .toList() ??
          [],
      deadlineType: DeadlineType.values.firstWhere(
        (type) => type.name == json['deadlineType'],
        orElse: () => DeadlineType.fixed,
      ),
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'])
          : null,
    );
  }

  @override
  WaterGoal copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? completionDate,
    DateTime? deadline,
    List<Reminder>? reminders,
    DeadlineType? deadlineType,
    DateTime? targetDate,
    int? currentLiters,
  }) {
    return WaterGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetLiters: targetLiters,
      currentLiters: currentLiters ?? this.currentLiters,
      reminderText: reminderText,
      isCompleted: isCompleted ?? this.isCompleted,
      completionDate: completionDate ?? this.completionDate,
      createdAt: createdAt,
      deadline: deadline ?? this.deadline,
      reminders: reminders ?? this.reminders,
      deadlineType: deadlineType ?? this.deadlineType,
      targetDate: targetDate ?? this.targetDate,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    targetLiters,
    currentLiters,
    reminderText,
  ];
}

// Enum для типов дополнительных целей
enum AdditionalGoalType {
  medication,
  reading,
  exercise,
  water,
  sleep,
  custom;

  String get title => switch (this) {
    medication => textLang('Прием лекарств'),
    reading => textLang('Чтение'),
    exercise => textLang('Упражнения'),
    water => textLang('Пить воду'),
    sleep => textLang('Сон'),
    custom => textLang('Своя цель'),
  };

  String get description => switch (this) {
    medication => textLang('Отслеживание приема лекарств'),
    reading => textLang('Чтение книг и статей'),
    exercise => textLang('Физические упражнения'),
    water => textLang('Потребление воды'),
    sleep => textLang('Качество и количество сна'),
    custom => textLang('Создание собственной цели'),
  };

  IconData get icon => switch (this) {
    medication => Icons.medication,
    reading => Icons.book,
    exercise => Icons.fitness_center,
    water => Icons.water_drop,
    sleep => Icons.bedtime,
    custom => Icons.add_task,
  };
}
