import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';
import 'package:tochka_balansa/presentation/widgets/buttons.dart';
import 'package:tochka_balansa/presentation/widgets/text_form_field.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';

class RegPage extends StatefulWidget {
  const RegPage({super.key});

  @override
  State<RegPage> createState() => _RegPageState();
}

class _RegPageState extends State<RegPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: textLang('Регистрация'), isBack: true),
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Gap(40),

              // Заголовок
              Text(
                textLang('Регистрация'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColor.darkBlue,
                ),
                textAlign: TextAlign.center,
              ),

              const Gap(40),

              // Форма регистрации
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      AppTextFormField(
                        type: TextFieldType.name,
                        controller: nameController,
                      ),
                      const Gap(20),
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
                      const Gap(20),
                      AppTextFormField(
                        type: TextFieldType.password,
                        controller: confirmPasswordController,
                        obscureText: true,
                      ),
                    ],
                  ),
                ),
              ),

              const Gap(30),

              // Кнопка регистрации
              RoundedWideButton(
                text: textLang('Зарегистрироваться'),
                onPressed: _register,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _register() {
    if (formKey.currentState!.validate()) {
      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(textLang('Пароли не совпадают'))),
        );
        return;
      }
      // Логика регистрации
    }
  }
}
