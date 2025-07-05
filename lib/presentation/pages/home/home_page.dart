import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(textLang('Главная'))));
  }
}
