import 'package:flutter/material.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';

class TrainingAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TrainingAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppBarWidget(
      title: 'Тренировки',
      // actions: [...],
      // isBack: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
