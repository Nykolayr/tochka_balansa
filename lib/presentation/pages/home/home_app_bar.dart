import 'package:flutter/material.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppBarWidget(
      title: 'Главная',
      // actions: [...], // можно добавить позже
      // isBack: false, // по умолчанию
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
