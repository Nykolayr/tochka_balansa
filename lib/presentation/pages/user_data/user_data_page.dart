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

class UserDataPage extends StatefulWidget {
  const UserDataPage({super.key});

  @override
  State<UserDataPage> createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  double selectedWeight = 90.0;
  double selectedHeight = 170.0; // в сантиметрах
  DateTime selectedDate = DateTime(2000, 1, 1);
  Gender selectedGender = Gender.male;
  final UserRepository _userRepository = Get.find<UserRepository>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = _userRepository.user;
    if (user.name.isNotEmpty) {
      nameController.text = user.name;
      selectedWeight = user.initialWeight > 0 ? user.initialWeight : 70.0;
      selectedHeight = user.height > 0
          ? user.height * 100
          : 170.0; // конвертируем в см
      selectedDate = user.birthDate;
      selectedGender = user.gender;
    }
  }

  void _saveUserData() {
    if (formKey.currentState!.validate()) {
      // Убираем фокус с текстового поля
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

      // Переходим на главный экран
      context.go('/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: textLang('Ваши данные'), isBack: false),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
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

                  // Дата рождения
                  AppDateField(
                    label: textLang('Дата рождения'),
                    selectedDate: selectedDate,
                    onDateSelected: (date) {
                      setState(() {
                        selectedDate = date;
                      });
                    },
                  ),
                  const Gap(20),

                  // Пол
                  AppDropdownField<Gender>(
                    label: textLang('Пол'),
                    value: selectedGender,
                    items: Gender.values,
                    itemText: (gender) =>
                        gender == Gender.male ? textLang('Мужской') : textLang('Женский'),
                    onChanged: (gender) {
                      if (gender != null) {
                        setState(() {
                          selectedGender = gender;
                        });
                      }
                    },
                  ),
                  const Gap(20),

                  // Вес
                  WeightPickerWidget(
                    value: selectedWeight,
                    onChanged: (weight) {
                      setState(() {
                        selectedWeight = weight;
                      });
                    },
                    label: textLang('Вес'),
                  ),
                  const Gap(20),

                  // Рост
                  HeightPickerWidget(
                    value: selectedHeight,
                    onChanged: (height) {
                      setState(() {
                        selectedHeight = height;
                      });
                    },
                    label: textLang('Рост'),
                  ),
                  const SizedBox(height: 120), // Отступ для кнопок
                ],
              ),
            ),
          ),

          // Кнопка сохранения
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: RoundedWideButton(
              text: textLang('Сохранить'),
              onPressed: _saveUserData,
            ),
          ),
        ],
      ),
    );
  }
}
