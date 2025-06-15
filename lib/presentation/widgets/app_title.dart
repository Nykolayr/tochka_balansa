import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';

class AppTitle extends StatelessWidget {
  const AppTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          textLang('Точка Баланса'),
          style: AppText.text18bb,
          textAlign: TextAlign.center,
        ),
        Text(
          textLang(
            'умный помощник для поддержания физического равновесия и веса',
          ),
          style: AppText.text16rb.copyWith(color: AppColor.greyText),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
