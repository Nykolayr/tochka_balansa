import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/colors.dart';

class GoalCompletedDialog extends StatelessWidget {
  final VoidCallback? onOkPressed;

  const GoalCompletedDialog({super.key, this.onOkPressed});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: AppColor.green, size: 64),
          const SizedBox(height: 16),
          Text(
            textLang('Поздравляем!'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColor.darkBlue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            textLang('Все задачи выполнены!'),
            style: const TextStyle(fontSize: 16, color: AppColor.greyText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            textLang('Цель перемещена в архив, где вы сможете ее просмотреть.'),
            style: const TextStyle(fontSize: 14, color: AppColor.greyText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: onOkPressed ?? () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.darkBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                textLang('ОК'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Статический метод для показа диалога
  static void show(BuildContext context, {VoidCallback? onOkPressed}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return GoalCompletedDialog(onOkPressed: onOkPressed);
      },
    );
  }
}
