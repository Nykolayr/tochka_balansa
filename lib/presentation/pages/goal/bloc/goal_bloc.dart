import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/data/models/goal/additional_goal.dart';
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
  }

  Future<void> _onLoadGoals(
    LoadGoalsEvent event,
    Emitter<GoalState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final user = _userRepository.user;
      emit(
        state.copyWith(
          isLoading: false,
          mainGoal: user.mainGoal,
          additionalGoals: user.additionalGoals,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onSetMainGoal(
    SetMainGoalEvent event,
    Emitter<GoalState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final updatedUser = _userRepository.user.copyWith(mainGoal: event.goal);
      _userRepository.user = updatedUser;
      await _userRepository.saveUserToLocal();

      emit(state.copyWith(isLoading: false, mainGoal: event.goal));
    } catch (e) {
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
