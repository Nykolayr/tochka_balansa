import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/goal/additional_goal.dart';
import 'package:tochka_balansa/data/models/goal/enums_goal.dart';
import 'package:tochka_balansa/presentation/pages/goal/bloc/goal_bloc.dart';
import 'package:tochka_balansa/presentation/pages/goal/widgets/sub_goal_modal.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';

class AdditionalGoalSetupPage extends StatefulWidget {
  final AdditionalGoal template;

  const AdditionalGoalSetupPage({super.key, required this.template});

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

  // Подцели для всех типов целей
  List<SubGoal> subGoals = [];

  @override
  void initState() {
    super.initState();
    _setDefaultValues();
  }

  void _setDefaultValues() {
    _unit = widget.template.unit;
    _targetCount = widget.template.targetCount;
    _reminderText = widget.template.reminderText;

    // Для кастомной цели заполняем контроллеры
    if (widget.template.id == 'custom') {
      _titleController.text = widget.template.title;
      _descriptionController.text = widget.template.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCustom = widget.template.id == 'custom';

    return Consumer<ScreenHeight>(
      builder: (context, res, child) {
        // Вычисляем keyboardHeight один раз
        final keyboardHeight = res.keyboardHeight > 0
            ? res.keyboardHeight
            : 0.0;

        return Scaffold(
          appBar: AppBarWidget(
            title: isCustom
                ? textLang('Создать свою цель')
                : widget.template.title,
            isBack: true,
          ),
          body: Column(
            children: [
              if (!isCustom)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Text(
                    widget.template.description,
                    style: const TextStyle(
                      fontSize: 18, // Сделал больше!
                      color: AppColor.darkBlue,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Для кастомной цели показываем поля ввода
                        if (widget.template.id == 'custom') ...[
                          TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: textLang('Название цели'),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return textLang('Введите название цели');
                              }
                              return null;
                            },
                          ),
                          const Gap(20),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: textLang('Описание цели'),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            maxLines: 3,
                          ),
                        ],
                        TextFormField(
                          initialValue: _reminderText,
                          decoration: InputDecoration(
                            labelText: textLang('Текст напоминания'),
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (value) => _reminderText = value,
                        ),
                        const Gap(16),
                        // Подцели для всех типов целей
                        if (subGoals.isNotEmpty) ...[
                          Text(
                            textLang('Добавленные ${widget.template.goalTo}:'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColor.darkBlue,
                            ),
                          ),
                          const Gap(8),
                          ...subGoals.map(
                            (subGoal) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(subGoal.title),
                                subtitle: Text(
                                  '${subGoal.targetCount} $_unit - ${subGoal.timeOfDayText}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: AppColor.red,
                                  ),
                                  onPressed: () => _removeSubGoal(subGoal.id),
                                ),
                              ),
                            ),
                          ),
                          const Gap(16),
                        ],

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _addSubGoal,
                            icon: const Icon(Icons.add),
                            label: Text(
                              textLang('Добавить задачу'),
                            ), // Заменяем только эту строку
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.darkBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),

                        Gap(
                          20 + keyboardHeight,
                        ), // Используем вычисленное значение
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          bottomSheet: Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              top: 10,
              left: 20,
              right: 20,
              bottom: keyboardHeight > 20
                  ? keyboardHeight - 20
                  : 20, // Используем вычисленное значение
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createGoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.darkBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: Text(
                  textLang('Создать'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _addSubGoal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SubGoalModal(
        goalTo: widget.template.goalTo,
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
      title: widget.template.id == 'custom'
          ? _titleController.text
          : widget.template.title,
      description: widget.template.id == 'custom'
          ? _descriptionController.text
          : widget.template.description,
      createdAt: DateTime.now(),
      deadlineType: DeadlineType.fixed, // Теперь DeadlineType доступен
      targetDate: DateTime.now().add(const Duration(days: 30)),
      targetCount: _targetCount,
      unit: _unit,
      goalTo: widget.template.goalTo,
      reminderText: _reminderText,
      subGoals: subGoals,
      icon: widget.template.icon,
    );

    final goalBloc = Get.find<GoalBloc>();
    goalBloc.add(AddAdditionalGoalEvent(goal));

    Navigator.pop(context);
    Navigator.pop(context);
  }
}
