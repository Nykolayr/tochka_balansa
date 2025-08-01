import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:tochka_balansa/data/models/goal/additional_goal.dart';
import 'package:tochka_balansa/data/models/goal/enums_goal.dart';
import 'package:tochka_balansa/data/models/goal/user_goal.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';

part 'goal_event.dart';
part 'goal_state.dart';

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  final UserRepository _userRepository = Get.find<UserRepository>();

  GoalBloc() : super(GoalState.initial()) {
    on<LoadGoalsEvent>(_onLoadGoals);
    on<SetMainGoalEvent>(_onSetMainGoal);
    on<AddAdditionalGoalEvent>(_onAddAdditionalGoal);
    on<RemoveAdditionalGoalEvent>(_onRemoveAdditionalGoal);
    on<UpdateAdditionalGoalEvent>(_onUpdateAdditionalGoal);

    // Загружаем цели при инициализации блока
    Logger.i('GoalBloc: Инициализация блока');
    add(const LoadGoalsEvent());
  }

  Future<void> _onLoadGoals(
    LoadGoalsEvent event,
    Emitter<GoalState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      Logger.i('Загрузка целей из UserRepository');
      final user = _userRepository.user;
      Logger.i('Загружена главная цель: ${user.mainGoal}');
      Logger.i(
        'Загружено дополнительных целей: ${user.additionalGoals.length}',
      );

      // Проверяем, не загружаем ли мы пустую цель, когда у нас уже есть цель
      if (!user.mainGoal.hasMainGoal && state.mainGoal.hasMainGoal) {
        Logger.w(
          'Попытка загрузить пустую цель, когда уже есть цель. Сохраняем текущую.',
        );
        // Сохраняем текущую цель обратно в UserRepository
        final updatedUser = _userRepository.user.copyWith(
          mainGoal: state.mainGoal,
        );
        _userRepository.user = updatedUser;
        await _userRepository.saveUserToLocal();

        emit(state.copyWith(isLoading: false));
        return;
      }

      emit(
        state.copyWith(
          isLoading: false,
          mainGoal: user.mainGoal,
          additionalGoals: user.additionalGoals,
        ),
      );
    } catch (e) {
      Logger.e('Ошибка загрузки целей: $e');
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onSetMainGoal(
    SetMainGoalEvent event,
    Emitter<GoalState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      Logger.i('Сохранение главной цели: ${event.goal}');

      // Проверяем, что цель имеет правильный тип
      if (event.goal.goalType == GoalType.none) {
        Logger.e('Попытка сохранить цель с типом GoalType.none');
        emit(
          state.copyWith(
            isLoading: false,
            error: 'Невозможно сохранить цель без типа',
          ),
        );
        return;
      }

      final updatedUser = _userRepository.user.copyWith(mainGoal: event.goal);
      Logger.i('Обновленный пользователь: ${updatedUser.mainGoal}');
      _userRepository.user = updatedUser;

      // Сохраняем в Hive
      await _userRepository.saveUserToLocal();
      Logger.i('Главная цель сохранена в Hive');

      // Проверяем, что цель правильно сохранилась
      await _userRepository.loadUserFromLocal();
      Logger.i(
        'Проверка после сохранения: mainGoal = ${_userRepository.user.mainGoal}',
      );

      // Обновляем состояние блока
      emit(state.copyWith(isLoading: false, mainGoal: event.goal));

      // Явно вызываем загрузку целей после небольшой задержки
      Future.delayed(const Duration(milliseconds: 300), () {
        add(const LoadGoalsEvent());
      });
    } catch (e) {
      Logger.e('Ошибка сохранения главной цели: $e');
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onAddAdditionalGoal(
    AddAdditionalGoalEvent event,
    Emitter<GoalState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final updatedGoals = [...state.additionalGoals, event.goal];
      final updatedUser = _userRepository.user.copyWith(
        additionalGoals: updatedGoals,
      );
      _userRepository.user = updatedUser;
      await _userRepository.saveUserToLocal();

      emit(state.copyWith(isLoading: false, additionalGoals: updatedGoals));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onRemoveAdditionalGoal(
    RemoveAdditionalGoalEvent event,
    Emitter<GoalState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final updatedGoals = state.additionalGoals
          .where((goal) => goal.id != event.goalId)
          .toList();
      final updatedUser = _userRepository.user.copyWith(
        additionalGoals: updatedGoals,
      );
      _userRepository.user = updatedUser;
      await _userRepository.saveUserToLocal();

      emit(state.copyWith(isLoading: false, additionalGoals: updatedGoals));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onUpdateAdditionalGoal(
    UpdateAdditionalGoalEvent event,
    Emitter<GoalState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final updatedGoals = state.additionalGoals.map((goal) {
        return goal.id == event.goal.id ? event.goal : goal;
      }).toList();

      final updatedUser = _userRepository.user.copyWith(
        additionalGoals: updatedGoals,
      );
      _userRepository.user = updatedUser;
      await _userRepository.saveUserToLocal();

      emit(state.copyWith(isLoading: false, additionalGoals: updatedGoals));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
