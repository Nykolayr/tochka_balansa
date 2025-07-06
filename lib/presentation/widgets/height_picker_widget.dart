import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/presentation/widgets/custom_animated_weight_picker.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';

class HeightPickerWidget extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final String label;

  const HeightPickerWidget({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  @override
  State<HeightPickerWidget> createState() => _HeightPickerWidgetState();
}

class _HeightPickerWidgetState extends State<HeightPickerWidget> {
  late String selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.value.toInt().toString();
  }

  @override
  void didUpdateWidget(HeightPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      selectedValue = widget.value.toInt().toString();
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
              Text(
                '${widget.value.toInt()} ${textLang('см')}',
                style: AppText.text18mb.copyWith(color: AppColor.darkBlue),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 70,
            child: CustomAnimatedWeightPicker(
              min: 100.0,
              max: 250.0,
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
