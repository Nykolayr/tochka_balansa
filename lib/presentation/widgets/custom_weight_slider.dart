import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/theme/theme.dart';

class CustomWeightSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final String label;

  const CustomWeightSlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  @override
  State<CustomWeightSlider> createState() => _CustomWeightSliderState();
}

class _CustomWeightSliderState extends State<CustomWeightSlider> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: AppText.text16rb.copyWith(color: AppColor.grey),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (_currentValue > 30.0) {
                    setState(() {
                      _currentValue = (_currentValue - 0.1).roundToDouble();
                      widget.onChanged(_currentValue);
                    });
                  }
                },
                icon: const Icon(Icons.remove_circle_outline),
                color: AppColor.darkBlue,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${_currentValue.toStringAsFixed(1)} кг',
                    style: AppText.text24mb.copyWith(color: AppColor.darkBlue),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (_currentValue < 200.0) {
                    setState(() {
                      _currentValue = (_currentValue + 0.1).roundToDouble();
                      widget.onChanged(_currentValue);
                    });
                  }
                },
                icon: const Icon(Icons.add_circle_outline),
                color: AppColor.darkBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
