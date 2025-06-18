import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/theme/theme.dart';

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
