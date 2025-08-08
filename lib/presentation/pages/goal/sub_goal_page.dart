import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/goal/additional_goal.dart';
import 'package:tochka_balansa/data/models/goal/enums_goal.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';
import 'package:tochka_balansa/presentation/pages/scanner/scanner_page.dart';

class SubGoalPage extends StatefulWidget {
  final AdditionalGoal template;

  const SubGoalPage({super.key, required this.template});

  @override
  State<SubGoalPage> createState() => _SubGoalPageState();
}

class _SubGoalPageState extends State<SubGoalPage> {
  final formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountPerDoseController = TextEditingController(text: '1');
  final _totalAmountController = TextEditingController();

  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _amountPerDoseFocusNode = FocusNode();
  final _totalAmountFocusNode = FocusNode();

  final ScrollController _scrollController = ScrollController();

  bool _takeMorning = false;
  bool _takeLunch = false;
  bool _takeEvening = false;
  TimeOfDay? _morningTime;
  TimeOfDay? _lunchTime;
  TimeOfDay? _eveningTime;

  GoalAchievementType _achievementType = GoalAchievementType.byTime;
  TimeInterval _timeInterval = TimeInterval.twoWeeks;

  String _titleError = '';

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_validateForm);

    // Добавляем значения по умолчанию
    _morningTime = const TimeOfDay(hour: 8, minute: 0);
    _lunchTime = const TimeOfDay(hour: 13, minute: 0);
    _eveningTime = const TimeOfDay(hour: 20, minute: 0);

    // Вызываем настройку слушателей фокуса
    _setupFocusListeners();
  }

  @override
  void dispose() {
    _titleController.removeListener(_validateForm);
    _titleController.dispose();
    _descriptionController.dispose();
    _amountPerDoseController.dispose();
    _totalAmountController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _amountPerDoseFocusNode.dispose();
    _totalAmountFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _titleError = '';
    });
  }

  bool get _isFormValid {
    return _titleController.text.trim().isNotEmpty &&
        (_takeMorning || _takeLunch || _takeEvening);
  }

  // Переименовываем метод с подчеркиванием
  void _setupFocusListeners() {
    // Автоматический скролл при фокусе на полях ввода
    _titleFocusNode.addListener(() {
      if (_titleFocusNode.hasFocus) {
        _scrollToField(_titleFocusNode);
      }
    });

    _amountPerDoseFocusNode.addListener(() {
      if (_amountPerDoseFocusNode.hasFocus) {
        _scrollToField(_amountPerDoseFocusNode);
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
    return Scaffold(
      appBar: AppBarWidget(title: textLang('Добавить задачу'), isBack: true),
      body: Consumer<ScreenHeight>(
        builder: (context, screenHeight, child) {
          final keyboardHeight = screenHeight.keyboardHeight.clamp(
            0.0,
            double.infinity,
          );
          final padding = (keyboardHeight * 0.3).clamp(20.0, double.infinity);

          return SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: padding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Название задачи с кнопкой сканера
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _titleController,
                        focusNode: _titleFocusNode,
                        decoration: InputDecoration(
                          labelText: textLang('Название задачи'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          errorText: _titleError,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return textLang('Введите название задачи');
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ScannerPage(),
                          ),
                        );
                        if (result != null && result is Map<String, dynamic>) {
                          setState(() {
                            _titleController.text = result['name'];
                            _achievementType = GoalAchievementType.byTotal;
                            _totalAmountController.text =
                                result['totalQuantity'].toString();
                          });
                        }
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: AppColor.darkBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(12),
                      ),
                      icon: const Icon(Icons.qr_code_scanner),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Количество за прием
                TextFormField(
                  focusNode: _amountPerDoseFocusNode,
                  controller: _amountPerDoseController,
                  decoration: InputDecoration(
                    labelText:
                        'Количество единиц за один раз', // Убираем widget.template.quantityUnit
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _amountPerDoseController.text = value,
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
                    controller: _totalAmountController,
                    decoration: InputDecoration(
                      labelText:
                          'Общее количество', // Убираем widget.template.quantityUnit
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _totalAmountController.text = value,
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
                                    initialTime:
                                        _morningTime ??
                                        const TimeOfDay(hour: 8, minute: 0),
                                  );
                                  if (time != null) {
                                    setState(() {
                                      _morningTime = time;
                                    });
                                  }
                                },
                                child: Text(
                                  '${_morningTime?.hour.toString().padLeft(2, '0')}:${_morningTime?.minute.toString().padLeft(2, '0')}',
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
                                    initialTime:
                                        _lunchTime ??
                                        const TimeOfDay(hour: 13, minute: 0),
                                  );
                                  if (time != null) {
                                    setState(() {
                                      _lunchTime = time;
                                    });
                                  }
                                },
                                child: Text(
                                  '${_lunchTime?.hour.toString().padLeft(2, '0')}:${_lunchTime?.minute.toString().padLeft(2, '0')}',
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
                                    initialTime:
                                        _eveningTime ??
                                        const TimeOfDay(hour: 20, minute: 0),
                                  );
                                  if (time != null) {
                                    setState(() {
                                      _eveningTime = time;
                                    });
                                  }
                                },
                                child: Text(
                                  '${_eveningTime?.hour.toString().padLeft(2, '0')}:${_eveningTime?.minute.toString().padLeft(2, '0')}',
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
          );
        },
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isFormValid ? _addSubGoal : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isFormValid
                ? AppColor.darkBlue
                : AppColor.greyText,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            textLang('Добавить'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  void _addSubGoal() {
    // Убираем проверку формы, которая вызывает ошибку
    // if (!_formKey.currentState!.validate()) return;

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
      targetCount =
          _timeInterval.days *
          (int.tryParse(_amountPerDoseController.text) ?? 1) *
          dosesPerDay;
    } else {
      targetCount = int.tryParse(_totalAmountController.text) ?? 30;
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
      amountPerDose: int.tryParse(_amountPerDoseController.text) ?? 1,
      achievementType: _achievementType,
      timeInterval: _achievementType == GoalAchievementType.byTime
          ? _timeInterval
          : null,
      totalAmount: _achievementType == GoalAchievementType.byTotal
          ? int.tryParse(_totalAmountController.text) ?? 30
          : null,
    );

    Navigator.pop(context, subGoal);
  }

  // Количество доз в день
  int _getDosesPerDay() {
    int doses = 0;
    if (_takeMorning) doses++;
    if (_takeLunch) doses++;
    if (_takeEvening) doses++;
    return doses;
  }
}
