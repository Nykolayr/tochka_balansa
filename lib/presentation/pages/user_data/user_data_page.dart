import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:tochka_balansa/data/models/gender.dart';
import 'package:tochka_balansa/data/models/health/activity_level.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';
import 'package:tochka_balansa/presentation/pages/auth/bloc/auth_bloc.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';
import 'package:tochka_balansa/presentation/widgets/buttons.dart';
import 'package:tochka_balansa/presentation/widgets/text_form_field.dart';
import 'package:tochka_balansa/presentation/widgets/app_date_field.dart';
import 'package:tochka_balansa/presentation/widgets/app_dropdown_field.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/presentation/widgets/number_picker_wheel.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';

class UserDataPage extends StatefulWidget {
  const UserDataPage({super.key});

  @override
  State<UserDataPage> createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final GlobalKey _weightKey = GlobalKey();
  final GlobalKey _heightKey = GlobalKey();
  final _scrollController = ScrollController();

  double selectedWeight = 70.0;
  double selectedHeight = 170.0;
  DateTime selectedDate = DateTime(2000, 1, 1);
  Gender selectedGender = Gender.male;
  ActivityLevel selectedActivityLevel =
      ActivityLevel.sedentary; // По умолчанию сидячий
  final UserRepository _userRepository = Get.find<UserRepository>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = _userRepository.user;
    if (user.name.isNotEmpty) {
      nameController.text = user.name;
      selectedWeight = user.initialWeight > 0 ? user.initialWeight : 70.0;
      selectedHeight = user.height > 0
          ? user.height
          : 170.0; // Убрал умножение на 100
      selectedDate = user.birthDate;
      selectedGender = user.gender;
      selectedActivityLevel = user.activityLevel; // НОВОЕ поле
    }
  }

  void _saveUserData() {
    if (formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      // Автоматически исправляем первую букву имени
      String correctedName = _capitalizeFirstLetter(nameController.text);

      Get.find<AuthBloc>().add(
        SaveUserDataEvent(
          name: correctedName,
          weight: selectedWeight,
          height: selectedHeight,
          birthDate: selectedDate,
          gender: selectedGender,
          activityLevel: selectedActivityLevel, // НОВОЕ поле
        ),
      );
      context.go('/main');
    }
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;

    // Проверяем, является ли первый символ буквой (русской или английской)
    if (RegExp(r'[а-яА-Яa-zA-Z]').hasMatch(text[0])) {
      return text[0].toUpperCase() + text.substring(1).toLowerCase();
    }

    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScreenHeight>(
      builder: (context, res, child) {
        final keyboardHeight = res.keyboardHeight > 0
            ? res.keyboardHeight
            : 0.0;

        return Scaffold(
          appBar: AppBarWidget(title: textLang('Ваши данные'), isBack: false),
          body: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            physics: const ClampingScrollPhysics(),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextFormField(
                    type: TextFieldType.name,
                    controller: nameController,
                  ),
                  const Gap(20),

                  AppDateField(
                    label: textLang('Дата рождения'),
                    selectedDate: selectedDate,
                    onDateSelected: (date) =>
                        setState(() => selectedDate = date),
                  ),
                  const Gap(20),

                  AppDropdownField<Gender>(
                    label: textLang('Пол'),
                    value: selectedGender,
                    items: Gender.values,
                    itemText: (gender) => gender == Gender.male
                        ? textLang('Мужской')
                        : textLang('Женский'),
                    onChanged: (gender) {
                      if (gender != null) {
                        setState(() => selectedGender = gender);
                      }
                    },
                  ),
                  const Gap(20),

                  NumberPickerWheel(
                    key: _weightKey,
                    value: selectedWeight,
                    onChanged: (weight) =>
                        setState(() => selectedWeight = weight),
                    label: textLang('Вес'),
                    unit: 'кг',
                    min: 30.0,
                    max: 290.0,
                    decimalPlaces: 0,
                    step: 1.0,
                  ),
                  const Gap(20),
                  NumberPickerWheel(
                    key: _heightKey,
                    value: selectedHeight,
                    onChanged: (height) =>
                        setState(() => selectedHeight = height),
                    label: textLang('Рост'),
                    unit: 'см',
                    min: 120.0,
                    max: 250.0,
                    decimalPlaces: 0,
                    step: 1.0,
                  ),

                  const Gap(20),
                  // НОВОЕ поле для выбора уровня активности
                  AppDropdownField<ActivityLevel>(
                    label: textLang('Уровень активности'),
                    value: selectedActivityLevel,
                    items: ActivityLevel.values,
                    itemText: (level) => level.title,
                    onChanged: (level) {
                      if (level != null) {
                        setState(() => selectedActivityLevel = level);
                      }
                    },
                  ),

                  const Gap(20),
                  Gap(keyboardHeight),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: RoundedWideButton(
              text: textLang('Сохранить'),
              onPressed: _saveUserData,
            ),
          ),
        );
      },
    );
  }
}
