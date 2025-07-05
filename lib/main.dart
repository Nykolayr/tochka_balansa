import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tochka_balansa/presentation/router/routers.dart';
import 'package:tochka_balansa/core/theme/colors.dart';
import 'package:tochka_balansa/presentation/pages/main/bloc/main_bloc.dart';

// GlobalKey для доступа к контексту глобально
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Глобальная переменная для мока
bool isMock = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addObserver(AppLifecycleObserver());
  HttpOverrides.global = MyHttpOverrides();

  // Инициализируем MainBloc
  Get.put(MainBloc());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
      buildWhen: (previous, current) =>
          current.shouldRefresh != previous.shouldRefresh,
      builder: (context, state) {
        // Получаем локаль системы
        final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
        // Определяем поддерживаемые языки
        final supportedLocales = const [Locale('ru', 'RU'), Locale('en', 'US')];
        // Выбираем ближайший поддерживаемый язык
        final locale = supportedLocales.firstWhere(
          (locale) => locale.languageCode == systemLocale.languageCode,
          orElse: () => const Locale('en', 'US'), // По умолчанию русский
        );

        return MaterialApp.router(
          title: 'Tochka Balansa',

          locale: locale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: supportedLocales,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: AppColor.white, // Используем AppColor
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColor.primary,
              surface: AppColor.white,
            ),
            textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),
          debugShowCheckedModeBanner: false,
          routeInformationProvider: router.routeInformationProvider,
          routeInformationParser: router.routeInformationParser,
          routerDelegate: router.routerDelegate,
          builder: (context, child) {
            final mq = MediaQuery.of(context);
            final fontScale = mq.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.1,
            );
            return FToastBuilder()(
              context,
              MediaQuery(
                data: mq.copyWith(textScaler: fontScale),
                child: SafeArea(
                  top: false, // Контент может заходить под статус-бар
                  bottom: true, // Защита от навигационной панели снизу
                  left: false, // Контент может заходить к краям экрана
                  right: false, // Контент может заходить к краям экрана
                  child: child!,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }
}
