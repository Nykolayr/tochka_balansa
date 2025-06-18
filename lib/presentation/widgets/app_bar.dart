import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/theme/theme.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isBack;

  const AppBarWidget({super.key, required this.title, this.isBack = true});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: AppColor.darkBlue,
      title: Text(
        title,
        style: AppText.text18mb.copyWith(color: AppColor.white),
      ),
      iconTheme: const IconThemeData(color: AppColor.white),
      leading: isBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
