import 'package:flutter/material.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ProfileAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppBarWidget(
      title: 'Профиль',
      // actions: [...],
      // isBack: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
