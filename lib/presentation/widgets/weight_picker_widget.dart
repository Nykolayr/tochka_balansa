import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/presentation/widgets/custom_animated_weight_picker.dart';

class WeightPickerWidget extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final String label;

  const WeightPickerWidget({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  @override
  State<WeightPickerWidget> createState() => _WeightPickerWidgetState();
}

class _WeightPickerWidgetState extends State<WeightPickerWidget> {
  late String selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.value.toStringAsFixed(1);
  }

  @override
  void didUpdateWidget(WeightPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      selectedValue = widget.value.toStringAsFixed(1);
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
                '${widget.value.toStringAsFixed(1)} кг',
                style: AppText.text18mb.copyWith(color: AppColor.darkBlue),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 70,
            child: CustomAnimatedWeightPicker(
              min: 30.0,
              max: 200.0,
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
