part of 'language_bloc.dart';

sealed class LanguageState extends Equatable {
  const LanguageState();

  @override
  List<Object?> get props => [];
}

/// Начальное состояние
class LanguageInitial extends LanguageState {}

/// Загрузка языка
class LanguageLoading extends LanguageState {}

/// Язык загружен
class LanguageLoaded extends LanguageState {
  final Language language;

  const LanguageLoaded(this.language);

  @override
  List<Object?> get props => [language];
}

/// Ошибка загрузки языка
class LanguageError extends LanguageState {
  final String message;

  const LanguageError(this.message);

  @override
  List<Object?> get props => [message];
}
