import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});
  @override
  Widget build(BuildContext context) => AppBar(title: const Text('Главная'));
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
