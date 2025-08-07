import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/goal/additional_goal.dart';

class SubGoalModal extends StatefulWidget {
  final String goalTo;
  final String unit;
  final Function(SubGoal subGoal) onSubGoalAdded;

  const SubGoalModal({
    super.key,
    required this.goalTo,
    required this.unit,
    required this.onSubGoalAdded,
  });

  @override
  State<SubGoalModal> createState() => _SubGoalModalState();
}

class _SubGoalModalState extends State<SubGoalModal> {
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
      amountPerDose: _targetCount, // Количество за прием
      courseType: CourseType.byDays, // По умолчанию по дням
      courseDays: 7, // По умолчанию 7 дней
    );

    widget.onSubGoalAdded(subGoal);
    Navigator.pop(context);
  }
}
