import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';

class AddWeightDialog {
  static void show(BuildContext context) {
    // Получаем текущий вес пользователя
    final userRepository = Get.find<UserRepository>();
    final initialWeight = userRepository.user.initialWeight;

    // Получаем последнее измерение веса из блока
    final healthBloc = Get.find<HealthBloc>();
    final weightMetrics = healthBloc.state.healthData.metrics
        .where((m) => m.type == HealthMetricType.weight)
        .toList();

    double currentWeight = initialWeight;
    if (weightMetrics.isNotEmpty) {
      weightMetrics.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      currentWeight =
          double.tryParse(weightMetrics.first.value) ?? initialWeight;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              textLang('Добавить текущий вес'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColor.darkBlue,
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Специальный виджет для выбора веса с десятичными долями
                  WeightPickerWheel(
                    value: currentWeight,
                    onChanged: (weight) =>
                        setState(() => currentWeight = weight),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    textLang(
                      'Текущий вес: ${currentWeight.toStringAsFixed(1)} кг',
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColor.darkBlue,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  textLang('Отмена'),
                  style: TextStyle(color: AppColor.greyText),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Создаем метрику веса
                  final metric = HealthMetric(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    type: HealthMetricType.weight,
                    value: currentWeight.toStringAsFixed(1),
                    timestamp: DateTime.now(),
                  );

                  // Добавляем в блок
                  Get.find<HealthBloc>().add(AddHealthMetricEvent(metric));
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.darkBlue,
                  foregroundColor: Colors.white,
                ),
                child: Text(textLang('Сохранить')),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Специальный виджет для выбора веса с поддержкой десятичных долей
class WeightPickerWheel extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const WeightPickerWheel({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<WeightPickerWheel> createState() => _WeightPickerWheelState();
}

class _WeightPickerWheelState extends State<WeightPickerWheel> {
  late FixedExtentScrollController _wholeController;
  late FixedExtentScrollController _decimalController;
  late int _wholePart;
  late int _decimalPart;

  @override
  void initState() {
    super.initState();
    _initializeValues();
  }

  @override
  void didUpdateWidget(WeightPickerWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _initializeValues();
    }
  }

  @override
  void dispose() {
    _wholeController.dispose();
    _decimalController.dispose();
    super.dispose();
  }

  void _initializeValues() {
    _wholePart = widget.value.toInt();
    _decimalPart = ((widget.value - _wholePart) * 10).round();

    _wholeController = FixedExtentScrollController(
      initialItem: _wholePart - 30,
    );
    _decimalController = FixedExtentScrollController(initialItem: _decimalPart);
  }

  void _onWholeChanged(int value) {
    setState(() {
      _wholePart = value + 30; // Смещение от 30
    });
    _updateValue();
  }

  void _onDecimalChanged(int value) {
    setState(() {
      _decimalPart = value;
    });
    _updateValue();
  }

  void _updateValue() {
    final newValue = _wholePart + (_decimalPart / 10);
    if (newValue >= 30.0 && newValue <= 290.0) {
      widget.onChanged(newValue);
    }
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
              Text(
                textLang('Вес'),
                style: AppText.text18bb.copyWith(color: AppColor.black),
              ),
              Text(
                '$_wholePart.${_decimalPart.toString().padLeft(1, '0')} кг',
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
                // Колесо для целой части
                Container(
                  width: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: CupertinoPicker(
                    scrollController: _wholeController,
                    itemExtent: 40,
                    diameterRatio: 2.0,
                    onSelectedItemChanged: _onWholeChanged,
                    children: List.generate(261, (index) {
                      return Center(
                        child: Text(
                          (index + 30).toString(),
                          style: AppText.text18bb.copyWith(
                            color: AppColor.darkBlue,
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // Точка
                Text(
                  '.',
                  style: AppText.text24bb.copyWith(color: AppColor.darkBlue),
                ),

                // Колесо для десятичной части
                Container(
                  width: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: CupertinoPicker(
                    scrollController: _decimalController,
                    itemExtent: 40,
                    diameterRatio: 2.0,
                    onSelectedItemChanged: _onDecimalChanged,
                    children: List.generate(10, (index) {
                      return Center(
                        child: Text(
                          index.toString(),
                          style: AppText.text18bb.copyWith(
                            color: AppColor.darkBlue,
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // Единица измерения
                const SizedBox(width: 8),
                Text(
                  'кг',
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
