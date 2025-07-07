import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';
import 'package:tochka_balansa/presentation/widgets/buttons.dart';
import 'package:tochka_balansa/presentation/widgets/text_form_field.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with WidgetsBindingObserver {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  double keyboardHeight = 0;
  bool isEnable = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = WidgetsBinding
        .instance
        .platformDispatcher
        .views
        .first
        .viewInsets
        .bottom;
    setState(() {
      keyboardHeight =
          bottomInset /
          WidgetsBinding
              .instance
              .platformDispatcher
              .views
              .first
              .devicePixelRatio;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: textLang('Вход'), isBack: false),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Gap(40),

            // Заголовок
            Text(
              textLang('Добро пожаловать'),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColor.darkBlue,
              ),
              textAlign: TextAlign.center,
            ),

            const Gap(40),

            // Форма входа
            Form(
              key: formKey,
              child: Column(
                children: [
                  AppTextFormField(
                    type: TextFieldType.email,
                    controller: emailController,
                  ),
                  const Gap(20),
                  AppTextFormField(
                    type: TextFieldType.password,
                    controller: passwordController,
                    obscureText: true,
                  ),
                ],
              ),
            ),

            const Gap(30),

            // Кнопка входа
            RoundedWideButton(text: textLang('Войти'), onPressed: () {}),

            const Gap(20),

            // Ссылка на регистрацию
            TextButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                context.pushNamed('регистрация пользователя');
              },
              child: Text(
                textLang('Нет аккаунта? Зарегистрируйтесь'),
                style: const TextStyle(color: AppColor.darkBlue, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        margin: EdgeInsets.only(bottom: keyboardHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RoundedWideButton(text: textLang('Войти'), onPressed: () {}),
            const Gap(20),
            TextButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                context.pushNamed('регистрация пользователя');
              },
              child: Text(
                textLang('Нет аккаунта? Зарегистрируйтесь'),
                style: AppText.text16rb.copyWith(color: AppColor.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
