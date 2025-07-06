part of 'language_bloc.dart';

sealed class LanguageEvent extends Equatable {
  const LanguageEvent();

  @override
  List<Object?> get props => [];
}

/// Загрузка языка при инициализации
class LoadLanguageEvent extends LanguageEvent {}

/// Изменение языка пользователем
class ChangeLanguageEvent extends LanguageEvent {
  final LanguageEnum language;
  const ChangeLanguageEvent(this.language);

  @override
  List<Object?> get props => [language];
}

/// Обновление языка из User (после загрузки пользователя)
class UpdateLanguageFromUserEvent extends LanguageEvent {
  final LanguageEnum language;
  const UpdateLanguageFromUserEvent(this.language);

  @override
  List<Object?> get props => [language];
}
