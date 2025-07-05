import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/data/models/user.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';

part 'main_event.dart';
part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc() : super(MainState.initial()) {
    on<SetErrorEvent>(_onSetErrorEvent);
    on<GetUserEvent>(_onGetUserEvent);
    on<GoToPageEvent>(_onGoToPageEvent);
    on<UpdateLanguageEvent>(_onUpdateLanguageEvent);
  }

  /// переход на страницу
  void _onGoToPageEvent(GoToPageEvent event, Emitter<MainState> emit) {
    emit(state.copyWith(selectedIndex: event.pageIndex));
  }

  /// получение пользователя
  Future<void> _onGetUserEvent(
    GetUserEvent event,
    Emitter<MainState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    UserRepository repo = Get.find<UserRepository>();
    final answer = await repo.getUser();
    emit(state.copyWith(isLoading: false));
    if (answer.isEmpty) {
      emit(state.copyWith(user: repo.user));
    } else {
      emit(state.copyWith(error: answer));
    }
  }

  /// обновление языка
  void _onUpdateLanguageEvent(
    UpdateLanguageEvent event,
    Emitter<MainState> emit,
  ) {
    // Устанавливаем язык
    setLanguage(event.language);
    // Обновляем состояние для перезагрузки страниц
    emit(state.copyWith(shouldRefresh: true));
  }

  /// установка ошибки
  void _onSetErrorEvent(SetErrorEvent event, Emitter<MainState> emit) async {
    emit(state.copyWith(error: event.error));
  }
}
