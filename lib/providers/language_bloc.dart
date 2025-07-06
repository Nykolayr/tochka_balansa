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
      _updateUserRepositoryLanguage(LanguageEnum.russian);
      emit(LanguageLoaded(LanguageEnum.russian));
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
  void _updateUserRepositoryLanguage(LanguageEnum language) {
    try {
      // Проверяем, существует ли UserRepository в Get
      if (Get.isRegistered<UserRepository>()) {
        final userRepository = Get.find<UserRepository>();
        userRepository.saveUserLanguage(language);
      }
    } catch (e) {
      Logger.e('Error updating UserRepository language: $e');
    }
  }

  /// Загрузка языка из Hive
  Future<LanguageEnum?> _loadLanguageFromHive() async {
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
  Future<void> _saveLanguageToHive(LanguageEnum language) async {
    await HiveData.saveJson(
      json: {'language': language.code},
      key: HiveDataKey.language,
    );
  }

  /// Получение enum из кода языка
  LanguageEnum _getLanguageFromCode(String code) {
    return switch (code) {
      'en' => LanguageEnum.english,
      'ru' => LanguageEnum.russian,
      _ => LanguageEnum.russian, // По умолчанию русский
    };
  }

  /// Получение языка из системной локали
  LanguageEnum _getSystemLanguage() {
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    return systemLocale.languageCode == 'en'
        ? LanguageEnum.english
        : LanguageEnum.russian;
  }

  /// Геттер для проверки, является ли текущий язык русским
  bool get isRussian {
    if (state is LanguageLoaded) {
      return (state as LanguageLoaded).language == LanguageEnum.russian;
    }
    return true; // По умолчанию русский
  }

  /// Геттер для проверки, является ли текущий язык английским
  bool get isEnglish {
    if (state is LanguageLoaded) {
      return (state as LanguageLoaded).language == LanguageEnum.english;
    }
    return false;
  }

  /// Геттер для получения текущего языка
  LanguageEnum get currentLanguage {
    if (state is LanguageLoaded) {
      return (state as LanguageLoaded).language;
    }
    return LanguageEnum.russian; // По умолчанию русский
  }
}
