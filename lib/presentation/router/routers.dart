import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tochka_balansa/core/utils/functions.dart';
import 'package:tochka_balansa/presentation/pages/auth/auth_page.dart';
import 'package:tochka_balansa/presentation/pages/auth/code_page.dart';
import 'package:tochka_balansa/presentation/pages/auth/reg_page.dart';
import 'package:tochka_balansa/presentation/pages/main/main_page.dart';
import 'package:tochka_balansa/presentation/pages/splash/splash_page.dart';
import 'package:tochka_balansa/presentation/pages/user_data/user_data_page.dart';
import 'package:tochka_balansa/presentation/pages/home/home_page.dart';
import 'package:tochka_balansa/presentation/pages/food/food_page.dart';
import 'package:tochka_balansa/presentation/pages/goal/goal_page.dart';
import 'package:tochka_balansa/presentation/pages/profile/profile_page.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/providers/language_bloc.dart';

final GoRouter router = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/splash',
  routes: <GoRoute>[
    GoRoute(
      name: 'сплэш',
      path: '/splash',
      pageBuilder: (context, state) {
        final languageState = Get.find<LanguageBloc>().state;
        return buildPageWithDefaultTransition(
          type: PageTransitionType.fade,
          context: context,
          state: state,
          child: SplashPage(key: ValueKey(languageState)),
        );
      },
    ),
    GoRoute(
      name: 'данные пользователя',
      path: '/user-data',
      pageBuilder: (context, state) {
        final languageState = Get.find<LanguageBloc>().state;
        return buildPageWithDefaultTransition(
          type: PageTransitionType.leftToRight,
          context: context,
          state: state,
          child: UserDataPage(key: ValueKey(languageState)),
        );
      },
    ),
    GoRoute(
      name: 'авторизация',
      path: '/auth',
      pageBuilder: (context, state) {
        final languageState = Get.find<LanguageBloc>().state;
        return buildPageWithDefaultTransition(
          type: PageTransitionType.leftToRight,
          context: context,
          state: state,
          child: AuthPage(key: ValueKey(languageState)),
        );
      },
      routes: <GoRoute>[
        GoRoute(
          name: 'регистрация пользователя',
          path: '/reg',
          pageBuilder: (context, state) {
            final languageState = Get.find<LanguageBloc>().state;
            return buildPageWithDefaultTransition(
              type: PageTransitionType.rightToLeft,
              context: context,
              state: state,
              child: RegPage(key: ValueKey(languageState)),
            );
          },
          routes: <GoRoute>[
            GoRoute(
              name: 'ввод кода',
              path: '/code',
              pageBuilder: (context, state) {
                final languageState = Get.find<LanguageBloc>().state;
                return buildPageWithDefaultTransition(
                  type: PageTransitionType.rightToLeft,
                  context: context,
                  state: state,
                  child: CodePage(key: ValueKey(languageState)),
                );
              },
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      name: 'Общая',
      path: '/main',
      pageBuilder: (context, state) {
        final languageState = Get.find<LanguageBloc>().state;
        return buildPageWithDefaultTransition(
          type: PageTransitionType.leftToRight,
          context: context,
          state: state,
          child: MainPage(key: ValueKey(languageState)),
        );
      },
      routes: <GoRoute>[
        GoRoute(
          name: 'Главная',
          path: 'home',
          pageBuilder: (context, state) {
            final languageState = Get.find<LanguageBloc>().state;
            return buildPageWithDefaultTransition(
              type: PageTransitionType.leftToRight,
              context: context,
              state: state,
              child: HomePage(key: ValueKey(languageState)),
            );
          },
        ),
        GoRoute(
          name: 'Еда',
          path: 'food',
          pageBuilder: (context, state) {
            final languageState = Get.find<LanguageBloc>().state;
            return buildPageWithDefaultTransition(
              type: PageTransitionType.leftToRight,
              context: context,
              state: state,
              child: FoodPage(key: ValueKey(languageState)),
            );
          },
        ),
        GoRoute(
          name: 'Тренировки',
          path: 'training',
          pageBuilder: (context, state) {
            final languageState = Get.find<LanguageBloc>().state;
            return buildPageWithDefaultTransition(
              type: PageTransitionType.leftToRight,
              context: context,
              state: state,
              child: GoalPage(key: ValueKey(languageState)),
            );
          },
        ),
        GoRoute(
          name: 'Профиль',
          path: 'profile',
          pageBuilder: (context, state) {
            final languageState = Get.find<LanguageBloc>().state;
            return buildPageWithDefaultTransition(
              type: PageTransitionType.leftToRight,
              context: context,
              state: state,
              child: ProfilePage(key: ValueKey(languageState)),
            );
          },
        ),
      ],
    ),
  ],
);
