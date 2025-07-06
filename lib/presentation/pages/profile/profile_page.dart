import 'package:flutter/material.dart';
import 'package:tochka_balansa/presentation/pages/profile/widgets/language_selector_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Виджет выбора языка
            const LanguageSelectorWidget(),
          ],
        ),
      ),
    );
  }
}
