import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/colors.dart';
import 'package:tochka_balansa/data/models/goal/enums_goal.dart';
import 'package:tochka_balansa/data/models/goal/user_goal.dart';
import 'package:tochka_balansa/presentation/pages/goal/bloc/goal_bloc.dart';
import 'package:tochka_balansa/presentation/pages/goal/widgets/goal_card_widget.dart';

class GoalPage extends StatefulWidget {
  const GoalPage({super.key});

  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  @override
  void initState() {
    super.initState();
    // Загружаем цели при инициализации страницы
    Get.find<GoalBloc>().add(const LoadGoalsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<GoalBloc, GoalState>(
        bloc: Get.find<GoalBloc>(),
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return _buildContent(state);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Открыть страницу добавления дополнительной цели
          // Get.to(() => const AdditionalGoalSetupPage());
        },
        backgroundColor: AppColor.darkBlue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(GoalState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Text(
            textLang('Цели'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColor.darkBlue,
            ),
          ),
          const SizedBox(height: 24),

          // Главная цель
          if (state.mainGoal.hasMainGoal) ...[
            Text(
              textLang('Главная цель'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColor.darkBlue,
              ),
            ),
            const SizedBox(height: 12),
            GoalCardWidget(
              title: state.mainGoal.goalType.title,
              description: _buildMainGoalDescription(state.mainGoal),
              progress: state.mainGoal.progressPercentage,
              daysLeft: state.mainGoal.daysUntilTarget,
              isMainGoal: true,
            ),
            const SizedBox(height: 24),
          ],

          // Дополнительные цели
          Text(
            textLang('Дополнительные цели'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColor.darkBlue,
            ),
          ),
          const SizedBox(height: 12),

          if (state.additionalGoals.isEmpty) ...[
            // Сообщение если нет дополнительных целей
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.grey.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.flag_outlined, size: 48, color: AppColor.grey),
                  const SizedBox(height: 12),
                  Text(
                    textLang('У вас нет дополнительных целей'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColor.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    textLang(
                      'Создайте свою первую цель для отслеживания прогресса',
                    ),
                    style: const TextStyle(fontSize: 14, color: AppColor.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ] else ...[
            // Список дополнительных целей
            Expanded(
              child: ListView.builder(
                itemCount: state.additionalGoals.length,
                itemBuilder: (context, index) {
                  final goal = state.additionalGoals[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GoalCardWidget(
                      title: goal.title,
                      description: goal.description,
                      progress: 0.0, // TODO: Добавить логику прогресса
                      daysLeft: 0, // TODO: Добавить логику дней
                      isMainGoal: false,
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _buildMainGoalDescription(UserGoal goal) {
    String description = goal.goalType.description;

    if (goal.targetWeight > 0) {
      description += ' до ${goal.targetWeight} кг';
    }

    if (goal.deadlineType == DeadlineType.fixed && goal.targetDate != null) {
      description +=
          ' до ${goal.targetDate!.day.toString().padLeft(2, '0')}.${goal.targetDate!.month.toString().padLeft(2, '0')}.${goal.targetDate!.year}';
    }

    return description;
  }
}
