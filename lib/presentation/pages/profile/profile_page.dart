import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
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
      title: 'Вы уверены, что хотите выйти?',
      height: 220,
      isDismissible: true,
      showCloseButton: false,
      child: Column(
        children: [
          Text(
            'Все данные будут удалены с устройства',
            style: AppText.text14rb.copyWith(color: AppColor.greyText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
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
      // Перезапускаем приложение с самого начала (сплэш экран)
      if (context.mounted) {
        context.go('/splash');
      }
    } catch (e) {
      // Показываем ошибку если что-то пошло не так
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось выйти из аккаунта'),
            backgroundColor: AppColor.red,
          ),
        );
      }
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
