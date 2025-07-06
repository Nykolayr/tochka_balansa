import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/colors.dart';
import 'package:tochka_balansa/presentation/pages/goal/goal_setup_page.dart';

class SetFirstGoalWidget extends StatelessWidget {
  const SetFirstGoalWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Иконка цели
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColor.darkBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(Icons.flag, size: 40, color: AppColor.darkBlue),
          ),

          const SizedBox(height: 24),

          // Заголовок
          Text(
            textLang('Давайте поставим первую цель!'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColor.darkBlue,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Описание
          Text(
            textLang('Это поможет вам отслеживать прогресс'),
            style: const TextStyle(fontSize: 16, color: AppColor.grey),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Кнопка "Начать"
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                // Переходим на страницу настройки цели
                Get.to(() => const GoalSetupPage());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.darkBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                textLang('Начать'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
