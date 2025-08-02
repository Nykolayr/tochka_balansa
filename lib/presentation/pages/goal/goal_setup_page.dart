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
  TimeInterval selectedTimeInterval = TimeInterval.threeMonths;
  DeadlineType deadlineType = DeadlineType.fixed;
  DateTime? customTargetDate; // Для ручной установки даты

  @override
  void initState() {
    super.initState();
    _updateTimeIntervalForGoalType(selectedGoalType);
  }

  void _updateTimeIntervalForGoalType(GoalType goalType) {
    setState(() {
      switch (goalType) {
        case GoalType.loseWeight:
          selectedTimeInterval = TimeInterval.threeMonths; // 3 месяца
          deadlineType = DeadlineType.fixed;
          break;
        case GoalType.gainWeight:
          selectedTimeInterval = TimeInterval.threeMonths; // 3 месяца
          deadlineType = DeadlineType.fixed;
          break;
        case GoalType.maintain:
          selectedTimeInterval =
              TimeInterval.oneMonth; // не важно для бессрочного
          deadlineType = DeadlineType.flexible; // бессрочный
          break;
        case GoalType.none:
          selectedTimeInterval = TimeInterval.oneMonth;
          deadlineType = DeadlineType.fixed;
          break;
      }
    });
  }

  String _getRecommendedDurationText(GoalType goalType) {
    switch (goalType) {
      case GoalType.loseWeight:
        return textLang('Рекомендуемый срок: 3 месяца');
      case GoalType.gainWeight:
        return textLang('Рекомендуемый срок: 3 месяца');
      case GoalType.maintain:
        return textLang('Рекомендуемый срок: бессрочно');
      case GoalType.none:
        return textLang('Рекомендуемый срок: 1 месяц');
    }
  }

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
        child: SingleChildScrollView(
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
                          _updateTimeIntervalForGoalType(value);
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
                  textLang('Промежуток времени'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkBlue,
                  ),
                ),
                const SizedBox(height: 8),
                // Подсказка о рекомендуемом сроке
                Text(
                  _getRecommendedDurationText(selectedGoalType),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColor.grey,
                    fontStyle: FontStyle.italic,
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
                    child: DropdownButton<TimeInterval>(
                      value: selectedTimeInterval,
                      isExpanded: true,
                      items: TimeInterval.values.map((interval) {
                        return DropdownMenuItem(
                          value: interval,
                          child: Text(interval.title),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedTimeInterval = value;
                            customTargetDate = null; // Сбрасываем ручную дату
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Показываем дату достижения цели
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColor.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColor.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${textLang('Дата достижения')}: ${(customTargetDate ?? DateTime.now().add(selectedTimeInterval.duration)).day.toString().padLeft(2, '0')}.${(customTargetDate ?? DateTime.now().add(selectedTimeInterval.duration)).month.toString().padLeft(2, '0')}.${(customTargetDate ?? DateTime.now().add(selectedTimeInterval.duration)).year}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColor.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Кнопка для ручной установки даты
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: customTargetDate ?? DateTime.now().add(selectedTimeInterval.duration),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 2)), // 2 года
                      );
                      if (date != null) {
                        setState(() {
                          customTargetDate = date;
                        });
                      }
                    },
                    icon: const Icon(Icons.edit_calendar, size: 16),
                    label: Text(textLang('Установить дату вручную')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColor.darkBlue,
                      side: const BorderSide(color: AppColor.darkBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 40),

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

              const SizedBox(height: 12),

              // Подсказка о возможности изменения цели
              Center(
                child: Text(
                  textLang('Цель всегда можно будет изменить в разделе "Цели"'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColor.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createGoal() {
    final goal = UserGoal(
      goalType: selectedGoalType,
      deadlineType: deadlineType,
      targetWeight: targetWeight,
      targetDate: deadlineType == DeadlineType.fixed
          ? customTargetDate ?? DateTime.now().add(selectedTimeInterval.duration)
          : null,
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
