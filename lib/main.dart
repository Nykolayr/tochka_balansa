import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tochka_balansa/presentation/router/routers.dart';
import 'package:tochka_balansa/core/theme/colors.dart';
import 'package:tochka_balansa/providers/language_bloc.dart';
import 'package:tochka_balansa/data/datasources/hive_data.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/di/locator.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
bool isMock = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveData.init();
  WidgetsBinding.instance.addObserver(AppLifecycleObserver());
  HttpOverrides.global = MyHttpOverrides();

  // Инициализируем все зависимости
  await initMain();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      bloc: Get.find<LanguageBloc>(),
      builder: (context, languageState) {
        // Определяем локаль на основе состояния LanguageBloc
        Locale currentLocale;
        if (languageState is LanguageLoaded) {
          currentLocale = languageState.language == LanguageEnum.english
              ? const Locale('en', 'US')
              : const Locale('ru', 'RU');
        } else {
          // Если состояние не загружено, используем системную локаль
          final systemLocale =
              WidgetsBinding.instance.platformDispatcher.locale;
          currentLocale = systemLocale.languageCode == 'en'
              ? const Locale('en', 'US')
              : const Locale('ru', 'RU');
        }

        return KeyboardSizeProvider(
          child: MaterialApp.router(
            key: ValueKey(languageState),
            title: 'Tochka Balansa',
            locale: currentLocale,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('ru', 'RU'), Locale('en', 'US')],
            theme: ThemeData(
              useMaterial3: true,
              scaffoldBackgroundColor: AppColor.white,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColor.primary,
                surface: AppColor.white,
              ),
              textTheme: GoogleFonts.robotoTextTheme(
                Theme.of(context).textTheme,
              ),
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
                    top: false,
                    bottom: true,
                    left: false,
                    right: false,
                    child: child!,
                  ),
                ),
              );
            },
          ),
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
    Logger.i('AppLifecycleState: $state');
  }
}
