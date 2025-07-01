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
import 'package:tochka_balansa/presentation/pages/training/training_page.dart';
import 'package:tochka_balansa/presentation/pages/profile/profile_page.dart';

/// роутер приложения
final GoRouter router = GoRouter(
  // observers: [GoNavigatorObserver()],
  debugLogDiagnostics: true,
  initialLocation: '/splash',
  routes: <GoRoute>[
    GoRoute(
      name: 'сплэш',
      path: '/splash',
      pageBuilder: (context, state) => buildPageWithDefaultTransition(
        type: PageTransitionType.fade,
        context: context,
        state: state,
        child: const SplashPage(),
      ),
    ),
    GoRoute(
      name: 'данные пользователя',
      path: '/user-data',
      pageBuilder: (context, state) => buildPageWithDefaultTransition(
        type: PageTransitionType.leftToRight,
        context: context,
        state: state,
        child: const UserDataPage(),
      ),
    ),
    GoRoute(
      name: 'авторизация',
      path: '/auth',
      pageBuilder: (context, state) => buildPageWithDefaultTransition(
        type: PageTransitionType.leftToRight,
        context: context,
        state: state,
        child: const AuthPage(),
      ),
      routes: <GoRoute>[
        GoRoute(
          name: 'регистрация пользователя',
          path: '/reg',
          pageBuilder: (context, state) => buildPageWithDefaultTransition(
            type: PageTransitionType.rightToLeft,
            context: context,
            state: state,
            child: const RegPage(),
          ),
          routes: <GoRoute>[
            GoRoute(
              name: 'ввод кода',
              path: '/code',
              pageBuilder: (context, state) => buildPageWithDefaultTransition(
                type: PageTransitionType.rightToLeft,
                context: context,
                state: state,
                child: const CodePage(),
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      name: 'Общая',
      path: '/main',
      pageBuilder: (context, state) => buildPageWithDefaultTransition(
        type: PageTransitionType.leftToRight,
        context: context,
        state: state,
        child: const MainPage(),
      ),
      routes: <GoRoute>[
        GoRoute(
          name: 'Главная',
          path: 'home',
          pageBuilder: (context, state) => buildPageWithDefaultTransition(
            type: PageTransitionType.leftToRight,
            context: context,
            state: state,
            child: const HomePage(),
          ),
        ),
        GoRoute(
          name: 'Еда',
          path: 'food',
          pageBuilder: (context, state) => buildPageWithDefaultTransition(
            type: PageTransitionType.leftToRight,
            context: context,
            state: state,
            child: const FoodPage(),
          ),
        ),
        GoRoute(
          name: 'Тренировки',
          path: 'training',
          pageBuilder: (context, state) => buildPageWithDefaultTransition(
            type: PageTransitionType.leftToRight,
            context: context,
            state: state,
            child: const TrainingPage(),
          ),
        ),
        GoRoute(
          name: 'Профиль',
          path: 'profile',
          pageBuilder: (context, state) => buildPageWithDefaultTransition(
            type: PageTransitionType.leftToRight,
            context: context,
            state: state,
            child: const ProfilePage(),
          ),
        ),
      ],
    ),
  ],
);
