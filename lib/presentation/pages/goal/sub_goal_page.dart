import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/goal/additional_goal.dart';
import 'package:tochka_balansa/data/models/goal/enums_goal.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';

class SubGoalPage extends StatefulWidget {
  final String goalTo;
  final String unit;
  final Function(SubGoal subGoal) onSubGoalAdded;

  const SubGoalPage({
    super.key,
    required this.goalTo,
    required this.unit,
    required this.onSubGoalAdded,
  });

  @override
  State<SubGoalPage> createState() => _SubGoalPageState();
}

class _SubGoalPageState extends State<SubGoalPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Focus nodes для автоматического скролла
  final _titleFocusNode = FocusNode();
  final _amountFocusNode = FocusNode();
  final _totalAmountFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();

  // Количество за прием
  int _amountPerDose = 1;

  // Тип достижения цели
  GoalAchievementType _achievementType = GoalAchievementType.byTime;

  // Поля для достижения цели по времени
  TimeInterval _timeInterval = TimeInterval.oneMonth;

  // Поля для достижения цели по общему количеству
  int _totalAmount = 30;

  // Время приема
  bool _takeMorning = false;
  bool _takeLunch = false;
  bool _takeEvening = false;
  TimeOfDay _morningTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _lunchTime = const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _setupFocusListeners();

    // Добавляем слушатель для обновления состояния кнопки
    _titleController.addListener(() {
      setState(() {});
    });
  }

  // Геттер для проверки валидности формы
  bool get _isFormValid {
    final hasTitle = _titleController.text.trim().isNotEmpty;
    final hasTimeSelected = _takeMorning || _takeLunch || _takeEvening;
    return hasTitle && hasTimeSelected;
  }

  void _setupFocusListeners() {
    // Автоматический скролл при фокусе на полях ввода
    _titleFocusNode.addListener(() {
      if (_titleFocusNode.hasFocus) {
        _scrollToField(_titleFocusNode);
      }
    });

    _amountFocusNode.addListener(() {
      if (_amountFocusNode.hasFocus) {
        _scrollToField(_amountFocusNode);
      }
    });

    _totalAmountFocusNode.addListener(() {
      if (_totalAmountFocusNode.hasFocus) {
        _scrollToField(_totalAmountFocusNode);
      }
    });

    _descriptionFocusNode.addListener(() {
      if (_descriptionFocusNode.hasFocus) {
        _scrollToField(_descriptionFocusNode);
      }
    });
  }

  void _scrollToField(FocusNode focusNode) {
    // Небольшая задержка для корректного скролла
    Future.delayed(const Duration(milliseconds: 300), () {
      if (focusNode.hasFocus && _scrollController.hasClients) {
        // Находим позицию поля в ScrollView
        final RenderBox? renderBox =
            focusNode.context?.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero);
          final scrollPosition = _scrollController.position.pixels;
          final viewportHeight = _scrollController.position.viewportDimension;

          // Вычисляем, нужно ли скроллить
          if (position.dy > viewportHeight * 0.7) {
            final targetScroll =
                scrollPosition + (position.dy - viewportHeight * 0.7) + 50;
            _scrollController.animateTo(
              targetScroll,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScreenHeight>(
      builder: (context, res, child) {
        final keyboardHeight = res.keyboardHeight > 0
            ? res.keyboardHeight
            : 0.0;

        return Scaffold(
          appBar: AppBarWidget(title: 'Добавить задачу', isBack: true),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Название
                  TextFormField(
                    controller: _titleController,
                    focusNode: _titleFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Название задачи',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите название задачи';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Количество за прием
                  TextFormField(
                    focusNode: _amountFocusNode,
                    initialValue: _amountPerDose.toString(),
                    decoration: InputDecoration(
                      labelText:
                          'Количество ${widget.unit} за один раз', // Изменили с 'за прием' на 'за один раз'
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) =>
                        _amountPerDose = int.tryParse(value) ?? 1,
                  ),
                  const SizedBox(height: 16),

                  // Тип достижения цели
                  Text(
                    textLang('Тип достижения задачи:'),
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
                      child: DropdownButton<GoalAchievementType>(
                        value: _achievementType,
                        isExpanded: true,
                        items: GoalAchievementType.values.map((type) {
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
                              _achievementType = value;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Поля в зависимости от типа достижения цели
                  if (_achievementType == GoalAchievementType.byTime) ...[
                    Text(
                      textLang('Период времени:'),
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
                        child: DropdownButton<TimeInterval>(
                          value: _timeInterval,
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
                                _timeInterval = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ] else ...[
                    TextFormField(
                      focusNode: _totalAmountFocusNode,
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
                    focusNode: _descriptionFocusNode,
                    decoration: InputDecoration(
                      labelText: textLang('Описание'),
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),

                  // Отступ для клавиатуры
                  SizedBox(height: keyboardHeight + 100),
                ],
              ),
            ),
          ),
          bottomSheet: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isFormValid ? _createSubGoal : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFormValid
                      ? AppColor.darkBlue
                      : AppColor.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: Text(
                  textLang('Добавить'),
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

    // Вычисляем targetCount в зависимости от типа достижения цели
    int targetCount;
    if (_achievementType == GoalAchievementType.byTime) {
      final dosesPerDay = _getDosesPerDay();
      targetCount = _timeInterval.days * _amountPerDose * dosesPerDay;
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
      achievementType: _achievementType,
      timeInterval: _achievementType == GoalAchievementType.byTime
          ? _timeInterval
          : null,
      totalAmount: _achievementType == GoalAchievementType.byTotal
          ? _totalAmount
          : null,
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
    _scrollController.dispose();
    _titleFocusNode.dispose();
    _amountFocusNode.dispose();
    _totalAmountFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }
}
