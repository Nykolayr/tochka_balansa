import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/presentation/widgets/custom_animated_weight_picker.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';

class HeightPickerWidget extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final String label;
  final VoidCallback? onFocus;

  const HeightPickerWidget({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.onFocus,
  });

  @override
  State<HeightPickerWidget> createState() => _HeightPickerWidgetState();
}

class _HeightPickerWidgetState extends State<HeightPickerWidget> {
  late String selectedValue;
  late TextEditingController _controller;
  late FocusNode _focusNode;
  final double _minHeight = 100.0;
  final double _maxHeight = 250.0;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.value.toInt().toString();
    _controller = TextEditingController(text: selectedValue);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(HeightPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      selectedValue = widget.value.toInt().toString();
      _controller.text = selectedValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleManualInput(String value) {
    if (value.isEmpty) return;

    // Проверяем, что введено только число
    if (!RegExp(r'^\d*$').hasMatch(value)) return;

    int? height = int.tryParse(value);
    if (height != null) {
      // Проверяем границы
      if (height < _minHeight.toInt()) {
        height = _minHeight.toInt();
        _controller.text = height.toString();
      } else if (height > _maxHeight.toInt()) {
        height = _maxHeight.toInt();
        _controller.text = height.toString();
      }

      setState(() {
        selectedValue = height.toString();
      });
      widget.onChanged(height.toDouble());
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
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    suffixText: textLang('см'),
                    suffixStyle: AppText.text16rb.copyWith(
                      color: AppColor.darkBlue,
                    ),
                    hintText: '${_minHeight.toInt()}-${_maxHeight.toInt()}',
                    hintStyle: AppText.text12rb.copyWith(color: AppColor.grey),
                  ),
                  style: AppText.text16rb.copyWith(color: AppColor.darkBlue),
                  onChanged: (value) {
                    // Разрешаем ввод любого значения, не валидируем на лету
                  },
                  onEditingComplete: () {
                    final text = _controller.text;
                    final int? height = int.tryParse(text);
                    if (height == null ||
                        height < _minHeight.toInt() ||
                        height > _maxHeight.toInt()) {
                      // Если невалидно — возвращаем старое значение
                      _controller.text = selectedValue;
                    } else {
                      setState(() {
                        selectedValue = height.toString();
                      });
                      widget.onChanged(height.toDouble());
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
          SizedBox(
            height: 70,
            child: CustomAnimatedWeightPicker(
              key: ValueKey(widget.value),
              min: _minHeight,
              max: _maxHeight,
              division: 1.0, // шаг 1 см (только целые числа)
              squeeze: 1.0,
              dialHeight: 60.0,
              dialThickness: 3.0,
              dialColor: AppColor.darkBlue,
              majorIntervalAt: 10, // каждые 10 см
              majorIntervalHeight: 20.0,
              majorIntervalThickness: 2.0,
              majorIntervalColor: AppColor.darkBlue,
              showMajorIntervalText: true,
              majorIntervalTextSize: 14.0,
              majorIntervalTextColor: AppColor.darkBlue,
              subIntervalAt: 5, // каждые 5 см
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
