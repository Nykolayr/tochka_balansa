import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/presentation/widgets/custom_tape_slider.dart';

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
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.grey, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Рост',
                style: AppText.text16rb.copyWith(color: AppColor.grey),
              ),
              Expanded(child: Container()),
              Text(
                '${widget.value.toInt()} см',
                style: AppText.text18mb.copyWith(color: AppColor.darkBlue),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: CustomTapeSlider(
              initialValue: widget.value,
              minValue: 100.0,
              maxValue: 250.0,
              itemExtent: 15.0,
              activeColor: AppColor.darkBlue,
              inactiveColor: AppColor.grey.withOpacity(0.3),
              indicatorColor: AppColor.red,
              indicatorThickness: 1.0,
              showLabels: true,
              tickInterval: 1,
              labelInterval: 10,
              majorTickLabelStyle: AppText.text12rb.copyWith(
                color: AppColor.darkBlue,
                fontSize: 10,
              ),
              minorTickLabelStyle: AppText.text10rb.copyWith(
                color: AppColor.grey,
                fontSize: 8,
              ),
              onValueChanged: (value) {
                widget.onChanged(value - 2);
              },
            ),
          ),
        ],
      ),
    );
  }
}
