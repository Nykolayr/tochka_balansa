import 'package:flutter/material.dart';

class FoodAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FoodAppBar({super.key});
  @override
  Widget build(BuildContext context) => AppBar(title: const Text('Еда'));
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
