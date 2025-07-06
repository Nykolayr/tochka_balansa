import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/providers/language_bloc.dart';
import 'package:tochka_balansa/core/theme/colors.dart';
import 'package:tochka_balansa/presentation/widgets/app_toast.dart';
import 'package:tochka_balansa/presentation/pages/profile/widgets/profile_settings_item.dart';

class LanguageSelectorWidget extends StatelessWidget {
  const LanguageSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileSettingsItem(
      onTap: () => _showLanguageBottomSheet(context),
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
                  Get.find<LanguageBloc>().currentLanguage == Language.english
                      ? 'English'
                      : textLang('Русский'),
                  style: const TextStyle(fontSize: 14, color: AppColor.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _LanguageBottomSheet(
        currentLanguage: Get.find<LanguageBloc>().currentLanguage,
        onLanguageSelected: (language) {
          // Отправляем событие в LanguageBloc для обновления языка
          Get.find<LanguageBloc>().add(ChangeLanguageEvent(language));
          // Закрываем модал и показываем тост
          Navigator.pop(context);
          _showLanguageChangedToast(language);
        },
      ),
    );
  }

  void _showLanguageChangedToast(Language language) {
    AppToast.show('${language.flag} Ваш язык изменен на ${language.titleRu}');
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected ? AppColor.darkBlue : AppColor.grey,
                  ),
                ),
              ),
              // Галочка для выбранного языка
              if (isSelected)
                const Icon(Icons.check, color: AppColor.darkBlue, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
