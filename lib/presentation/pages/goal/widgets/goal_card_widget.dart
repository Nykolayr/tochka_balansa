import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/colors.dart';
import 'package:tochka_balansa/data/models/goal/additional_goal.dart';
import 'package:tochka_balansa/data/models/goal/user_goal.dart';
import 'package:tochka_balansa/data/models/goal/enums_goal.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/presentation/pages/goal/bloc/goal_bloc.dart';

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
        final unit = additionalGoal.unit.isNotEmpty
            ? additionalGoal.unit
            : 'единиц';
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColor.darkBlue, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColor.darkBlue,
                          ),
                        ),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColor.greyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Кнопка удаления только для дополнительных целей
                  if (!isMainGoal && goal is AdditionalGoal)
                    IconButton(
                      onPressed: () => _showDeleteDialog(context),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColor.red,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: AppColor.grey,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColor.darkBlue,
                ),
                minHeight: 6,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${progress.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColor.darkBlue,
                    ),
                  ),
                  if (daysLeft > 0)
                    Text(
                      '$daysLeft ${textLang('дней')}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColor.greyText,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(textLang('Удалить цель?')),
          content: Text(
            textLang(
              'Вы уверены, что хотите удалить цель "${title}"? Это действие нельзя отменить.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                textLang('Отмена'),
                style: const TextStyle(color: AppColor.greyText),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteGoal();
              },
              child: Text(
                textLang('Удалить'),
                style: const TextStyle(color: AppColor.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteGoal() {
    if (goal is AdditionalGoal) {
      final additionalGoal = goal as AdditionalGoal;
      final goalBloc = Get.find<GoalBloc>();
      goalBloc.add(RemoveAdditionalGoalEvent(additionalGoal.id));
    }
  }
}
