import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tochka_balansa/core/utils/functions.dart';
import 'package:tochka_balansa/presentation/pages/auth/auth_page.dart';
import 'package:tochka_balansa/presentation/pages/auth/code_page.dart';
import 'package:tochka_balansa/presentation/pages/auth/reg_page.dart';
import 'package:tochka_balansa/presentation/pages/food/enum_eat.dart';
import 'package:tochka_balansa/presentation/pages/health/health_page.dart';
import 'package:tochka_balansa/presentation/pages/health/weight_page.dart';
import 'package:tochka_balansa/presentation/pages/health/weight_history_page.dart';
import 'package:tochka_balansa/presentation/pages/health/blood_pressure_page.dart';
import 'package:tochka_balansa/presentation/pages/health/blood_pressure_history_page.dart';
import 'package:tochka_balansa/presentation/pages/main/main_page.dart';
import 'package:tochka_balansa/presentation/pages/splash/splash_page.dart';
import 'package:tochka_balansa/presentation/pages/user_data/user_data_page.dart';
import 'package:tochka_balansa/presentation/pages/home/home_page.dart';
import 'package:tochka_balansa/presentation/pages/goal/goal_page.dart';
import 'package:tochka_balansa/presentation/pages/goal/add_additional_goal_page.dart';
import 'package:tochka_balansa/presentation/pages/goal/additional_goal_detail_page.dart';
import 'package:tochka_balansa/presentation/pages/goal/archive_page.dart';
import 'package:tochka_balansa/presentation/pages/profile/profile_page.dart';
import 'package:tochka_balansa/presentation/pages/health/blood_sugar_page.dart';
import 'package:tochka_balansa/presentation/pages/health/blood_sugar_history_page.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/providers/language_bloc.dart';
import 'package:tochka_balansa/data/models/goal/additional_goal.dart';
import 'package:tochka_balansa/presentation/pages/health/steps_page.dart';
import 'package:tochka_balansa/presentation/pages/health/steps_history_page.dart';
import 'package:tochka_balansa/presentation/pages/goal/goal_setup_page.dart';
import 'package:tochka_balansa/presentation/pages/food/eat_page.dart';
import 'package:tochka_balansa/presentation/pages/exercise/exercise_page.dart';
import 'package:tochka_balansa/presentation/pages/food/add_product_page.dart';

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
      name: 'основная',
      path: '/main',
      pageBuilder: (context, state) {
        final languageState = Get.find<LanguageBloc>().state;
        return buildPageWithDefaultTransition(
          type: PageTransitionType.fade,
          context: context,
          state: state,
          child: MainPage(key: ValueKey(languageState)),
        );
      },
      routes: [
        GoRoute(
          name: 'домашняя',
          path: 'home',
          pageBuilder: (context, state) {
            final languageState = Get.find<LanguageBloc>().state;
            return buildPageWithDefaultTransition(
              type: PageTransitionType.fade,
              context: context,
              state: state,
              child: HomePage(key: ValueKey(languageState)),
            );
          },
          routes: [
            GoRoute(
              name: 'eat',
              path: 'eat',
              pageBuilder: (context, state) {
                final eatType = state.extra as EatType?;
                return buildPageWithDefaultTransition(
                  type: PageTransitionType.rightToLeft,
                  context: context,
                  state: state,
                  child: EatPage(initialEatType: eatType),
                );
              },
            ),

            GoRoute(
              name: 'exercise',
              path: 'exercise',
              pageBuilder: (context, state) {
                final languageState = Get.find<LanguageBloc>().state;
                return buildPageWithDefaultTransition(
                  type: PageTransitionType.rightToLeft,
                  context: context,
                  state: state,
                  child: ExercisePage(key: ValueKey(languageState)),
                );
              },
            ),
            GoRoute(
              name: 'add-product',
              path: 'add-product',
              pageBuilder: (context, state) {
                final eatType = state.extra as EatType;
                return buildPageWithDefaultTransition(
                  type: PageTransitionType.rightToLeft,
                  context: context,
                  state: state,
                  child: AddProductPage(eatType: eatType),
                );
              },
            ),
          ],
        ),
        GoRoute(
          name: 'здоровье',
          path: 'health',
          pageBuilder: (context, state) {
            final languageState = Get.find<LanguageBloc>().state;
            return buildPageWithDefaultTransition(
              type: PageTransitionType.leftToRight,
              context: context,
              state: state,
              child: HealthPage(key: ValueKey(languageState)),
            );
          },
          routes: [
            GoRoute(
              name: 'вес',
              path: 'weight',
              pageBuilder: (context, state) {
                final languageState = Get.find<LanguageBloc>().state;
                return buildPageWithDefaultTransition(
                  type: PageTransitionType.rightToLeft,
                  context: context,
                  state: state,
                  child: WeightPage(key: ValueKey(languageState)),
                );
              },
              routes: [
                GoRoute(
                  name: 'история веса',
                  path: 'history',
                  pageBuilder: (context, state) {
                    final languageState = Get.find<LanguageBloc>().state;
                    return buildPageWithDefaultTransition(
                      type: PageTransitionType.rightToLeft,
                      context: context,
                      state: state,
                      child: WeightHistoryPage(key: ValueKey(languageState)),
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              name: 'давление',
              path: 'pressure',
              pageBuilder: (context, state) {
                final languageState = Get.find<LanguageBloc>().state;
                return buildPageWithDefaultTransition(
                  type: PageTransitionType.rightToLeft,
                  context: context,
                  state: state,
                  child: BloodPressurePage(key: ValueKey(languageState)),
                );
              },
              routes: [
                GoRoute(
                  name: 'история давления',
                  path: 'history',
                  pageBuilder: (context, state) {
                    final languageState = Get.find<LanguageBloc>().state;
                    return buildPageWithDefaultTransition(
                      type: PageTransitionType.rightToLeft,
                      context: context,
                      state: state,
                      child: BloodPressureHistoryPage(
                        key: ValueKey(languageState),
                      ),
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              name: 'шаги',
              path: 'steps',
              pageBuilder: (context, state) {
                final languageState = Get.find<LanguageBloc>().state;
                return buildPageWithDefaultTransition(
                  type: PageTransitionType.rightToLeft,
                  context: context,
                  state: state,
                  child: StepsPage(key: ValueKey(languageState)),
                );
              },
              routes: [
                GoRoute(
                  name: 'история шагов',
                  path: 'history',
                  pageBuilder: (context, state) {
                    final languageState = Get.find<LanguageBloc>().state;
                    return buildPageWithDefaultTransition(
                      type: PageTransitionType.rightToLeft,
                      context: context,
                      state: state,
                      child: StepsHistoryPage(key: ValueKey(languageState)),
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              name: 'сахар',
              path: 'blood-sugar',
              pageBuilder: (context, state) {
                final languageState = Get.find<LanguageBloc>().state;
                return buildPageWithDefaultTransition(
                  type: PageTransitionType.rightToLeft,
                  context: context,
                  state: state,
                  child: BloodSugarPage(key: ValueKey(languageState)),
                );
              },
              routes: [
                GoRoute(
                  name: 'история сахара',
                  path: 'history',
                  pageBuilder: (context, state) {
                    final languageState = Get.find<LanguageBloc>().state;
                    return buildPageWithDefaultTransition(
                      type: PageTransitionType.rightToLeft,
                      context: context,
                      state: state,
                      child: BloodSugarHistoryPage(
                        key: ValueKey(languageState),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          name: 'тренировки',
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
          routes: [
            GoRoute(
              name: 'настройка цели',
              path: 'setup',
              pageBuilder: (context, state) {
                final languageState = Get.find<LanguageBloc>().state;
                return buildPageWithDefaultTransition(
                  type: PageTransitionType.rightToLeft,
                  context: context,
                  state: state,
                  child: GoalSetupPage(key: ValueKey(languageState)),
                );
              },
            ),
            GoRoute(
              name: 'добавить дополнительную цель',
              path: 'add-additional',
              pageBuilder: (context, state) {
                final languageState = Get.find<LanguageBloc>().state;
                return buildPageWithDefaultTransition(
                  type: PageTransitionType.rightToLeft,
                  context: context,
                  state: state,
                  child: AddAdditionalGoalPage(key: ValueKey(languageState)),
                );
              },
            ),
            GoRoute(
              name: 'архив целей',
              path: 'archive',
              pageBuilder: (context, state) {
                final languageState = Get.find<LanguageBloc>().state;
                return buildPageWithDefaultTransition(
                  type: PageTransitionType.rightToLeft,
                  context: context,
                  state: state,
                  child: ArchivePage(key: ValueKey(languageState)),
                );
              },
            ),
            GoRoute(
              name: 'детали дополнительной цели',
              path: 'goal-detail',
              pageBuilder: (context, state) {
                final languageState = Get.find<LanguageBloc>().state;
                final goal = state.extra as AdditionalGoal;
                return buildPageWithDefaultTransition(
                  type: PageTransitionType.rightToLeft,
                  context: context,
                  state: state,
                  child: AdditionalGoalDetailPage(
                    key: ValueKey(languageState),
                    goal: goal,
                  ),
                );
              },
            ),
          ],
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
