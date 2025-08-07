import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:go_router/go_router.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/colors.dart';
import 'package:tochka_balansa/presentation/pages/goal/bloc/goal_bloc.dart';
import 'package:tochka_balansa/presentation/pages/goal/widgets/goal_card_widget.dart';
import 'package:tochka_balansa/presentation/pages/goal/widgets/goal_edit_modal.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final goalBloc = Get.find<GoalBloc>();
      goalBloc.add(const LoadGoalsEvent());
      Logger.i('GoalPage: Загружаем цели при инициализации страницы');
    });
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
    );
  }

  Widget _buildContent(GoalState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Главная цель
          if (state.mainGoal.hasMainGoal) ...[
            Text(
              textLang('Главная цель'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColor.darkBlue,
              ),
            ),
            const SizedBox(height: 12),
            GoalCardWidget(
              goal: state.mainGoal,
              isMainGoal: true,
              onTap: () {
                // Открываем модальное окно для редактирования главной цели
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: GoalEditModal(currentGoal: state.mainGoal),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],

          // Дополнительные цели
          Row(
            children: [
              Text(
                textLang('Дополнительные цели'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColor.darkBlue,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  context.push('/main/training/add-additional');
                },
                icon: const Icon(Icons.add, size: 16),
                label: Text(textLang('Добавить')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.darkBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // Добавляем небольшой отступ

          if (state.additionalGoals.isEmpty) ...[
            // Сообщение если нет дополнительных целей
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColor.grey.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColor.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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
                      goal: goal,
                      isMainGoal: false,
                      onTap: () {
                        // Переходим на страницу деталей цели через роутер
                        context.push('/main/training/goal-detail', extra: goal);
                      },
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
}
