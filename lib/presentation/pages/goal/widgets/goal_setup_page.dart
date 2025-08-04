import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/goal/additional_goal.dart';
import 'package:tochka_balansa/data/models/goal/enums_goal.dart';
import 'package:tochka_balansa/presentation/pages/goal/bloc/goal_bloc.dart';
import 'package:tochka_balansa/presentation/pages/goal/widgets/sub_goal_modal.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';

class AdditionalGoalSetupPage extends StatefulWidget {
  final AdditionalGoalType goalType;

  const AdditionalGoalSetupPage({super.key, required this.goalType});

  @override
  State<AdditionalGoalSetupPage> createState() =>
      _AdditionalGoalSetupPageState();
}

class _AdditionalGoalSetupPageState extends State<AdditionalGoalSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Универсальные поля
  int _targetCount = 0;
  String _unit = '';
  String _reminderText = '';

  // Поля для подцелей (лекарства)
  List<SubGoal> subGoals = [];

  @override
  void initState() {
    super.initState();
    _setDefaultValues();
  }

  void _setDefaultValues() {
    _unit = widget.goalType.defaultUnit;

    switch (widget.goalType) {
      case AdditionalGoalType.exercise:
        _targetCount = 50;
        _reminderText = 'Сделать упражнения';
        break;
      case AdditionalGoalType.reading:
        _targetCount = 100;
        _reminderText = 'Прочитать страницы';
        break;
      case AdditionalGoalType.water:
        _targetCount = 2;
        _reminderText = 'Выпить воду';
        break;
      case AdditionalGoalType.medication:
        _targetCount = 30;
        _reminderText = 'Принять лекарство';
        break;
      case AdditionalGoalType.custom:
        _targetCount = 10;
        _reminderText = 'Выполнить задачу';
        _titleController.text = textLang('Моя цель');
        _descriptionController.text = textLang('Описание моей цели');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: widget.goalType.title,
        isBack: true,
        actions: [
          TextButton(
            onPressed: _createGoal,
            child: Text(
              textLang('Создать'),
              style: const TextStyle(
                color: AppColor.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Поля для custom типа цели
              if (widget.goalType == AdditionalGoalType.custom) ...[
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: textLang('Название цели'),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return textLang('Введите название цели');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: textLang('Описание цели'),
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
              ],

              // Поля для обычных целей (не лекарства)
              if (widget.goalType != AdditionalGoalType.medication) ...[
                TextFormField(
                  initialValue: _targetCount.toString(),
                  decoration: InputDecoration(
                    labelText: textLang('Целевое количество'),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _targetCount = int.tryParse(value) ?? 0,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  initialValue: _unit,
                  decoration: InputDecoration(
                    labelText: textLang('Единица измерения'),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) => _unit = value,
                ),
                const SizedBox(height: 16),
              ],

              // Поля для лекарств
              if (widget.goalType == AdditionalGoalType.medication) ...[
                // Список подцелей (лекарств)
                if (subGoals.isNotEmpty) ...[
                  Text(
                    textLang('Добавленные лекарства:'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColor.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...subGoals.map(
                    (subGoal) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(subGoal.title),
                        subtitle: Text(
                          '${subGoal.targetCount} $_unit - ${subGoal.timeOfDayText}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: AppColor.red),
                          onPressed: () => _removeSubGoal(subGoal.id),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addSubGoal,
                    icon: const Icon(Icons.add),
                    label: Text(textLang('Добавить лекарство')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.darkBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextFormField(
                initialValue: _reminderText,
                decoration: InputDecoration(
                  labelText: textLang('Текст напоминания'),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) => _reminderText = value,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addSubGoal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SubGoalModal(
        goalTo: widget.goalType.defaultGoalTo,
        unit: _unit,
        onSubGoalAdded: (subGoal) {
          setState(() {
            subGoals.add(subGoal);
          });
        },
      ),
    );
  }

  void _removeSubGoal(String id) {
    setState(() {
      subGoals.removeWhere((goal) => goal.id == id);
    });
  }

  void _createGoal() {
    if (!_formKey.currentState!.validate()) return;

    final goal = AdditionalGoal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: widget.goalType == AdditionalGoalType.custom
          ? _titleController.text
          : widget.goalType.title,
      description: widget.goalType == AdditionalGoalType.custom
          ? _descriptionController.text
          : widget.goalType.description,
      createdAt: DateTime.now(),
      deadlineType: DeadlineType.fixed,
      targetDate: DateTime.now().add(const Duration(days: 30)),
      targetCount: _targetCount,
      unit: _unit,
      goalTo: widget.goalType.defaultGoalTo,
      reminderText: _reminderText,
      subGoals: subGoals,
    );

    // Добавляем цель через GoalBloc
    final goalBloc = Get.find<GoalBloc>();
    goalBloc.add(AddAdditionalGoalEvent(goal));

    // Возвращаемся на предыдущую страницу
    Navigator.pop(context);
    Navigator.pop(context);
  }
}
