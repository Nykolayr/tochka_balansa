import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';

class GoalPage extends StatelessWidget {
  const GoalPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(textLang('Тренировки'))));
  }
}
