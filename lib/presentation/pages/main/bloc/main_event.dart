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

/// обновление данных о калориях
class UpdateCaloriesEvent extends MainEvent {
  final int consumedCalories;
  final int burnedCalories;
  final int maxCalories;

  const UpdateCaloriesEvent({
    required this.consumedCalories,
    required this.burnedCalories,
    required this.maxCalories,
  });
}
