import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/colors.dart';
import 'package:tochka_balansa/data/models/goal/additional_goal.dart';
import 'package:tochka_balansa/data/models/goal/user_goal.dart';
import 'package:tochka_balansa/data/models/goal/enums_goal.dart';
import 'package:tochka_balansa/presentation/pages/goal/bloc/goal_bloc.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';

class ArchivePage extends StatelessWidget {
  const ArchivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: textLang('Архив'), isBack: true),
      body: BlocBuilder<GoalBloc, GoalState>(
        bloc: Get.find<GoalBloc>(),
        builder: (context, state) {
          if (state.archivedGoals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.archive_outlined,
                    size: 64,
                    color: AppColor.greyText.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    textLang('Архив пуст'),
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColor.greyText.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    textLang('Завершенные цели появятся здесь'),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColor.greyText.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.archivedGoals.length,
            itemBuilder: (context, index) {
              final goal = state.archivedGoals[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ArchivedGoalCardWidget(
                  goal: goal,
                  isMainGoal: false,
                  onTap: () {
                    // Можно добавить детальный просмотр архивированной цели
                    // context.push('/main/training/archive-detail', extra: goal);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ArchivedGoalCardWidget extends StatelessWidget {
  final dynamic goal; // UserGoal или AdditionalGoal
  final bool isMainGoal;
  final VoidCallback? onTap;

  const ArchivedGoalCardWidget({
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
        return '$completed/${additionalGoal.subGoals.length} задач выполнено';
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

  // Метод для форматирования даты
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  // Метод для получения количества дней
  int get daysBetween {
    if (goal is AdditionalGoal) {
      final additionalGoal = goal as AdditionalGoal;
      if (additionalGoal.completionDate != null) {
        return additionalGoal.completionDate!
            .difference(additionalGoal.createdAt)
            .inDays;
      }
    }
    return 0;
  }

  // Метод для получения даты начала
  String get startDate {
    if (goal is AdditionalGoal) {
      final additionalGoal = goal as AdditionalGoal;
      return _formatDate(additionalGoal.createdAt);
    }
    return '';
  }

  // Метод для получения даты окончания (completionDate)
  String get endDate {
    if (goal is AdditionalGoal) {
      final additionalGoal = goal as AdditionalGoal;
      if (additionalGoal.completionDate != null) {
        return _formatDate(additionalGoal.completionDate!);
      }
    }
    return '';
  }

  IconData get icon {
    if (goal is UserGoal) {
      return Icons.flag;
    } else if (goal is AdditionalGoal) {
      final additionalGoal = goal as AdditionalGoal;
      if (additionalGoal.subGoals.isNotEmpty) return Icons.medication;
      if (additionalGoal.targetCount > 0) {
        final unit = additionalGoal.unit.toLowerCase();
        if (unit.contains('страниц') || unit.contains('книг')) {
          return Icons.book;
        }
        if (unit.contains('повторений') ||
            unit.contains('подтягиваний') ||
            unit.contains('отжиманий')) {
          return Icons.fitness_center;
        }
        if (unit.contains('км') || unit.contains('метров')) {
          return Icons.directions_run;
        }
        if (unit.contains('литров') || unit.contains('воды')) {
          return Icons.water_drop;
        }
        if (unit.contains('часов') || unit.contains('времени')) {
          return Icons.access_time;
        }
      }
      return additionalGoal.icon ?? Icons.flag;
    }
    return Icons.flag;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  Icon(icon, color: AppColor.green, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColor.darkBlue,
                          ),
                        ),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColor.greyText,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(Icons.check_circle, color: AppColor.green, size: 24),
                ],
              ),
              const SizedBox(height: 12),
              // Информация о датах для архивных целей
              if (goal is AdditionalGoal) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        startDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColor.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$daysBetween дней',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColor.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        endDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColor.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
