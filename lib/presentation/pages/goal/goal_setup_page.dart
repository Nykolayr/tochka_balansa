import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/colors.dart';
import 'package:tochka_balansa/data/models/goal/enums_goal.dart';
import 'package:tochka_balansa/data/models/goal/user_goal.dart';
import 'package:tochka_balansa/presentation/pages/goal/bloc/goal_bloc.dart';
import 'package:tochka_balansa/presentation/widgets/app_toast.dart';
import 'package:tochka_balansa/presentation/pages/main/bloc/main_bloc.dart';

class GoalSetupPage extends StatefulWidget {
  static const String route = '/main/training/setup';

  const GoalSetupPage({super.key});

  @override
  State<GoalSetupPage> createState() => _GoalSetupPageState();
}

class _GoalSetupPageState extends State<GoalSetupPage> {
  GoalType selectedGoalType = GoalType.loseWeight;
  double targetWeight = 70.0;
  DateTime targetDate = DateTime.now().add(const Duration(days: 30));
  DeadlineType deadlineType = DeadlineType.fixed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(textLang('Настройка цели')),
        backgroundColor: AppColor.darkBlue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Тип цели
            Text(
              textLang('Выберите тип цели'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColor.darkBlue,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<GoalType>(
                  value: selectedGoalType,
                  isExpanded: true,
                  items: GoalType.values
                      .where((type) => type != GoalType.none)
                      .map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(type.title),
                              Text(
                                type.description,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColor.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedGoalType = value;
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Целевой вес
            Text(
              textLang('Целевой вес (кг)'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColor.darkBlue,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: '70.0',
              ),
              onChanged: (value) {
                setState(() {
                  targetWeight = double.tryParse(value) ?? 70.0;
                });
              },
            ),

            const SizedBox(height: 24),

            // Тип срока
            Text(
              textLang('Тип срока'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColor.darkBlue,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<DeadlineType>(
                  value: deadlineType,
                  isExpanded: true,
                  items: DeadlineType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(type.title),
                          Text(
                            type.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColor.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        deadlineType = value;
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Дата достижения цели (только для фиксированного срока)
            if (deadlineType == DeadlineType.fixed) ...[
              Text(
                textLang('Дата достижения цели'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.darkBlue,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: targetDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      targetDate = date;
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColor.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${targetDate.day.toString().padLeft(2, '0')}.${targetDate.month.toString().padLeft(2, '0')}.${targetDate.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],

            const Spacer(),

            // Кнопка создания цели
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _createGoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.darkBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  textLang('Создать цель'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createGoal() {
    final goal = UserGoal(
      goalType: selectedGoalType,
      deadlineType: deadlineType,
      targetWeight: targetWeight,
      targetDate: deadlineType == DeadlineType.fixed ? targetDate : null,
    );

    final goalBloc = Get.find<GoalBloc>();
    goalBloc.add(SetMainGoalEvent(goal));

    // Явно вызываем загрузку целей после сохранения
    Future.delayed(const Duration(milliseconds: 300), () {
      goalBloc.add(const LoadGoalsEvent());

      // Переходим на главную страницу и переключаемся на таб "Цели" (индекс 2)
      final mainBloc = Get.find<MainBloc>();
      mainBloc.add(GoToPageEvent(2)); // 2 - индекс таба "Цели" (training)

      // Используем GoRouter для навигации
      context.go('/main');

      AppToast.show('${textLang('Цель создана')}: ${goal.goalType.title}');
    });
  }
}
