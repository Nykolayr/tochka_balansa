import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/colors.dart';
import 'package:tochka_balansa/presentation/pages/goal/bloc/goal_bloc.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';
import 'package:tochka_balansa/presentation/pages/goal/widgets/archived_goal_card_widget.dart';

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
