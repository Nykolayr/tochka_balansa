import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:tochka_balansa/data/models/goal/enums_goal.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';

// Универсальный класс для дополнительной цели
class AdditionalGoal extends Equatable {
  final String id;
  final String title;
  final String description; // Описание цели
  final bool isCompleted;
  final DateTime? completionDate;
  final DateTime createdAt;
  final DateTime? deadline;
  final List<Reminder> reminders;
  final DeadlineType deadlineType;
  final DateTime? targetDate;

  // Универсальные поля для всех типов целей
  final List<SubGoal> subGoals; // Для лекарств и других целей с подцелями

  // Универсальная количественная мера
  final int targetCount; // Целевое количество
  final int currentCount; // Текущий прогресс
  final String
  unit; // Единица измерения (страницы, км, литры, часы, повторения и т.д.)

  final String reminderText; // Текст напоминания
  final String
  goalTo; // Для кого/чего цель (например, "лекарство", "книга", "упражнение")

  // Добавляем поле для иконки
  final IconData? icon;

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
    this.subGoals = const [],
    this.targetCount = 0,
    this.currentCount = 0,
    this.unit = '',
    this.reminderText = '',
    this.goalTo = '',
    this.icon,
  });

  bool get isActive => !isCompleted;
  bool get isOverdue =>
      deadline != null && DateTime.now().isAfter(deadline!) && !isCompleted;

  // Количество дней до цели
  int get daysUntilTarget {
    if (targetDate == null) return 0;
    final now = DateTime.now();
    final difference = targetDate!.difference(now);
    return difference.inDays;
  }

  // Процент прогресса (универсальный)
  double get progressPercentage {
    if (deadlineType == DeadlineType.flexible) return 0.0;

    // Для целей с подцелями (лекарства)
    if (subGoals.isNotEmpty) {
      if (subGoals.isEmpty) return 0.0;
      final completedSubGoals = subGoals
          .where((goal) => goal.isCompleted)
          .length;
      return (completedSubGoals / subGoals.length).clamp(0.0, 1.0);
    }

    // Для целей с количественной мерой
    if (targetCount > 0) {
      return (currentCount / targetCount).clamp(0.0, 1.0);
    }

    return 0.0;
  }

  // Обновление прогресса подцели (для лекарств)
  AdditionalGoal updateSubGoalProgress(String subGoalId, int newCount) {
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

  // Обновление прогресса (универсальный метод)
  AdditionalGoal updateProgress(int count) {
    final newCount = currentCount + count;
    return copyWith(
      currentCount: newCount,
      isCompleted: newCount >= targetCount,
      completionDate: newCount >= targetCount ? DateTime.now() : null,
    );
  }

  // Добавление новой подцели
  AdditionalGoal addSubGoal(SubGoal subGoal) {
    return copyWith(subGoals: [...subGoals, subGoal]);
  }

  // Удаление подцели
  AdditionalGoal removeSubGoal(String subGoalId) {
    return copyWith(
      subGoals: subGoals.where((subGoal) => subGoal.id != subGoalId).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
      'targetCount': targetCount,
      'currentCount': currentCount,
      'unit': unit,
      'reminderText': reminderText,
      'goalTo': goalTo,
      'icon': icon?.codePoint,
    };
  }

  factory AdditionalGoal.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> subJsonGoals = [];
    List<SubGoal> subGoals = [];

    try {
      if (json.containsKey('subGoals') && json['subGoals'] is List) {
        subJsonGoals = List<Map<String, dynamic>>.from(
          json['subGoals'].map((e) => Map<String, dynamic>.from(e)),
        );
      }
      subGoals = subJsonGoals.map((sg) => SubGoal.fromJson(sg)).toList();
    } catch (e) {
      Logger.e('AdditionalGoal.fromJson: Ошибка при создании subGoals: $e');
    }
    return AdditionalGoal(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completionDate: json['completionDate'] != null
          ? DateTime.parse(json['completionDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      reminders:
          (json['reminders'] as List<dynamic>?)
              ?.map((r) => Reminder.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      deadlineType: DeadlineType.values.firstWhere(
        (e) => e.name == json['deadlineType'],
        orElse: () => DeadlineType.fixed,
      ),
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'] as String)
          : null,
      subGoals: subGoals,
      targetCount: json['targetCount'] as int? ?? 0,
      currentCount: json['currentCount'] as int? ?? 0,
      unit: json['unit'] as String? ?? '',
      reminderText: json['reminderText'] as String? ?? '',
      goalTo: json['goalTo'] as String? ?? '',
      icon: json['icon'] != null
          ? IconData(json['icon'] as int, fontFamily: 'MaterialIcons')
          : null,
    );
  }

  AdditionalGoal copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? completionDate,
    DateTime? createdAt,
    DateTime? deadline,
    List<Reminder>? reminders,
    DeadlineType? deadlineType,
    DateTime? targetDate,
    List<SubGoal>? subGoals,
    int? targetCount,
    int? currentCount,
    String? unit,
    String? reminderText,
    String? goalTo,
    IconData? icon,
  }) {
    return AdditionalGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      completionDate: completionDate ?? this.completionDate,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
      reminders: reminders ?? this.reminders,
      deadlineType: deadlineType ?? this.deadlineType,
      targetDate: targetDate ?? this.targetDate,
      subGoals: subGoals ?? this.subGoals,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      unit: unit ?? this.unit,
      reminderText: reminderText ?? this.reminderText,
      goalTo: goalTo ?? this.goalTo,
      icon: icon ?? this.icon,
    );
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
    subGoals,
    targetCount,
    currentCount,
    unit,
    reminderText,
    goalTo,
    icon,
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

  // Поля для времени приема (лекарства)
  final bool takeMorning; // Прием утром
  final bool takeLunch; // Прием в обед
  final bool takeEvening; // Прием вечером
  final TimeOfDay? morningTime; // Время утреннего приема
  final TimeOfDay? lunchTime; // Время дневного приема
  final TimeOfDay? eveningTime; // Время вечернего приема
  final String? description; // Описание (например, "до еды", "после еды")

  // Новые поля для управления достижением цели
  final int amountPerDose; // Количество за прием (например, 2 таблетки)
  final GoalAchievementType
  achievementType; // Тип достижения цели: по времени или по общему количеству
  final TimeInterval?
  timeInterval; // Интервал времени (если achievementType == GoalAchievementType.byTime)
  final int?
  totalAmount; // Общее количество (если achievementType == GoalAchievementType.byTotal)

  const SubGoal({
    required this.id,
    required this.title,
    required this.targetCount,
    this.currentCount = 0,
    this.reminderText,
    this.reminderTimes = const [],
    this.isCompleted = false,
    required this.createdAt,
    this.takeMorning = false,
    this.takeLunch = false,
    this.takeEvening = false,
    this.morningTime,
    this.lunchTime,
    this.eveningTime,
    this.description,
    required this.amountPerDose,
    required this.achievementType,
    this.timeInterval,
    this.totalAmount,
  });

  // Обновление прогресса
  SubGoal copyWith({
    int? currentCount,
    bool? isCompleted,
    String? reminderText,
    List<DateTime>? reminderTimes,
    bool? takeMorning,
    bool? takeLunch,
    bool? takeEvening,
    TimeOfDay? morningTime,
    TimeOfDay? lunchTime,
    TimeOfDay? eveningTime,
    String? description,
    int? amountPerDose,
    GoalAchievementType? achievementType,
    TimeInterval? timeInterval,
    int? totalAmount,
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
      takeMorning: takeMorning ?? this.takeMorning,
      takeLunch: takeLunch ?? this.takeLunch,
      takeEvening: takeEvening ?? this.takeEvening,
      morningTime: morningTime ?? this.morningTime,
      lunchTime: lunchTime ?? this.lunchTime,
      eveningTime: eveningTime ?? this.eveningTime,
      description: description ?? this.description,
      amountPerDose: amountPerDose ?? this.amountPerDose,
      achievementType: achievementType ?? this.achievementType,
      timeInterval: timeInterval ?? this.timeInterval,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  // Проверка завершения подцели
  bool checkCompletion() => currentCount >= targetCount;

  // Процент выполнения
  double get progressPercentage =>
      targetCount > 0 ? (currentCount / targetCount).clamp(0.0, 1.0) : 0.0;

  // Вычисляемое количество дней достижения цели
  int get calculatedDays {
    if (achievementType == GoalAchievementType.byTime && timeInterval != null) {
      return timeInterval!.days;
    } else if (achievementType == GoalAchievementType.byTotal &&
        totalAmount != null) {
      final dosesPerDay = _getDosesPerDay();
      return dosesPerDay > 0
          ? (totalAmount! / (amountPerDose * dosesPerDay)).ceil()
          : 0;
    }
    return 0;
  }

  // Вычисляемое общее количество
  int get calculatedTotalAmount {
    if (achievementType == GoalAchievementType.byTotal) {
      return totalAmount ?? 0;
    } else if (achievementType == GoalAchievementType.byTime &&
        timeInterval != null) {
      final dosesPerDay = _getDosesPerDay();
      return timeInterval!.days * amountPerDose * dosesPerDay;
    }
    return 0;
  }

  // Количество доз в день
  int _getDosesPerDay() {
    int doses = 0;
    if (takeMorning) doses++;
    if (takeLunch) doses++;
    if (takeEvening) doses++;
    return doses;
  }

  // Получить время приема в текстовом виде
  String get timeOfDayText {
    final times = <String>[];
    if (takeMorning) {
      final time = morningTime ?? const TimeOfDay(hour: 8, minute: 0);
      times.add(
        'утро (${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')})',
      );
    }
    if (takeLunch) {
      final time = lunchTime ?? const TimeOfDay(hour: 13, minute: 0);
      times.add(
        'обед (${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')})',
      );
    }
    if (takeEvening) {
      final time = eveningTime ?? const TimeOfDay(hour: 20, minute: 0);
      times.add(
        'вечер (${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')})',
      );
    }
    return times.join(', ');
  }

  // Получить описание достижения цели
  String get achievementDescription {
    final dosesPerDay = _getDosesPerDay();
    if (achievementType == GoalAchievementType.byTime && timeInterval != null) {
      return '$amountPerDose за прием, $dosesPerDay раз в день, ${timeInterval!.title}';
    } else {
      return '$amountPerDose за прием, $dosesPerDay раз в день, всего $calculatedTotalAmount';
    }
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
    takeMorning,
    takeLunch,
    takeEvening,
    morningTime,
    lunchTime,
    eveningTime,
    description,
    amountPerDose,
    achievementType,
    timeInterval,
    totalAmount,
  ];

  // Сериализация в JSON
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
      'takeMorning': takeMorning,
      'takeLunch': takeLunch,
      'takeEvening': takeEvening,
      'morningTime': morningTime?.toString(),
      'lunchTime': lunchTime?.toString(),
      'eveningTime': eveningTime?.toString(),
      'description': description,
      'amountPerDose': amountPerDose,
      'achievementType': achievementType.name,
      'timeInterval': timeInterval?.name,
      'totalAmount': totalAmount,
    };
  }

  // Десериализация из JSON
  factory SubGoal.fromJson(Map<String, dynamic> json) {
    return SubGoal(
      id: json['id'] as String,
      title: json['title'] as String,
      targetCount: json['targetCount'] as int,
      currentCount: json['currentCount'] as int? ?? 0,
      reminderText: json['reminderText'] as String?,
      reminderTimes:
          (json['reminderTimes'] as List<dynamic>?)
              ?.map((time) => DateTime.parse(time as String))
              .toList() ??
          [],
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      takeMorning: json['takeMorning'] as bool? ?? false,
      takeLunch: json['takeLunch'] as bool? ?? false,
      takeEvening: json['takeEvening'] as bool? ?? false,
      morningTime: json['morningTime'] != null
          ? _parseTimeOfDay(json['morningTime'] as String)
          : null,
      lunchTime: json['lunchTime'] != null
          ? _parseTimeOfDay(json['lunchTime'] as String)
          : null,
      eveningTime: json['eveningTime'] != null
          ? _parseTimeOfDay(json['eveningTime'] as String)
          : null,
      description: json['description'] as String?,
      amountPerDose: json['amountPerDose'] as int,
      achievementType: GoalAchievementType.values.firstWhere(
        (e) => e.name == json['achievementType'],
        orElse: () => GoalAchievementType.byTime,
      ),
      timeInterval: json['timeInterval'] != null
          ? TimeInterval.values.firstWhere(
              (e) => e.name == json['timeInterval'],
              orElse: () => TimeInterval.oneMonth,
            )
          : null,
      totalAmount: json['totalAmount'] as int?,
    );
  }

  // Вспомогательный метод для парсинга TimeOfDay
  static TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString
        .replaceAll('TimeOfDay(', '')
        .replaceAll(')', '')
        .split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}

// Тип достижения цели
enum GoalAchievementType {
  byTime, // По времени (дни, недели, месяцы)
  byTotal, // По общему количеству
}

extension GoalAchievementTypeExtension on GoalAchievementType {
  String get title {
    switch (this) {
      case GoalAchievementType.byTime:
        return 'По времени';
      case GoalAchievementType.byTotal:
        return 'По общему количеству';
    }
  }

  String get description {
    switch (this) {
      case GoalAchievementType.byTime:
        return 'Указать период времени';
      case GoalAchievementType.byTotal:
        return 'Указать общее количество';
    }
  }
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

// Enum для типов дополнительных целей
enum AdditionalGoalType {
  medication,
  reading,
  exercise,
  water,
  custom;

  String get title => switch (this) {
    medication => textLang('Прием лекарств'),
    reading => textLang('Чтение'),
    exercise => textLang('Упражнения'),
    water => textLang('Пить воду'),
    custom => textLang('Своя цель'),
  };

  String get description => switch (this) {
    medication => textLang('Отслеживание приема лекарств'),
    reading => textLang('Чтение книг и статей'),
    exercise => textLang('Физические упражнения'),
    water => textLang('Потребление воды'),
    custom => textLang('Создание собственной цели'),
  };

  IconData get icon => switch (this) {
    medication => Icons.medication,
    reading => Icons.book,
    exercise => Icons.fitness_center,
    water => Icons.water_drop,
    custom => Icons.add_task,
  };

  // Получить единицу измерения по умолчанию для типа цели
  String get defaultUnit => switch (this) {
    medication => textLang('таблеток'),
    reading => textLang('страниц'),
    exercise => textLang('повторений'),
    water => textLang('литров'),
    custom => textLang('единиц'),
  };

  // Получить название поля goalTo по умолчанию
  String get defaultGoalTo => switch (this) {
    medication => textLang('лекарство'),
    reading => textLang('книга'),
    exercise => textLang('упражнение'),
    water => textLang('вода'),
    custom => textLang('цель'),
  };
}
