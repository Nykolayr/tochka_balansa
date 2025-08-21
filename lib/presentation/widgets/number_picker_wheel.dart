import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/theme/theme.dart';

class NumberPickerWheel extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final String label;
  final String unit;
  final double min;
  final double max;
  final int decimalPlaces;
  final double step;

  const NumberPickerWheel({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    required this.unit,
    required this.min,
    required this.max,
    this.decimalPlaces = 0,
    this.step = 1.0,
  });

  @override
  State<NumberPickerWheel> createState() => _NumberPickerWheelState();
}

class _NumberPickerWheelState extends State<NumberPickerWheel> {
  late List<int> _digits;
  late List<FixedExtentScrollController> _controllers;
  late List<List<int>> _digitOptions;

  @override
  void initState() {
    super.initState();
    _initializeDigits();
  }

  @override
  void didUpdateWidget(NumberPickerWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _initializeDigits();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeDigits() {
    // Преобразуем значение в целое число
    int intValue = widget.value.toInt();
    
    print('NumberPickerWheel: инициализация с значением ${widget.value}, intValue: $intValue');

    // Разбиваем на цифры
    List<int> wholeDigits = intValue
        .toString()
        .split('')
        .map((e) => int.parse(e))
        .toList();

    // Дополняем ведущими нулями, если нужно
    while (wholeDigits.length < 3) {
      wholeDigits.insert(0, 0);
    }

    // Берем только первые 3 цифры
    _digits = wholeDigits.take(3).toList();
    
    print('NumberPickerWheel: цифры: $_digits');

    // Создаем контроллеры для каждого колеса
    _controllers = List.generate(
      3,
      (index) => FixedExtentScrollController(initialItem: _digits[index]),
    );

    // Создаем варианты для каждого колеса
    _digitOptions = _createDigitOptions();

    // Устанавливаем правильные начальные позиции для контроллеров
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < _controllers.length; i++) {
        if (_controllers[i].hasClients) {
          int initialIndex = _digitOptions[i].indexOf(_digits[i]);
          if (initialIndex >= 0) {
            _controllers[i].jumpToItem(initialIndex);
          }
        }
      }
    });
  }

  List<List<int>> _createDigitOptions() {
    List<List<int>> options = [];

    // Для целой части (первые 3 цифры)
    for (int i = 0; i < 3; i++) {
      if (i == 0) {
        // Первая цифра: ограничиваем до 0, 1, 2
        options.add([0, 1, 2]);
      } else if (i == 1) {
        // Вторая цифра: 0-9
        options.add(List.generate(10, (index) => index));
      } else {
        // Третья цифра: 0-9
        options.add(List.generate(10, (index) => index));
      }
    }

    return options;
  }

  void _onDigitChanged(int digitIndex, int newValue) {
    print('NumberPickerWheel: изменение цифры $digitIndex на $newValue');
    setState(() {
      _digits[digitIndex] = newValue;
    });

    // Обновляем значение
    double calculatedValue = _calculateValue();
    print('NumberPickerWheel: проверка диапазона: $calculatedValue >= ${widget.min} && $calculatedValue <= ${widget.max}');
    if (calculatedValue >= widget.min && calculatedValue <= widget.max) {
      print('NumberPickerWheel: вызываем onChanged с $calculatedValue');
      widget.onChanged(calculatedValue);
    } else {
      print('NumberPickerWheel: значение $calculatedValue вне диапазона [${widget.min}, ${widget.max}]');
    }
  }

  double _calculateValue() {
    // Собираем целую часть (только 3 цифры)
    int wholePart = 0;
    for (int i = 0; i < 3; i++) {
      wholePart = wholePart * 10 + _digits[i];
    }
    print('NumberPickerWheel: рассчитанное значение: $wholePart');
    return wholePart.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    widget.label,
                    style: AppText.text18bb.copyWith(color: AppColor.black),
                  ),
                  Text(
                    ' (${widget.min.toInt()} - ${widget.max.toInt()} ${widget.unit})',
                    style: AppText.text12rb.copyWith(color: AppColor.grey),
                  ),
                ],
              ),
              Text(
                '${_calculateValue().toInt()} ${widget.unit}',
                style: AppText.text18bb.copyWith(color: AppColor.black),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Основной контейнер с колесами
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Колеса для цифр
                ...List.generate(_digits.length, (index) {
                  return Container(
                    width: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: CupertinoPicker(
                      scrollController: _controllers[index],
                      itemExtent: 40,
                      diameterRatio: 2.0,
                      onSelectedItemChanged: (value) {
                        _onDigitChanged(index, _digitOptions[index][value]);
                      },
                      children: _digitOptions[index].map((digit) {
                        return Center(
                          child: Text(
                            digit.toString(),
                            style: AppText.text18bb.copyWith(
                              color: AppColor.darkBlue,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }),

                // Единица измерения
                const SizedBox(width: 8),
                Text(
                  widget.unit,
                  style: AppText.text18mb.copyWith(color: AppColor.darkBlue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
