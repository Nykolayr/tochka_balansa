import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:tochka_balansa/data/models/gender.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';
import 'package:tochka_balansa/presentation/widgets/buttons.dart';
import 'package:tochka_balansa/presentation/widgets/text_form_field.dart';
import 'package:tochka_balansa/presentation/widgets/app_date_field.dart';
import 'package:tochka_balansa/presentation/widgets/app_dropdown_field.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/presentation/widgets/weight_picker_widget.dart';
import 'package:tochka_balansa/presentation/widgets/height_picker_widget.dart';

class UserDataPage extends StatefulWidget {
  const UserDataPage({super.key});

  @override
  State<UserDataPage> createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  double selectedWeight = 70.0;
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

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  void _saveUserData() {
    if (formKey.currentState!.validate()) {
      final age = _calculateAge(selectedDate);

      final updatedUser = _userRepository.user.copyWith(
        name: nameController.text.trim(),
        birthDate: selectedDate,
        age: age,
        gender: selectedGender,
        initialWeight: selectedWeight,
        height: selectedHeight / 100, // конвертируем обратно в метры
      );

      _userRepository.user = updatedUser;
      _userRepository.saveUserToLocal();

      // Переходим на главный экран
      context.go('/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: 'Ваши данные', isBack: false),
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
                    label: 'Дата рождения',
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
                    label: 'Пол',
                    value: selectedGender,
                    items: Gender.values,
                    itemText: (gender) =>
                        gender == Gender.male ? 'Мужской' : 'Женский',
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
                    label: 'Вес',
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
                    label: 'Рост',
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
              text: 'Сохранить',
              onPressed: _saveUserData,
            ),
          ),
        ],
      ),
    );
  }
}
