import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/presentation/pages/home/home_page.dart';
import 'package:tochka_balansa/presentation/pages/health/health_page.dart';
import 'package:tochka_balansa/presentation/pages/goal/goal_page.dart';
import 'package:tochka_balansa/presentation/pages/profile/profile_page.dart';
import 'package:tochka_balansa/presentation/pages/home/home_app_bar.dart';
import 'package:tochka_balansa/presentation/pages/health/health_app_bar.dart';
import 'package:tochka_balansa/presentation/pages/profile/profile_app_bar.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';
import 'package:tochka_balansa/providers/language_bloc.dart';
import 'package:tochka_balansa/presentation/pages/goal/archive_page.dart';

enum MainPages {
  home,
  health,
  training,
  profile;

  String get title => switch (this) {
    home => textLang('Главная'),
    health => textLang('Здоровье'),
    training => textLang('Цели'),
    profile => textLang('Профиль'),
  };

  Widget get page => switch (this) {
    home => const HomePage(),
    health => const HealthPage(),
    training => const GoalPage(),
    profile => const ProfilePage(),
  };

  IconData get icon => switch (this) {
    home => Icons.home,
    health => Icons.favorite,
    training => Icons.flag,
    profile => Icons.person,
  };

  Widget get appBar {
    return BlocBuilder<LanguageBloc, LanguageState>(
      bloc: Get.find<LanguageBloc>(),
      builder: (context, languageState) {
        return switch (this) {
          home => HomeAppBar(),
          health => HealthAppBar(),
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
