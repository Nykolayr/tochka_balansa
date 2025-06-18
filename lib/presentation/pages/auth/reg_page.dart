import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';
import 'package:tochka_balansa/presentation/widgets/buttons.dart';
import 'package:tochka_balansa/presentation/widgets/text_form_field.dart';

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
      appBar: const AppBarWidget(title: 'Регистрация', isBack: true),
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      AppTextFormField(
                        type: TextFieldType.name,
                        controller: nameController,
                      ),
                      const SizedBox(height: 20),
                      AppTextFormField(
                        type: TextFieldType.email,
                        controller: emailController,
                      ),
                      const SizedBox(height: 20),
                      AppTextFormField(
                        type: TextFieldType.password,
                        controller: passwordController,
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      AppTextFormField(
                        type: TextFieldType.password,
                        controller: confirmPasswordController,
                        obscureText: true,
                      ),
                    ],
                  ),
                ),
              ),
              RoundedWideButton(
                text: 'Зарегистрироваться',
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    if (passwordController.text !=
                        confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Пароли не совпадают')),
                      );
                      return;
                    }
                    // TODO: Implement registration logic
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
