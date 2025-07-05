import 'package:tochka_balansa/core/l10n/app_en.dart';
import 'package:tochka_balansa/core/l10n/app_ru.dart';

import 'package:tochka_balansa/data/repositories/user_repository.dart';
import 'package:get/get.dart';

String textLang(String text) {
  try {
    final userRepository = Get.find<UserRepository>();
    final userLanguage = userRepository.user.language;

    // Если язык русский, возвращаем текст как есть
    if (userLanguage == 'ru') {
      return text;
    }

    // Если другой язык, ищем перевод
    // Сначала ищем в rusLang по русскому ключу
    if (rusLang.containsKey(text)) {
      // Затем берем перевод из соответствующего langMap
      return enLang[text] ?? text;
    }

    return text;
  } catch (e) {
    // Если не удалось получить репозиторий, возвращаем текст как есть
    return text;
  }
}

void toggleLanguage() {
  try {
    final userRepository = Get.find<UserRepository>();
    final currentLanguage = userRepository.user.language;
    final newLanguage = currentLanguage == 'ru' ? 'en' : 'ru';
    userRepository.saveUserLanguage(newLanguage);
  } catch (e) {
    print('Error toggling language: $e');
  }
}

/// Установка языка (для использования в MainBloc)
void setLanguage(String language) {
  try {
    final userRepository = Get.find<UserRepository>();
    userRepository.saveUserLanguage(language);
  } catch (e) {
    print('Error setting language: $e');
  }
}

/// Геттер для проверки, является ли текущий язык русским
bool get isRussian {
  try {
    final userRepository = Get.find<UserRepository>();
    return userRepository.user.language == 'ru';
  } catch (e) {
    return true; // По умолчанию русский
  }
}

/// Геттер для проверки, является ли текущий язык английским
bool get isEnglish {
  try {
    final userRepository = Get.find<UserRepository>();
    return userRepository.user.language == 'en';
  } catch (e) {
    return false; // По умолчанию русский
  }
}

enum Language {
  english,
  russian;

  String get titleEn => switch (this) {
    english => 'English',
    russian => 'Russian',
  };

  String get titleRu => switch (this) {
    english => 'Английский',
    russian => 'Русский',
  };

  String get flag => switch (this) {
    english => '🇺🇸', // Флаг США
    russian => '🇷🇺', // Флаг России
  };

  Map<String, String> get langMap => switch (this) {
    english => enLang,
    russian => rusLang,
  };
}
