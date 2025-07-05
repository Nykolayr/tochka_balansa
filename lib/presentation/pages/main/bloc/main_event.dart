part of 'main_bloc.dart';

sealed class MainEvent extends Equatable {
  const MainEvent();

  @override
  List<Object> get props => [];
}

/// получение пользователя
class GetUserEvent extends MainEvent {}

/// установка ошибки
class SetErrorEvent extends MainEvent {
  final String error;
  const SetErrorEvent(this.error);
}

/// переход на страницу
class GoToPageEvent extends MainEvent {
  final int pageIndex;
  const GoToPageEvent(this.pageIndex);
}

/// обновление языка
class UpdateLanguageEvent extends MainEvent {
  final String language;
  const UpdateLanguageEvent(this.language);
}
