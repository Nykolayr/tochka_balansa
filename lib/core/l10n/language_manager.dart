import 'package:tochka_balansa/core/l10n/app_en.dart';
import 'package:tochka_balansa/core/l10n/app_ru.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';
import 'package:tochka_balansa/data/datasources/hive_data.dart';
import 'package:get/get.dart';
import 'package:flutter_easylogger/flutter_logger.dart';

String textLang(String text) {
  try {
    // Читаем язык напрямую из Hive синхронно
    final data = HiveData.loadJsonSync(key: HiveDataKey.language);
    final userLanguage = data?['language'] as String? ?? 'ru';

    // Если язык русский, возвращаем текст как есть
    if (userLanguage == 'ru') {
      return text;
    }

    // Если другой язык, ищем перевод
    // Сначала ищем в rusLang по русскому ключу
    if (rusLang.containsKey(text)) {
      // Затем берем перевод из соответствующего langMap
      final translation = enLang[text] ?? text;
      return translation;
    }

    return text;
  } catch (e) {
    Logger.e('textLang error: $e');
    // Если не удалось получить язык, возвращаем текст как есть
    return text;
  }
}

void toggleLanguage() {
  try {
    final userRepository = Get.find<UserRepository>();
    final currentLanguage = userRepository.user.language;
    final newLanguage = currentLanguage == 'ru' ? 'en' : 'ru';
    userRepository.saveUserLanguage(newLanguage);
    // Также сохраняем в Hive
    _saveLanguageToHive(newLanguage);
  } catch (e) {
    Logger.e('Error toggling language: $e');
  }
}

/// Установка языка (для использования в MainBloc)
void setLanguage(String language) {
  try {
    final userRepository = Get.find<UserRepository>();
    userRepository.saveUserLanguage(language);
    // Также сохраняем в Hive
    _saveLanguageToHive(language);
  } catch (e) {
    Logger.e('Error setting language: $e');
  }
}

/// Сохранение языка в Hive
Future<void> _saveLanguageToHive(String language) async {
  try {
    await HiveData.saveJson(
      json: {'language': language},
      key: HiveDataKey.language,
    );
  } catch (e) {
    Logger.e('Error saving language to Hive: $e');
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

/// Получение кода языка из enum
String getLanguageCode(Language language) {
  return switch (language) {
    Language.english => 'en',
    Language.russian => 'ru',
  };
}

/// Получение enum из кода языка
Language getLanguageFromCode(String code) {
  return switch (code) {
    'en' => Language.english,
    'ru' => Language.russian,
    _ => Language.russian, // По умолчанию русский
  };
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
