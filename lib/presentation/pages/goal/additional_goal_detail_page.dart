import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/colors.dart';
import 'package:tochka_balansa/data/models/goal/additional_goal.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';

class AdditionalGoalDetailPage extends StatelessWidget {
  final AdditionalGoal goal;

  const AdditionalGoalDetailPage({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: goal.title, isBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Описание цели
            if (goal.description.isNotEmpty) ...[
              Text(
                goal.description,
                style: const TextStyle(fontSize: 16, color: AppColor.greyText),
              ),
              const SizedBox(height: 24),
            ],

            // Общий прогресс
            _buildOverallProgress(),
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
            ...goal.subGoals.map((subGoal) => _buildSubGoalCard(subGoal)),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallProgress() {
    final progress = goal.progressPercentage;
    final completedSubGoals = goal.subGoals
        .where((sg) => sg.isCompleted)
        .length;
    final totalSubGoals = goal.subGoals.length;

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

  Widget _buildSubGoalCard(SubGoal subGoal) {
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
                      decoration: subGoal.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
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
                  onPressed: () {
                    // TODO: Добавить логику закрытия подзадачи
                  },
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
}
