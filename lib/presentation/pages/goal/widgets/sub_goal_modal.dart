import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
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

  // Количество за прием
  int _amountPerDose = 1;

  // Тип курса
  CourseType _courseType = CourseType.byDays;

  // Поля для курса по дням
  int _courseDays = 7;

  // Поля для курса по общему количеству
  int _totalAmount = 30;

  // Время приема
  bool _takeMorning = false;
  bool _takeLunch = false;
  bool _takeEvening = false;
  TimeOfDay _morningTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _lunchTime = const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Consumer<ScreenHeight>(
      builder: (context, res, child) {
        final keyboardHeight = res.keyboardHeight > 0
            ? res.keyboardHeight
            : 0.0;

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
                        // Название
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

                        // Количество за прием
                        TextFormField(
                          initialValue: _amountPerDose.toString(),
                          decoration: InputDecoration(
                            labelText: 'Количество ${widget.unit} за прием',
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) =>
                              _amountPerDose = int.tryParse(value) ?? 1,
                        ),
                        const SizedBox(height: 16),

                        // Тип курса
                        Text(
                          textLang('Тип курса:'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColor.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColor.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<CourseType>(
                              value: _courseType,
                              isExpanded: true,
                              items: CourseType.values.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    _courseType = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Поля в зависимости от типа курса
                        if (_courseType == CourseType.byDays) ...[
                          TextFormField(
                            initialValue: _courseDays.toString(),
                            decoration: InputDecoration(
                              labelText: 'Количество дней курса',
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) =>
                                _courseDays = int.tryParse(value) ?? 7,
                          ),
                        ] else ...[
                          TextFormField(
                            initialValue: _totalAmount.toString(),
                            decoration: InputDecoration(
                              labelText: 'Общее количество ${widget.unit}',
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) =>
                                _totalAmount = int.tryParse(value) ?? 30,
                          ),
                        ],
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

                        // Описание
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: textLang('Описание'),
                            border: const OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 20),

                        // Отступ для клавиатуры
                        SizedBox(height: keyboardHeight),

                        // Кнопки действий
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColor.darkBlue,
                                  side: const BorderSide(
                                    color: AppColor.darkBlue,
                                  ),
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
      },
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

    // Вычисляем targetCount в зависимости от типа курса
    int targetCount;
    if (_courseType == CourseType.byDays) {
      final dosesPerDay = _getDosesPerDay();
      targetCount = _courseDays * _amountPerDose * dosesPerDay;
    } else {
      targetCount = _totalAmount;
    }

    final subGoal = SubGoal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      targetCount: targetCount,
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
      amountPerDose: _amountPerDose,
      courseType: _courseType,
      courseDays: _courseType == CourseType.byDays ? _courseDays : null,
      totalAmount: _courseType == CourseType.byTotal ? _totalAmount : null,
    );

    widget.onSubGoalAdded(subGoal);
    Navigator.pop(context);
  }

  // Количество доз в день
  int _getDosesPerDay() {
    int doses = 0;
    if (_takeMorning) doses++;
    if (_takeLunch) doses++;
    if (_takeEvening) doses++;
    return doses;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
