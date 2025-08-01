import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/colors.dart';
import 'package:tochka_balansa/data/models/goal/enums_goal.dart';
import 'package:tochka_balansa/data/models/goal/user_goal.dart';
import 'package:tochka_balansa/presentation/pages/goal/bloc/goal_bloc.dart';
import 'package:tochka_balansa/presentation/widgets/app_toast.dart';

class GoalEditModal extends StatefulWidget {
  final UserGoal currentGoal;

  const GoalEditModal({super.key, required this.currentGoal});

  @override
  State<GoalEditModal> createState() => _GoalEditModalState();
}

class _GoalEditModalState extends State<GoalEditModal> {
  late GoalType selectedGoalType;
  late double targetWeight;
  late DateTime targetDate;
  late DeadlineType deadlineType;

  @override
  void initState() {
    super.initState();
    // Инициализируем поля текущими значениями цели
    selectedGoalType = widget.currentGoal.goalType;
    targetWeight = widget.currentGoal.targetWeight;
    targetDate =
        widget.currentGoal.targetDate ??
        DateTime.now().add(const Duration(days: 90));
    deadlineType = widget.currentGoal.deadlineType;
  }

  void _updateTargetDateForGoalType(GoalType goalType) {
    setState(() {
      switch (goalType) {
        case GoalType.loseWeight:
          targetDate = DateTime.now().add(const Duration(days: 90)); // 3 месяца
          deadlineType = DeadlineType.fixed;
          break;
        case GoalType.gainWeight:
          targetDate = DateTime.now().add(const Duration(days: 90)); // 3 месяца
          deadlineType = DeadlineType.fixed;
          break;
        case GoalType.maintain:
          targetDate = DateTime.now().add(
            const Duration(days: 30),
          ); // не важно для бессрочного
          deadlineType = DeadlineType.flexible; // бессрочный
          break;
        case GoalType.none:
          targetDate = DateTime.now().add(const Duration(days: 30));
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Заголовок с кнопкой закрытия
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColor.darkBlue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Text(
                  textLang('Редактирование цели'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          // Содержимое модального окна
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Тип цели
                  Text(
                    textLang('Выберите тип цели'),
                    style: const TextStyle(
                      fontSize: 16,
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
                              _updateTargetDateForGoalType(value);
                            });
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Целевой вес
                  Text(
                    textLang('Целевой вес (кг)'),
                    style: const TextStyle(
                      fontSize: 16,
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
                    controller: TextEditingController(
                      text: targetWeight.toString(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        targetWeight = double.tryParse(value) ?? 70.0;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // Тип срока
                  Text(
                    textLang('Тип срока'),
                    style: const TextStyle(
                      fontSize: 16,
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

                  const SizedBox(height: 20),

                  // Дата достижения цели (только для фиксированного срока)
                  if (deadlineType == DeadlineType.fixed) ...[
                    Text(
                      textLang('Дата достижения цели'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColor.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Подсказка о рекомендуемом сроке
                    Text(
                      _getRecommendedDurationText(selectedGoalType),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColor.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: targetDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
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

                  const SizedBox(height: 30),

                  // Кнопки действий
                  Row(
                    children: [
                      // Кнопка удаления
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _deleteGoal,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            textLang('Удалить'),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Кнопка сохранения
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.darkBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            textLang('Сохранить'),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    final updatedGoal = UserGoal(
      goalType: selectedGoalType,
      deadlineType: deadlineType,
      targetWeight: targetWeight,
      targetDate: deadlineType == DeadlineType.fixed ? targetDate : null,
    );

    final goalBloc = Get.find<GoalBloc>();
    goalBloc.add(SetMainGoalEvent(updatedGoal));

    // Явно вызываем загрузку целей после сохранения
    Future.delayed(const Duration(milliseconds: 300), () {
      goalBloc.add(const LoadGoalsEvent());
    });

    AppToast.show(
      '${textLang('Цель обновлена')}: ${updatedGoal.goalType.title}',
    );

    // Закрываем модальное окно
    Navigator.of(context).pop();
  }

  void _deleteGoal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(textLang('Удалить цель?')),
          content: Text(
            textLang(
              'Вы уверены, что хотите удалить главную цель? Это действие нельзя отменить.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(textLang('Отмена')),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _confirmDelete();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(textLang('Удалить')),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete() {
    final emptyGoal = UserGoal.init();
    final goalBloc = Get.find<GoalBloc>();
    goalBloc.add(SetMainGoalEvent(emptyGoal));

    // Явно вызываем загрузку целей после удаления
    Future.delayed(const Duration(milliseconds: 300), () {
      goalBloc.add(const LoadGoalsEvent());
    });

    AppToast.show(textLang('Цель удалена'));

    // Закрываем модальное окно
    Navigator.of(context).pop();
  }
}
