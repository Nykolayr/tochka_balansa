import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/colors.dart';
import 'package:tochka_balansa/presentation/pages/goal/bloc/goal_bloc.dart';
import 'package:tochka_balansa/presentation/pages/goal/widgets/goal_card_widget.dart';
import 'package:tochka_balansa/presentation/pages/goal/widgets/goal_edit_modal.dart';
import 'package:tochka_balansa/presentation/pages/main/bloc/main_bloc.dart';

class GoalPage extends StatelessWidget {
  const GoalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoalBloc, GoalState>(
      bloc: Get.find<GoalBloc>(),
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Главная цель
              ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      textLang('Главная цель'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColor.darkBlue,
                      ),
                    ),
                    if (!state.mainGoal.hasMainGoal)
                      ElevatedButton(
                        onPressed: () {
                          // Переходим на главную страницу (индекс 0)
                          final mainBloc = Get.find<MainBloc>();
                          mainBloc.add(GoToPageEvent(0));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.darkBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(textLang('Добавить')),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Показываем виджет только если цель установлена
                if (state.mainGoal.hasMainGoal) ...[
                  GoalCardWidget(
                    goal: state.mainGoal,
                    isMainGoal: true,
                    onTap: () {
                      // Показываем модальное окно редактирования главной цели
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) =>
                            GoalEditModal(currentGoal: state.mainGoal),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ],

              // Дополнительные цели
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    textLang('Дополнительные цели'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColor.darkBlue,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.push('/main/training/add-additional');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.darkBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(textLang('Добавить')),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Список дополнительных целей
              if (state.additionalGoals.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.flag_outlined,
                          size: 64,
                          color: AppColor.greyText.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          textLang('Нет дополнительных целей'),
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColor.greyText.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          textLang('Добавьте свою первую цель'),
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColor.greyText.withValues(alpha: 0.5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...state.additionalGoals.map(
                  (goal) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GoalCardWidget(
                      goal: goal,
                      isMainGoal: false,
                      onTap: () {
                        context.push('/main/training/goal-detail', extra: goal);
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
