import 'package:flutter/material.dart';
import 'package:tochka_balansa/presentation/pages/home/home_page.dart';
import 'package:tochka_balansa/presentation/pages/food/food_page.dart';
import 'package:tochka_balansa/presentation/pages/training/training_page.dart';
import 'package:tochka_balansa/presentation/pages/profile/profile_page.dart';
import 'package:tochka_balansa/presentation/pages/home/home_app_bar.dart';
import 'package:tochka_balansa/presentation/pages/food/food_app_bar.dart';
import 'package:tochka_balansa/presentation/pages/training/training_app_bar.dart';
import 'package:tochka_balansa/presentation/pages/profile/profile_app_bar.dart';

enum MainPages {
  home,
  food,
  training,
  profile;

  String get title => switch (this) {
    home => 'Главная',
    food => 'Еда',
    training => 'Тренировки',
    profile => 'Профиль',
  };

  Widget get page => switch (this) {
    home => const HomePage(),
    food => const FoodPage(),
    training => const TrainingPage(),
    profile => const ProfilePage(),
  };

  IconData get icon => switch (this) {
    home => Icons.home,
    food => Icons.restaurant,
    training => Icons.directions_run,
    profile => Icons.person,
  };

  PreferredSizeWidget get appBar => switch (this) {
    home => const HomeAppBar(),
    food => const FoodAppBar(),
    training => const TrainingAppBar(),
    profile => const ProfileAppBar(),
  };
}
