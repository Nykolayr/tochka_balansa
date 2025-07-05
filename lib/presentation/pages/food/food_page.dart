import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';

class FoodPage extends StatelessWidget {
  const FoodPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(textLang('Еда'))));
  }
}
