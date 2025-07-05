import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tochka_balansa/data/datasources/hive_data.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:get/get.dart';
import 'package:flutter_easylogger/flutter_logger.dart';

part 'language_event.dart';
part 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc() : super(LanguageInitial()) {
    on<LoadLanguageEvent>(_onLoadLanguage);
    on<ChangeLanguageEvent>(_onChangeLanguage);
    on<UpdateLanguageFromUserEvent>(_onUpdateLanguageFromUser);
  }

  /// Загрузка языка при инициализации
  Future<void> _onLoadLanguage(
    LoadLanguageEvent event,
    Emitter<LanguageState> emit,
  ) async {
    emit(LanguageLoading());
    try {
      // Сначала пытаемся загрузить из Hive
      final savedLanguage = await _loadLanguageFromHive();

      if (savedLanguage != null) {
        // Обновляем UserRepository
        _updateUserRepositoryLanguage(savedLanguage);
        emit(LanguageLoaded(savedLanguage));
      } else {
        // Если нет сохраненного языка, берем из системной локали
        final systemLanguage = _getSystemLanguage();
        // Обновляем UserRepository
        _updateUserRepositoryLanguage(systemLanguage);
        emit(LanguageLoaded(systemLanguage));
        // Сохраняем системный язык в Hive
        await _saveLanguageToHive(systemLanguage);
      }
    } catch (e) {
      // В случае ошибки используем русский по умолчанию
      _updateUserRepositoryLanguage(Language.russian);
      emit(LanguageLoaded(Language.russian));
    }
  }

  /// Изменение языка пользователем
  Future<void> _onChangeLanguage(
    ChangeLanguageEvent event,
    Emitter<LanguageState> emit,
  ) async {
    try {
      // Обновляем UserRepository
      _updateUserRepositoryLanguage(event.language);
      await _saveLanguageToHive(event.language);
      emit(LanguageLoaded(event.language));
    } catch (e) {
      emit(LanguageError('Ошибка при смене языка: $e'));
    }
  }

  /// Обновление языка из User (после загрузки пользователя)
  Future<void> _onUpdateLanguageFromUser(
    UpdateLanguageFromUserEvent event,
    Emitter<LanguageState> emit,
  ) async {
    try {
      // Обновляем UserRepository
      _updateUserRepositoryLanguage(event.language);
      await _saveLanguageToHive(event.language);
      emit(LanguageLoaded(event.language));
    } catch (e) {
      emit(LanguageError('Ошибка при обновлении языка: $e'));
    }
  }

  /// Обновление языка в UserRepository
  void _updateUserRepositoryLanguage(Language language) {
    try {
      // Проверяем, существует ли UserRepository в Get
      if (Get.isRegistered<UserRepository>()) {
        final userRepository = Get.find<UserRepository>();
        final languageCode = _getLanguageCode(language);
        userRepository.saveUserLanguage(languageCode);
      }
    } catch (e) {
      Logger.e('Error updating UserRepository language: $e');
    }
  }

  /// Получение кода языка из enum
  String _getLanguageCode(Language language) {
    return switch (language) {
      Language.english => 'en',
      Language.russian => 'ru',
    };
  }

  /// Получение enum из кода языка
  Language _getLanguageFromCode(String code) {
    return switch (code) {
      'en' => Language.english,
      'ru' => Language.russian,
      _ => Language.russian, // По умолчанию русский
    };
  }

  /// Загрузка языка из Hive
  Future<Language?> _loadLanguageFromHive() async {
    try {
      final data = await HiveData.loadJson(key: HiveDataKey.language);
      final languageCode = data['language'] as String?;
      if (languageCode != null) {
        return _getLanguageFromCode(languageCode);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Сохранение языка в Hive
  Future<void> _saveLanguageToHive(Language language) async {
    final languageCode = _getLanguageCode(language);
    await HiveData.saveJson(
      json: {'language': languageCode},
      key: HiveDataKey.language,
    );
  }

  /// Получение языка из системной локали
  Language _getSystemLanguage() {
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    return systemLocale.languageCode == 'en'
        ? Language.english
        : Language.russian;
  }

  /// Геттер для проверки, является ли текущий язык русским
  bool get isRussian {
    if (state is LanguageLoaded) {
      return (state as LanguageLoaded).language == Language.russian;
    }
    return true; // По умолчанию русский
  }

  /// Геттер для проверки, является ли текущий язык английским
  bool get isEnglish {
    if (state is LanguageLoaded) {
      return (state as LanguageLoaded).language == Language.english;
    }
    return false;
  }

  /// Геттер для получения текущего языка
  Language get currentLanguage {
    if (state is LanguageLoaded) {
      return (state as LanguageLoaded).language;
    }
    return Language.russian; // По умолчанию русский
  }
}
