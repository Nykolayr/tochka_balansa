import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/colors.dart';
import 'package:tochka_balansa/data/models/goal/additional_goal.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/presentation/pages/goal/bloc/goal_bloc.dart';
import 'package:tochka_balansa/presentation/widgets/goal_completed_dialog.dart';

class AdditionalGoalDetailPage extends StatelessWidget {
  final AdditionalGoal goal;

  const AdditionalGoalDetailPage({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return BlocListener<GoalBloc, GoalState>(
      bloc: Get.find<GoalBloc>(),
      listener: (context, state) {
        // Проверяем, была ли цель перемещена в архив
        final goalInArchive = state.archivedGoals.any((g) => g.id == goal.id);
        final goalInActive = state.additionalGoals.any((g) => g.id == goal.id);

        if (goalInArchive && !goalInActive) {
          // Цель была перемещена в архив - показываем модальное окно
          _showGoalCompletedDialog(context);
        }
      },
      child: Scaffold(
        appBar: AppBarWidget(title: goal.title, isBack: true),
        body: BlocBuilder<GoalBloc, GoalState>(
          bloc: Get.find<GoalBloc>(),
          builder: (context, state) {
            // Находим актуальную цель в состоянии
            final currentGoal = state.additionalGoals.firstWhere(
              (g) => g.id == goal.id,
              orElse: () => goal,
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Описание цели
                  if (currentGoal.description.isNotEmpty) ...[
                    Text(
                      currentGoal.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColor.greyText,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Общий прогресс
                  _buildOverallProgress(currentGoal),
                  const SizedBox(height: 24),

                  // Подзадачи
                  Text(
                    textLang('Подзадачи'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColor.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...currentGoal.subGoals.map(
                    (subGoal) => _buildSubGoalCard(context, subGoal),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showGoalCompletedDialog(BuildContext context) {
    GoalCompletedDialog.show(
      context,
      onOkPressed: () {
        Navigator.of(context).pop(); // Закрываем диалог
        Navigator.of(context).pop(); // Возвращаемся на предыдущую страницу
      },
    );
  }

  Widget _buildOverallProgress(AdditionalGoal currentGoal) {
    final progress = currentGoal.progressPercentage;
    final completedSubGoals = currentGoal.subGoals
        .where((sg) => sg.isCompleted)
        .length;
    final totalSubGoals = currentGoal.subGoals.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.greyLine,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            textLang('Общий прогресс'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColor.darkBlue,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColor.grey,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColor.darkBlue),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            '$completedSubGoals из $totalSubGoals ${textLang('подзадач выполнено')}',
            style: const TextStyle(fontSize: 14, color: AppColor.greyText),
          ),
        ],
      ),
    );
  }

  Widget _buildSubGoalCard(BuildContext context, SubGoal subGoal) {
    final progress = subGoal.targetCount > 0
        ? (subGoal.currentCount / subGoal.targetCount).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    subGoal.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: subGoal.isCompleted
                          ? AppColor.green
                          : AppColor.darkBlue,
                      // Убираем зачеркивание
                    ),
                  ),
                ),
                if (subGoal.isCompleted)
                  const Icon(
                    Icons.check_circle,
                    color: AppColor.green,
                    size: 24,
                  ),
              ],
            ),
            if (subGoal.description != null &&
                subGoal.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                subGoal.description!,
                style: const TextStyle(fontSize: 14, color: AppColor.greyText),
              ),
            ],
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColor.grey,
              valueColor: AlwaysStoppedAnimation<Color>(
                subGoal.isCompleted ? AppColor.green : AppColor.darkBlue,
              ),
              minHeight: 6,
            ),
            const SizedBox(height: 8),
            Text(
              '${subGoal.currentCount} / ${subGoal.targetCount}',
              style: const TextStyle(fontSize: 14, color: AppColor.greyText),
            ),
            if (!subGoal.isCompleted) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showCompleteSubGoalDialog(context, subGoal),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.darkBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(textLang('Завершить подзадачу')),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCompleteSubGoalDialog(BuildContext context, SubGoal subGoal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(textLang('Завершить подзадачу?')),
          content: Text(
            textLang(
              'Вы уверены, что хотите завершить подзадачу "${subGoal.title}"?',
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
                _completeSubGoal(subGoal.id);
              },
              child: Text(
                textLang('Завершить'),
                style: const TextStyle(color: AppColor.darkBlue),
              ),
            ),
          ],
        );
      },
    );
  }

  void _completeSubGoal(String subGoalId) {
    final goalBloc = Get.find<GoalBloc>();
    goalBloc.add(CompleteSubGoalEvent(goal.id, subGoalId));
  }
}
