import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/theme/theme.dart';

enum TextFieldType { email, password, name }

class AppTextFormField extends StatelessWidget {
  final TextFieldType type;
  final TextEditingController controller;
  final bool obscureText;

  const AppTextFormField({
    super.key,
    required this.type,
    required this.controller,
    this.obscureText = false,
  });

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Введите корректный email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите пароль';
    }
    if (value.length < 6) {
      return 'Пароль должен содержать минимум 6 символов';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите имя';
    }
    if (value.length < 4) {
      return 'Имя должно содержать минимум 4 символа';
    }
    if (value[0] != value[0].toUpperCase()) {
      return 'Первая буква должна быть заглавной';
    }
    return null;
  }

  String _getHint() {
    switch (type) {
      case TextFieldType.email:
        return 'Email';
      case TextFieldType.password:
        return 'Пароль';
      case TextFieldType.name:
        return 'Имя';
    }
  }

  IconData _getIcon() {
    switch (type) {
      case TextFieldType.email:
        return Icons.email;
      case TextFieldType.password:
        return Icons.lock;
      case TextFieldType.name:
        return Icons.person;
    }
  }

  String? Function(String?)? _getValidator() {
    switch (type) {
      case TextFieldType.email:
        return _validateEmail;
      case TextFieldType.password:
        return _validatePassword;
      case TextFieldType.name:
        return _validateName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: type == TextFieldType.password && obscureText,
      decoration: InputDecoration(
        labelText: _getHint(),
        prefixIcon: Icon(_getIcon()),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: _getValidator(),
    );
  }
}
