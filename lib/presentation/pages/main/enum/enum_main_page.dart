import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/presentation/pages/home/home_page.dart';
import 'package:tochka_balansa/presentation/pages/food/food_page.dart';
import 'package:tochka_balansa/presentation/pages/goal/goal_page.dart';
import 'package:tochka_balansa/presentation/pages/profile/profile_page.dart';
import 'package:tochka_balansa/presentation/pages/home/home_app_bar.dart';
import 'package:tochka_balansa/presentation/pages/food/food_app_bar.dart';
import 'package:tochka_balansa/presentation/pages/profile/profile_app_bar.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';
import 'package:tochka_balansa/providers/language_bloc.dart';
import 'package:tochka_balansa/presentation/pages/goal/archive_page.dart';

enum MainPages {
  home,
  food,
  training,
  profile;

  String get title => switch (this) {
    home => textLang('Главная'),
    food => textLang('Еда'),
    training => textLang('Цели'),
    profile => textLang('Профиль'),
  };

  Widget get page => switch (this) {
    home => const HomePage(),
    food => const FoodPage(),
    training => const GoalPage(),
    profile => const ProfilePage(),
  };

  IconData get icon => switch (this) {
    home => Icons.home,
    food => Icons.restaurant,
    training => Icons.flag,
    profile => Icons.person,
  };

  Widget get appBar {
    return BlocBuilder<LanguageBloc, LanguageState>(
      bloc: Get.find<LanguageBloc>(),
      builder: (context, languageState) {
        return switch (this) {
          home => HomeAppBar(),
          food => FoodAppBar(),
          training => AppBarWidget(
            title: textLang('Цели'),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ArchivePage(),
                    ),
                  );
                },
                icon: const Icon(Icons.history, color: Colors.white),
              ),
            ],
          ),
          profile => ProfileAppBar(),
        };
      },
    );
  }
}
