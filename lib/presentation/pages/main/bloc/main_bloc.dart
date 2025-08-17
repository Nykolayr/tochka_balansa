import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/data/models/user.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';

part 'main_event.dart';
part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc() : super(MainState.initial()) {
    on<SetErrorEvent>(_onSetErrorEvent);
    on<GetUserEvent>(_onGetUserEvent);
    on<GoToPageEvent>(_onGoToPageEvent);
    on<UpdateCaloriesEvent>(_onUpdateCaloriesEvent);
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

  /// установка ошибки
  void _onSetErrorEvent(SetErrorEvent event, Emitter<MainState> emit) async {
    emit(state.copyWith(error: event.error));
  }

  /// НОВОЕ: обновление данных о калориях
  void _onUpdateCaloriesEvent(
    UpdateCaloriesEvent event,
    Emitter<MainState> emit,
  ) {

    
    emit(
      state.copyWith(
        consumedCalories: event.consumedCalories,
        burnedCalories: event.burnedCalories,
        maxCalories: event.maxCalories,
      ),
    );
  }
}
