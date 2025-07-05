import 'package:flutter/material.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';

class TrainingAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TrainingAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBarWidget(title: textLang('Тренировки'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
