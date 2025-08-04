import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/goal/additional_goal.dart';
import 'package:tochka_balansa/data/models/goal/enums_goal.dart'; // Добавляю импорт
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/presentation/pages/goal/bloc/goal_bloc.dart';
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
          final templates = state.goalTypes;

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
              ...templates.map((goal) => _GoalTypeTile(goal: goal)),
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
              builder: (context) => _GoalSetupPage(template: goal),
            ),
          );
        },
      ),
    );
  }
}

class _GoalSetupPage extends StatefulWidget {
  final AdditionalGoal template;

  const _GoalSetupPage({required this.template});

  @override
  State<_GoalSetupPage> createState() => _GoalSetupPageState();
}

class _GoalSetupPageState extends State<_GoalSetupPage> {
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
    return Scaffold(
      appBar: AppBarWidget(
        title: widget.template.id == 'custom'
            ? textLang('Создать свою цель')
            : widget.template.title,
        isBack: true,
      ),
      body: Form(
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
                const SizedBox(height: 24),
              ],

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
                  label: Text(textLang('Добавить ${widget.template.goalTo}')),
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

              TextFormField(
                initialValue: _reminderText,
                decoration: InputDecoration(
                  labelText: textLang('Текст напоминания'),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) => _reminderText = value,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
              elevation: 0, // Без тени!
              shadowColor: Colors.transparent, // Без тени!
            ),
            child: Text(
              textLang('Создать'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
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
      builder: (context) => _SubGoalModal(
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

class _SubGoalModal extends StatefulWidget {
  final String goalTo;
  final String unit;
  final Function(SubGoal subGoal) onSubGoalAdded;

  const _SubGoalModal({
    required this.goalTo,
    required this.unit,
    required this.onSubGoalAdded,
  });

  @override
  State<_SubGoalModal> createState() => _SubGoalModalState();
}

class _SubGoalModalState extends State<_SubGoalModal> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _targetCount = 1;

  // Время приема
  bool _takeMorning = false;
  bool _takeLunch = false;
  bool _takeEvening = false;
  TimeOfDay _morningTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _lunchTime = const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Заголовок
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColor.darkBlue,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(
                  widget.goalTo == 'лекарство'
                      ? Icons.medication
                      : Icons.add_task,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Добавить ${widget.goalTo}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          // Содержимое
          Flexible(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Название ${widget.goalTo}',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите название ${widget.goalTo}';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      initialValue: _targetCount.toString(),
                      decoration: InputDecoration(
                        labelText: 'Количество ${widget.unit}',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>
                          _targetCount = int.tryParse(value) ?? 1,
                    ),
                    const SizedBox(height: 16),

                    // Время приема
                    Text(
                      textLang('Время выполнения:'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColor.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Card(
                      child: Column(
                        children: [
                          CheckboxListTile(
                            title: Text(textLang('Утром')),
                            value: _takeMorning,
                            onChanged: (value) {
                              setState(() {
                                _takeMorning = value ?? false;
                              });
                            },
                            secondary: _takeMorning
                                ? TextButton(
                                    onPressed: () async {
                                      final time = await showTimePicker(
                                        context: context,
                                        initialTime: _morningTime,
                                      );
                                      if (time != null) {
                                        setState(() {
                                          _morningTime = time;
                                        });
                                      }
                                    },
                                    child: Text(
                                      '${_morningTime.hour.toString().padLeft(2, '0')}:${_morningTime.minute.toString().padLeft(2, '0')}',
                                    ),
                                  )
                                : null,
                          ),
                          CheckboxListTile(
                            title: Text(textLang('В обед')),
                            value: _takeLunch,
                            onChanged: (value) {
                              setState(() {
                                _takeLunch = value ?? false;
                              });
                            },
                            secondary: _takeLunch
                                ? TextButton(
                                    onPressed: () async {
                                      final time = await showTimePicker(
                                        context: context,
                                        initialTime: _lunchTime,
                                      );
                                      if (time != null) {
                                        setState(() {
                                          _lunchTime = time;
                                        });
                                      }
                                    },
                                    child: Text(
                                      '${_lunchTime.hour.toString().padLeft(2, '0')}:${_lunchTime.minute.toString().padLeft(2, '0')}',
                                    ),
                                  )
                                : null,
                          ),
                          CheckboxListTile(
                            title: Text(textLang('Вечером')),
                            value: _takeEvening,
                            onChanged: (value) {
                              setState(() {
                                _takeEvening = value ?? false;
                              });
                            },
                            secondary: _takeEvening
                                ? TextButton(
                                    onPressed: () async {
                                      final time = await showTimePicker(
                                        context: context,
                                        initialTime: _eveningTime,
                                      );
                                      if (time != null) {
                                        setState(() {
                                          _eveningTime = time;
                                        });
                                      }
                                    },
                                    child: Text(
                                      '${_eveningTime.hour.toString().padLeft(2, '0')}:${_eveningTime.minute.toString().padLeft(2, '0')}',
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: textLang('Описание'),
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),

                    // Кнопки действий
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColor.darkBlue,
                              side: const BorderSide(color: AppColor.darkBlue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(textLang('Отмена')),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _createSubGoal,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.darkBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(textLang('Добавить')),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _createSubGoal() {
    if (!_formKey.currentState!.validate()) return;
    if (!_takeMorning && !_takeLunch && !_takeEvening) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(textLang('Выберите хотя бы одно время выполнения')),
        ),
      );
      return;
    }

    final subGoal = SubGoal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      targetCount: _targetCount,
      createdAt: DateTime.now(),
      takeMorning: _takeMorning,
      takeLunch: _takeLunch,
      takeEvening: _takeEvening,
      morningTime: _takeMorning ? _morningTime : null,
      lunchTime: _takeLunch ? _lunchTime : null,
      eveningTime: _takeEvening ? _eveningTime : null,
      description: _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : null,
    );

    widget.onSubGoalAdded(subGoal);
    Navigator.pop(context);
  }
}
