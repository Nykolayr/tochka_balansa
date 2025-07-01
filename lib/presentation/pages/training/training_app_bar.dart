import 'package:flutter/material.dart';

class TrainingAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TrainingAppBar({super.key});
  @override
  Widget build(BuildContext context) => AppBar(title: const Text('Тренировки'));
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
