import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/theme/colors.dart';
import 'package:tochka_balansa/data/models/goal/additional_goal.dart';
import 'package:tochka_balansa/data/models/goal/user_goal.dart';
import 'package:tochka_balansa/data/models/goal/enums_goal.dart';

class GoalCardWidget extends StatelessWidget {
  final dynamic goal; // UserGoal или AdditionalGoal
  final bool isMainGoal;
  final VoidCallback? onTap;

  const GoalCardWidget({
    super.key,
    required this.goal,
    required this.isMainGoal,
    this.onTap,
  });

  String get title {
    if (goal is UserGoal) {
      final userGoal = goal as UserGoal;
      switch (userGoal.goalType) {
        case GoalType.loseWeight:
          return 'Сбросить вес';
        case GoalType.gainWeight:
          return 'Набрать вес';
        case GoalType.maintain:
          return 'Поддерживать вес';
        case GoalType.none:
          return 'Цель не установлена';
      }
    } else if (goal is AdditionalGoal) {
      return (goal as AdditionalGoal).title;
    }
    return '';
  }

  String get description {
    if (goal is UserGoal) {
      final userGoal = goal as UserGoal;
      return '${userGoal.targetWeight} кг к ${userGoal.targetDate?.day.toString().padLeft(2, '0')}.${userGoal.targetDate?.month.toString().padLeft(2, '0')}.${userGoal.targetDate?.year}';
    } else if (goal is AdditionalGoal) {
      final additionalGoal = goal as AdditionalGoal;
      if (additionalGoal.subGoals.isNotEmpty) {
        final completed = additionalGoal.subGoals
            .where((sg) => sg.isCompleted)
            .length;
        return '$completed/${additionalGoal.subGoals.length} подцелей выполнено';
      } else if (additionalGoal.targetCount > 0) {
        final unit = additionalGoal.unit.isNotEmpty ? additionalGoal.unit : 'единиц';
        return '${additionalGoal.currentCount}/${additionalGoal.targetCount} $unit';
      }
      return additionalGoal.description.isNotEmpty
          ? additionalGoal.description
          : additionalGoal.reminderText.isNotEmpty
              ? additionalGoal.reminderText
              : 'Дополнительная цель';
    }
    return '';
  }

  double get progress {
    if (goal is UserGoal) {
      return (goal as UserGoal).progressPercentage * 100;
    } else if (goal is AdditionalGoal) {
      return (goal as AdditionalGoal).progressPercentage * 100;
    }
    return 0.0;
  }

  int get daysLeft {
    if (goal is UserGoal) {
      return (goal as UserGoal).daysUntilTarget;
    } else if (goal is AdditionalGoal) {
      return (goal as AdditionalGoal).daysUntilTarget;
    }
    return 0;
  }

  IconData get icon {
    if (goal is UserGoal) {
      return Icons.flag;
    } else if (goal is AdditionalGoal) {
      final additionalGoal = goal as AdditionalGoal;
      if (additionalGoal.subGoals.isNotEmpty) return Icons.medication;
      if (additionalGoal.targetCount > 0) {
        // Определяем иконку по единице измерения
        final unit = additionalGoal.unit.toLowerCase();
        if (unit.contains('страниц') || unit.contains('книг')) {
          return Icons.book;
        }
        if (unit.contains('повторений') ||
            unit.contains('подтягиваний') ||
            unit.contains('отжиманий')) {
          return Icons.fitness_center;
        }
        if (unit.contains('литров') || unit.contains('воды')) {
          return Icons.water_drop;
        }
        if (unit.contains('часов') || unit.contains('сна')) {
          return Icons.bedtime;
        }
        if (unit.contains('км') || unit.contains('километров')) {
          return Icons.directions_run;
        }
        return Icons.star;
      }
      return Icons.star;
    }
    return Icons.star;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isMainGoal
                ? AppColor.darkBlue
                : AppColor.grey.withValues(alpha: 0.3),
            width: isMainGoal ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок и иконка
            Row(
              children: [
                Icon(
                  icon,
                  color: isMainGoal ? AppColor.darkBlue : AppColor.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isMainGoal ? AppColor.darkBlue : Colors.black87,
                    ),
                  ),
                ),
                // Иконка редактирования для главной цели
                if (isMainGoal && onTap != null) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.edit, color: AppColor.grey, size: 16),
                ],
              ],
            ),

            const SizedBox(height: 8),

            // Описание
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: AppColor.grey),
            ),

            const SizedBox(height: 12),

            // Прогресс бар
            if (progress > 0) ...[
              LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: AppColor.grey.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isMainGoal ? AppColor.darkBlue : AppColor.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${progress.toStringAsFixed(1)}% выполнено',
                style: const TextStyle(fontSize: 12, color: AppColor.grey),
              ),
            ],

            // Дни до цели
            if (daysLeft > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: AppColor.grey),
                  const SizedBox(width: 4),
                  Text(
                    '$daysLeft дней до цели',
                    style: const TextStyle(fontSize: 12, color: AppColor.grey),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
