import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:tochka_balansa/data/models/gender.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';
import 'package:tochka_balansa/presentation/pages/auth/bloc/auth_bloc.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';
import 'package:tochka_balansa/presentation/widgets/buttons.dart';
import 'package:tochka_balansa/presentation/widgets/text_form_field.dart';
import 'package:tochka_balansa/presentation/widgets/app_date_field.dart';
import 'package:tochka_balansa/presentation/widgets/app_dropdown_field.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/presentation/widgets/weight_picker_widget.dart';
import 'package:tochka_balansa/presentation/widgets/height_picker_widget.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'dart:async';

class UserDataPage extends StatefulWidget {
  const UserDataPage({super.key});

  @override
  State<UserDataPage> createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage>
    with WidgetsBindingObserver {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final GlobalKey _weightKey = GlobalKey();
  final GlobalKey _heightKey = GlobalKey();
  final _scrollController = ScrollController(); // <-- Добавлено

  double selectedWeight = 90.0;
  double selectedHeight = 165.0;
  DateTime selectedDate = DateTime(2000, 1, 1);
  Gender selectedGender = Gender.male;
  final UserRepository _userRepository = Get.find<UserRepository>();
  late StreamSubscription<bool> keyboardSubscription;
  double keyboardHeight = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
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
    nameController.dispose();
    keyboardSubscription.cancel();
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _loadUserData() {
    final user = _userRepository.user;
    if (user.name.isNotEmpty) {
      nameController.text = user.name;
      selectedWeight = user.initialWeight > 0 ? user.initialWeight : 70.0;
      selectedHeight = user.height > 0 ? user.height * 100 : 165.0;
      selectedDate = user.birthDate;
      selectedGender = user.gender;
    }
  }

  void _saveUserData() {
    if (formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      Get.find<AuthBloc>().add(
        SaveUserDataEvent(
          name: nameController.text,
          weight: selectedWeight,
          height: selectedHeight,
          birthDate: selectedDate,
          gender: selectedGender,
        ),
      );
      context.go('/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: textLang('Ваши данные'), isBack: false),
      body: SingleChildScrollView(
        controller: _scrollController, // <-- Добавлено
        padding: const EdgeInsets.all(20),
        physics: const ClampingScrollPhysics(), // <-- Добавлено
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
                onDateSelected: (date) => setState(() => selectedDate = date),
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

              WeightPickerWidget(
                key: _weightKey,
                value: selectedWeight,
                onChanged: (weight) => setState(() => selectedWeight = weight),
                label: textLang('Вес'),
              ),
              const Gap(20),
              HeightPickerWidget(
                key: _heightKey,
                value: selectedHeight,
                onChanged: (height) => setState(() => selectedHeight = height),
                label: textLang('Рост'),
              ),

              const Gap(40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        margin: EdgeInsets.only(bottom: keyboardHeight),
        child: RoundedWideButton(
          text: textLang('Сохранить'),
          onPressed: _saveUserData,
        ),
      ),
    );
  }
}
