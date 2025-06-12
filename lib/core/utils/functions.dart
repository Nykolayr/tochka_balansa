import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';

/// функция создает различные анимации для переходов по страницам

CustomTransitionPage<dynamic> buildPageWithDefaultTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  required PageTransitionType type,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    restorationId: state.pageKey.value,
    name: state.name,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        PageTransition(
          child: child,
          type: type,
        ).buildTransitions(context, animation, secondaryAnimation, child),
  );
}
