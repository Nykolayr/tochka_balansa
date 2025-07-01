import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/theme/colors.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isBack;
  final List<Widget>? actions;

  const AppBarWidget({
    super.key,
    required this.title,
    this.isBack = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: AppColor.darkBlue,
      title: Text(
        title,
        style: const TextStyle(
          color: AppColor.white,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColor.white),
      leading: isBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.of(context).maybePop(),
            )
          : null,
      actions: actions,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
