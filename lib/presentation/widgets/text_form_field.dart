import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';

enum TextFieldType { email, password, name, weight, height }

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
      return textLang('Введите email');
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return textLang('Введите корректный email');
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return textLang('Введите пароль');
    }
    if (value.length < 6) {
      return textLang('Пароль должен содержать минимум 6 символов');
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return textLang('Введите имя');
    }
    if (value.length < 4) {
      return textLang('Имя должно содержать минимум 4 символа');
    }
    return null;
  }

  String? _validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return textLang('Введите вес');
    }
    final weight = double.tryParse(value);
    if (weight == null || weight < 1 || weight > 300) {
      return textLang('Введите корректный вес (1-300 кг)');
    }
    return null;
  }

  String? _validateHeight(String? value) {
    if (value == null || value.isEmpty) {
      return textLang('Введите рост');
    }
    final height = double.tryParse(value);
    if (height == null || height < 1 || height > 250) {
      return textLang('Введите корректный рост (1-250 см)');
    }
    return null;
  }

  String _getLabel() {
    switch (type) {
      case TextFieldType.email:
        return textLang('Email');
      case TextFieldType.password:
        return textLang('Пароль');
      case TextFieldType.name:
        return textLang('Имя');
      case TextFieldType.weight:
        return textLang('Вес (кг)');
      case TextFieldType.height:
        return textLang('Рост (см)');
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
      case TextFieldType.weight:
        return Icons.monitor_weight;
      case TextFieldType.height:
        return Icons.height;
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
      case TextFieldType.weight:
        return _validateWeight;
      case TextFieldType.height:
        return _validateHeight;
    }
  }

  TextInputType _getKeyboardType() {
    switch (type) {
      case TextFieldType.email:
        return TextInputType.emailAddress;
      case TextFieldType.password:
        return TextInputType.visiblePassword;
      case TextFieldType.name:
        return TextInputType.name;
      case TextFieldType.weight:
      case TextFieldType.height:
        return TextInputType.number;
    }
  }

  TextCapitalization _getTextCapitalization() {
    switch (type) {
      case TextFieldType.name:
        return TextCapitalization.words;
      default:
        return TextCapitalization.none;
    }
  }

  List<TextInputFormatter>? _getInputFormatters() {
    switch (type) {
      case TextFieldType.name:
        return [FilteringTextInputFormatter.allow(RegExp(r'[а-яА-Яa-zA-Z\s]'))];
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: type == TextFieldType.password && obscureText,
      keyboardType: _getKeyboardType(),
      textCapitalization: _getTextCapitalization(),
      inputFormatters: _getInputFormatters(),
      enableSuggestions: false,
      autocorrect: false,
      enableInteractiveSelection: false,
      decoration: InputDecoration(
        labelText: _getLabel(),
        prefixIcon: Icon(_getIcon()),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: _getValidator(),
    );
  }
}
