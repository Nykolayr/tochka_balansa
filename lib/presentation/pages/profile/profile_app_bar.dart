import 'package:flutter/material.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ProfileAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBarWidget(title: textLang('Профиль'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
