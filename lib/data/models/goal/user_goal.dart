import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:tochka_balansa/data/models/goal/enums_goal.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';

class UserGoal extends Equatable {
  final GoalType goalType;
  final DeadlineType deadlineType;
  final double targetWeight;
  final DateTime? targetDate;

  const UserGoal({
    required this.goalType,
    required this.deadlineType,
    required this.targetWeight,
    this.targetDate,
  });

  factory UserGoal.init() => const UserGoal(
    goalType: GoalType.none,
    deadlineType: DeadlineType.fixed,
    targetWeight: 0.0,
  );

  factory UserGoal.fromJson(Map<String, dynamic> json) {
    try {
      // Проверяем тип goalType
      String? goalTypeStr = json['goalType'] as String?;

      if (goalTypeStr == null) {
        Logger.e('goalType в JSON равен null');
        return UserGoal.init();
      }

      // Находим соответствующий GoalType
      GoalType goalType = GoalType.none;
      for (var type in GoalType.values) {
        if (type.name == goalTypeStr) {
          goalType = type;
          break;
        }
      }

      // Находим deadlineType
      String? deadlineTypeStr = json['deadlineType'] as String?;
      DeadlineType deadlineType = DeadlineType.fixed;
      if (deadlineTypeStr != null) {
        for (var type in DeadlineType.values) {
          if (type.name == deadlineTypeStr) {
            deadlineType = type;
            break;
          }
        }
      }

      // Получаем targetWeight
      double targetWeight = 0.0;
      if (json['targetWeight'] != null) {
        targetWeight = (json['targetWeight'] as num).toDouble();
      }

      // Получаем targetDate
      DateTime? targetDate;
      if (json['targetDate'] != null) {
        try {
          targetDate = DateTime.parse(json['targetDate'] as String);
        } catch (e) {
          Logger.e('Ошибка при парсинге targetDate: $e');
        }
      }

      return UserGoal(
        goalType: goalType,
        deadlineType: deadlineType,
        targetWeight: targetWeight,
        targetDate: targetDate,
      );
    } catch (e) {
      Logger.e('Ошибка в UserGoal.fromJson: $e');
      return UserGoal.init();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'goalType': goalType.name,
      'deadlineType': deadlineType.name,
      'targetWeight': targetWeight,
      'targetDate': targetDate?.toIso8601String(),
    };
  }

  UserGoal copyWith({
    GoalType? goalType,
    DeadlineType? deadlineType,
    double? targetWeight,
    DateTime? targetDate,
  }) {
    return UserGoal(
      goalType: goalType ?? this.goalType,
      deadlineType: deadlineType ?? this.deadlineType,
      targetWeight: targetWeight ?? this.targetWeight,
      targetDate: targetDate ?? this.targetDate,
    );
  }

  // Проверка, установлена ли главная цель
  bool get hasMainGoal => goalType != GoalType.none;

  // Количество дней до цели
  int get daysUntilTarget {
    if (targetDate == null) return 0;
    final now = DateTime.now();
    final difference = targetDate!.difference(now);
    return difference.inDays;
  }

  // Процент прогресса
  double get progressPercentage {
    if (goalType == GoalType.none || targetWeight <= 0) return 0.0;

    // Для неограниченных целей не считаем прогресс
    if (deadlineType == DeadlineType.flexible) return 0.0;

    try {
      final userRepository = Get.find<UserRepository>();
      final currentWeight =
          userRepository.user.initialWeight; // TODO: Заменить на текущий вес

      if (currentWeight <= 0) return 0.0;

      switch (goalType) {
        case GoalType.loseWeight:
          // Для сброса веса: прогресс = (начальный вес - текущий вес) / (начальный вес - целевой вес)
          final startWeight = userRepository.user.initialWeight;
          final totalToLose = startWeight - targetWeight;
          final alreadyLost = startWeight - currentWeight;
          if (totalToLose <= 0) return 100.0;
          return (alreadyLost / totalToLose * 100).clamp(0.0, 100.0);

        case GoalType.gainWeight:
          // Для набора веса: прогресс = (текущий вес - начальный вес) / (целевой вес - начальный вес)
          final startWeight = userRepository.user.initialWeight;
          final totalToGain = targetWeight - startWeight;
          final alreadyGained = currentWeight - startWeight;
          if (totalToGain <= 0) return 100.0;
          return (alreadyGained / totalToGain * 100).clamp(0.0, 100.0);

        case GoalType.maintain:
          // Для поддержания веса: прогресс на основе стабильности
          final startWeight = userRepository.user.initialWeight;
          final weightDifference = (currentWeight - startWeight).abs();
          final tolerance = 2.0; // Допустимое отклонение в кг
          if (weightDifference <= tolerance) {
            return 100.0;
          } else {
            return (100.0 - (weightDifference - tolerance) * 10).clamp(
              0.0,
              100.0,
            );
          }

        default:
          return 0.0;
      }
    } catch (e) {
      return 0.0;
    }
  }

  @override
  List<Object?> get props => [goalType, deadlineType, targetWeight, targetDate];

  @override
  String toString() {
    return 'UserGoal(goalType: $goalType, targetWeight: $targetWeight, hasMainGoal: $hasMainGoal)';
  }
}
