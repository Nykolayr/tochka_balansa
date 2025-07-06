import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/theme/colors.dart';

class GoalCardWidget extends StatelessWidget {
  final String title;
  final String description;
  final double progress;
  final int daysLeft;
  final bool isMainGoal;

  const GoalCardWidget({
    super.key,
    required this.title,
    required this.description,
    required this.progress,
    required this.daysLeft,
    required this.isMainGoal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                isMainGoal ? Icons.flag : Icons.star,
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
    );
  }
}
