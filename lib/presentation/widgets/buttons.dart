import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/core/theme/text.dart';

/// Красивая широкая кнопка с закруглениями и кастомным цветом
class RoundedWideButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool enabled;
  final double height;

  const RoundedWideButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.enabled = true,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          height: height,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColor.darkBlue,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            text,
            style: AppText.text18mb.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Блок из двух кнопок на всю ширину с отступом между ними
class DoubleWideButtons extends StatelessWidget {
  final String leftText;
  final VoidCallback leftOnPressed;
  final String rightText;
  final VoidCallback rightOnPressed;
  final bool leftEnabled;
  final bool rightEnabled;
  final double height;

  const DoubleWideButtons({
    super.key,
    required this.leftText,
    required this.leftOnPressed,
    required this.rightText,
    required this.rightOnPressed,
    this.leftEnabled = true,
    this.rightEnabled = true,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: RoundedWideButton(
            text: leftText,
            onPressed: leftOnPressed,
            enabled: leftEnabled,
            height: height,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RoundedWideButton(
            text: rightText,
            onPressed: rightOnPressed,
            enabled: rightEnabled,
            height: height,
          ),
        ),
      ],
    );
  }
}
