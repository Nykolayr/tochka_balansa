import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/goal/additional_goal.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/presentation/pages/goal/bloc/goal_bloc.dart';
import 'package:tochka_balansa/presentation/pages/goal/widgets/goal_setup_page.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';

class AddAdditionalGoalPage extends StatelessWidget {
  const AddAdditionalGoalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: textLang('Добавить цель'), isBack: true),
      body: BlocBuilder<GoalBloc, GoalState>(
        bloc: Get.find<GoalBloc>(),
        builder: (context, state) {
          // Сортируем шаблоны: сначала стандартные, потом пользовательские
          final sortedTemplates = List<AdditionalGoal>.from(state.goalTypes);
          sortedTemplates.sort((a, b) {
            // Если один из них "Своя цель" (id == 'custom'), он идет в конец
            if (a.id == 'custom') return 1;
            if (b.id == 'custom') return -1;

            // Если оба пользовательские шаблоны (начинаются с 'template_'), сортируем по дате создания
            if (a.id.startsWith('template_') && b.id.startsWith('template_')) {
              return b.createdAt.compareTo(a.createdAt); // Новые шаблоны сверху
            }

            // Если один пользовательский, а другой стандартный
            if (a.id.startsWith('template_'))
              return 1; // Пользовательские после стандартных
            if (b.id.startsWith('template_')) return -1;

            return 0; // Стандартные шаблоны остаются в исходном порядке
          });

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                textLang('Выберите тип цели'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColor.darkBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                textLang(
                  'Выберите категорию, которая лучше всего описывает вашу цель',
                ),
                style: const TextStyle(fontSize: 16, color: AppColor.grey),
              ),
              const SizedBox(height: 24),
              ...sortedTemplates.map((goal) => _GoalTypeTile(goal: goal)),
            ],
          );
        },
      ),
    );
  }
}

class _GoalTypeTile extends StatelessWidget {
  final AdditionalGoal goal;

  const _GoalTypeTile({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          goal.icon ?? Icons.flag,
          color: AppColor.darkBlue,
          size: 28,
        ),
        title: Text(
          goal.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColor.darkBlue,
          ),
        ),
        subtitle: Text(
          goal.description,
          style: const TextStyle(fontSize: 14, color: AppColor.grey),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: AppColor.grey,
          size: 16,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdditionalGoalSetupPage(template: goal),
            ),
          );
        },
      ),
    );
  }
}
