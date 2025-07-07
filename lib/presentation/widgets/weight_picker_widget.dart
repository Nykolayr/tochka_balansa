import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/presentation/widgets/custom_animated_weight_picker.dart';

class WeightPickerWidget extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final String label;
  final VoidCallback? onFocus;

  const WeightPickerWidget({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.onFocus,
  });

  @override
  State<WeightPickerWidget> createState() => _WeightPickerWidgetState();
}

class _WeightPickerWidgetState extends State<WeightPickerWidget> {
  late String selectedValue;
  late TextEditingController _controller;
  late FocusNode _focusNode;
  final double _minWeight = 30.0;
  final double _maxWeight = 200.0;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.value.toStringAsFixed(1);
    _controller = TextEditingController(text: selectedValue);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(WeightPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      selectedValue = widget.value.toStringAsFixed(1);
      _controller.text = selectedValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void handleManualInput(String value) {
    if (value.isEmpty) return;

    // Заменяем запятую на точку
    value = value.replaceAll(',', '.');

    // Проверяем, что введено только число с точкой
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(value)) return;

    double? weight = double.tryParse(value);
    if (weight != null) {
      // Проверяем границы
      if (weight < _minWeight) {
        weight = _minWeight;
        _controller.text = weight.toStringAsFixed(1);
      } else if (weight > _maxWeight) {
        weight = _maxWeight;
        _controller.text = weight.toStringAsFixed(1);
      }

      setState(() {
        selectedValue = weight!.toStringAsFixed(1);
      });
      widget.onChanged(weight);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.label,
                style: AppText.text16rb.copyWith(color: AppColor.grey),
              ),
              Expanded(child: Container()),
              Container(
                width: 100,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _focusNode.hasFocus
                        ? AppColor.darkBlue
                        : AppColor.grey,
                    width: _focusNode.hasFocus ? 2.0 : 1.0,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  color: _focusNode.hasFocus
                      ? AppColor.darkBlue.withValues(alpha: 0.1)
                      : Colors.transparent,
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
                  ],
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    suffixText: textLang('кг'),
                    suffixStyle: AppText.text16rb.copyWith(
                      color: AppColor.darkBlue,
                    ),
                    hintText:
                        '${_minWeight.toStringAsFixed(1)}-${_maxWeight.toStringAsFixed(1)}',
                    hintStyle: AppText.text12rb.copyWith(color: AppColor.grey),
                  ),
                  style: AppText.text16rb.copyWith(color: AppColor.darkBlue),
                  onChanged: (value) {
                    // Разрешаем ввод любого значения, не валидируем на лету
                  },
                  onEditingComplete: () {
                    final text = _controller.text.replaceAll(',', '.');
                    final double? weight = double.tryParse(text);
                    if (weight == null ||
                        weight < _minWeight ||
                        weight > _maxWeight) {
                      // Если невалидно — возвращаем старое значение
                      _controller.text = selectedValue;
                    } else {
                      setState(() {
                        selectedValue = weight.toStringAsFixed(1);
                      });
                      widget.onChanged(weight);
                    }
                    _focusNode.unfocus();
                  },
                  onTap: () {
                    widget.onFocus?.call();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 70,
            child: CustomAnimatedWeightPicker(
              key: ValueKey(widget.value),
              min: _minWeight,
              max: _maxWeight,
              division: 0.1, // шаг 0.1 кг
              squeeze: 1.0,
              dialHeight: 60.0,
              dialThickness: 3.0,
              dialColor: AppColor.darkBlue,
              majorIntervalAt: 10, // каждые 10 кг
              majorIntervalHeight: 20.0,
              majorIntervalThickness: 2.0,
              majorIntervalColor: AppColor.darkBlue,
              showMajorIntervalText: true,
              majorIntervalTextSize: 14.0,
              majorIntervalTextColor: AppColor.darkBlue,
              subIntervalAt: 5, // каждые 5 кг
              subIntervalHeight: 15.0,
              subIntervalThickness: 1.5,
              subIntervalColor: AppColor.grey,
              showSubIntervalText: false,
              minorIntervalHeight: 10.0,
              minorIntervalThickness: 1.0,
              minorIntervalColor: AppColor.grey.withValues(alpha: 0.5),
              showMinorIntervalText: false,
              showSelectedValue: false,
              selectedValueColor: AppColor.darkBlue,
              selectedValueStyle: AppText.text18mb.copyWith(
                color: AppColor.darkBlue,
              ),
              showSuffix: false,
              onChange: (newValue) {
                setState(() {
                  selectedValue = newValue;
                });
                _controller.text = newValue;
                widget.onChanged(double.parse(newValue));
              },
              initialValue: widget.value, // Передаем начальное значение
            ),
          ),
        ],
      ),
    );
  }
}
