import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/presentation/pages/main/bloc/main_bloc.dart';
import 'package:tochka_balansa/core/theme/colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Заголовок
            Text(
              textLang('Настройки'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColor.darkBlue,
              ),
            ),

            const SizedBox(height: 30),

            // Кнопка выбора языка
            _buildLanguageButton(context),

            const SizedBox(height: 20),

            // Другие настройки можно добавить здесь
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.grey, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showLanguageBottomSheet(context),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Иконка языка
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColor.darkBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.language,
                    color: AppColor.darkBlue,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Текст
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        textLang('Язык'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColor.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isRussian ? textLang('Русский') : 'English',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColor.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Стрелка
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColor.grey,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _LanguageBottomSheet(
        currentLanguage: isRussian ? Language.russian : Language.english,
        onLanguageSelected: (language) {
          final newLanguage = language == Language.english ? 'en' : 'ru';
          // Отправляем событие в MainBloc для обновления языка
          Get.find<MainBloc>().add(UpdateLanguageEvent(newLanguage));
          _showLanguageChangedSnackBar(context, language);
        },
      ),
    );
  }

  void _showLanguageChangedSnackBar(BuildContext context, Language language) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            // Флаг языка
            Text(language.flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            // Текст уведомления
            Expanded(
              child: Text(
                language == Language.english
                    ? textLang('Ваш язык изменен на Английский')
                    : textLang('Ваш язык изменен на Русский'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColor.darkBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'OK',
          textColor: AppColor.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

class _LanguageBottomSheet extends StatelessWidget {
  final Language currentLanguage;
  final Function(Language) onLanguageSelected;

  const _LanguageBottomSheet({
    required this.currentLanguage,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Заголовок
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: AppColor.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            textLang('Выберите язык'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColor.darkBlue,
            ),
          ),

          const SizedBox(height: 20),

          // Список языков
          ...Language.values.map(
            (language) => _buildLanguageTile(
              context,
              language,
              language == currentLanguage,
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    Language language,
    bool isSelected,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onLanguageSelected(language);
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // Флаг
              Text(language.flag, style: const TextStyle(fontSize: 24)),

              const SizedBox(width: 16),

              // Название языка
              Expanded(
                child: Text(
                  language.titleRu,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColor.darkBlue,
                  ),
                ),
              ),

              // Чекбокс
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColor.darkBlue,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
