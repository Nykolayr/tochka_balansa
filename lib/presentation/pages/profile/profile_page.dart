import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/theme/colors.dart';
import 'package:tochka_balansa/core/theme/text.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';
import 'package:tochka_balansa/presentation/pages/profile/widgets/language_selector_widget.dart';
import 'package:tochka_balansa/presentation/widgets/common/custom_modal_sheet.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserRepository _userRepository = Get.find<UserRepository>();

  void _showLogoutDialog() {
    CustomModalSheet.show(
      context: context,
      title: 'Выход из аккаунта',
      height: 200,
      isDismissible: false,
      child: Column(
        children: [
          Text(
            'Вы уверены, что хотите выйти?',
            style: AppText.text16mb.copyWith(color: AppColor.black),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Все данные будут удалены с устройства',
            style: AppText.text14rb.copyWith(color: AppColor.greyText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppColor.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Отмена',
                    style: AppText.text14mb.copyWith(color: AppColor.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _logout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Выйти',
                    style: AppText.text14mb.copyWith(color: AppColor.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await _userRepository.logout();
      // Перенаправляем на страницу авторизации
      Get.offAllNamed('/auth');
    } catch (e) {
      // Показываем ошибку если что-то пошло не так
      Get.snackbar(
        'Ошибка',
        'Не удалось выйти из аккаунта',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

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

            const SizedBox(height: 32),

            // Кнопка выхода
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showLogoutDialog,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColor.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.logout, color: AppColor.red, size: 20),
                label: Text(
                  'Выйти из аккаунта',
                  style: AppText.text14mb.copyWith(color: AppColor.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
