import 'package:flutter/material.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';

class FoodAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FoodAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppBarWidget(
      title: 'Еда',
      // actions: [...],
      // isBack: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
