import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tochka_balansa/presentation/router/routers.dart';

// GlobalKey для доступа к контексту глобально
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Глобальная переменная для мока
bool isMock = true;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  WidgetsBinding.instance.addObserver(AppLifecycleObserver());
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Tochka Balansa',
      locale: const Locale('ru', 'RU'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ru', 'RU'), Locale('en', 'US')],
      theme: ThemeData(
        // fontFamily: 'ProximaNova',
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder()},
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
