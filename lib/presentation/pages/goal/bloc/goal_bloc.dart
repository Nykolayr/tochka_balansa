import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:tochka_balansa/data/models/goal/additional_goal.dart';
import 'package:tochka_balansa/data/models/goal/enums_goal.dart';
import 'package:tochka_balansa/data/models/goal/user_goal.dart';
import 'package:tochka_balansa/data/models/goal/default_goal_types.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';

part 'goal_event.dart';
part 'goal_state.dart';

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  final UserRepository _userRepository = Get.find<UserRepository>();

  GoalBloc() : super(GoalState.initial()) {
    on<LoadGoalsEvent>(_onLoadGoals);
    on<LoadGoalTypesEvent>(_onLoadGoalTypes);
    on<SetMainGoalEvent>(_onSetMainGoal);
    on<AddAdditionalGoalEvent>(_onAddAdditionalGoal);
    on<RemoveAdditionalGoalEvent>(_onRemoveAdditionalGoal);
    on<UpdateAdditionalGoalEvent>(_onUpdateAdditionalGoal);
    on<AddGoalTemplateEvent>(_onAddGoalTemplate);
    on<CompleteSubGoalEvent>(_onCompleteSubGoal); // Добавляем обработчик
    on<MoveToArchiveEvent>(_onMoveToArchive); // Добавляем обработчик

    // Инициализация блока (без автоматической загрузки данных)
    Logger.i('GoalBloc: Инициализация блока');
  }

  Future<void> _onLoadGoalTypes(
    LoadGoalTypesEvent event,
    Emitter<GoalState> emit,
  ) async {
    try {
      // Загружаем типы целей только если их еще нет
      if (_userRepository.goalTypes.isEmpty) {
        await _userRepository.loadGoalTypesFromLocal();
      }

      // Создаем стандартные типы целей, если их нет
      final goalTypes = _userRepository.goalTypes;
      if (goalTypes.isEmpty) {
        final defaultTypes = DefaultGoalTypes.defaultTypes;
        _userRepository.goalTypes = defaultTypes;
        await _userRepository.saveGoalTypesToLocal();
      }

      emit(state.copyWith(goalTypes: _userRepository.goalTypes));
    } catch (e) {
      Logger.e('Ошибка загрузки типов целей: $e');
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onLoadGoals(
    LoadGoalsEvent event,
    Emitter<GoalState> emit,
  ) async {
    Logger.i(
      'GoalBloc: Получен LoadGoalsEvent (${DateTime.now().millisecondsSinceEpoch})',
    );

    emit(state.copyWith(isLoading: true));

    try {
      // Пользователь уже загружен в UserRepository.init(), загружаем только архив
      if (_userRepository.archivedGoals.isEmpty) {
        await _userRepository.loadArchivedGoalsFromLocal();
      }

      // Загружаем типы целей, если их еще нет
      if (_userRepository.goalTypes.isEmpty) {
        await _userRepository.loadGoalTypesFromLocal();

        // Создаем стандартные типы целей, если их нет
        if (_userRepository.goalTypes.isEmpty) {
          final defaultTypes = DefaultGoalTypes.defaultTypes;
          _userRepository.goalTypes = defaultTypes;
          await _userRepository.saveGoalTypesToLocal();
        }
      }

      Logger.i('Загрузка целей из UserRepository');
      final user = _userRepository.user;
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
          archivedGoals: _userRepository.archivedGoals, // Добавляем архив
          goalTypes: _userRepository.goalTypes, // Добавляем типы целей
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

      // Проверяем, что цель правильно сохранилась (пользователь уже в памяти)
      Logger.i(
        'Проверка после сохранения: mainGoal = ${_userRepository.user.mainGoal}',
      );

      // Обновляем состояние блока
      emit(state.copyWith(isLoading: false, mainGoal: event.goal));
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

  Future<void> _onAddGoalTemplate(
    AddGoalTemplateEvent event,
    Emitter<GoalState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Создаем новый шаблон на основе цели
      final template = AdditionalGoal(
        id: 'template_${DateTime.now().millisecondsSinceEpoch}',
        title: event.goal.title,
        description: event.goal.description,
        createdAt: DateTime.now(),
        deadlineType: DeadlineType.fixed,
        targetDate: DateTime.now().add(const Duration(days: 30)),
        targetCount: event.goal.targetCount,
        unit: event.goal.unit,
        goalTo: event.goal.goalTo,
        reminderText: event.goal.reminderText,
        subGoals: event.goal.subGoals,
        icon: event.goal.icon,
      );

      // Добавляем шаблон в список типов целей
      final updatedGoalTypes = [...state.goalTypes, template];
      _userRepository.goalTypes = updatedGoalTypes;
      await _userRepository.saveGoalTypesToLocal();

      emit(state.copyWith(isLoading: false, goalTypes: updatedGoalTypes));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onCompleteSubGoal(
    CompleteSubGoalEvent event,
    Emitter<GoalState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Находим цель
      final goalIndex = state.additionalGoals.indexWhere(
        (g) => g.id == event.goalId,
      );
      if (goalIndex == -1) {
        emit(state.copyWith(isLoading: false, error: 'Цель не найдена'));
        return;
      }

      final goal = state.additionalGoals[goalIndex];

      // Обновляем подзадачу
      final updatedSubGoals = goal.subGoals.map((subGoal) {
        if (subGoal.id == event.subGoalId) {
          return subGoal.copyWith(
            isCompleted: true,
            currentCount:
                subGoal.targetCount, // Устанавливаем максимальное значение
          );
        }
        return subGoal;
      }).toList();

      final updatedGoal = goal.copyWith(
        subGoals: updatedSubGoals,
        endDate: DateTime.now(), // Добавляем endDate
      );

      // Проверяем, все ли подзадачи завершены
      final allCompleted = updatedSubGoals.every((sg) => sg.isCompleted);

      if (allCompleted) {
        // Все подзадачи завершены - перемещаем в архив
        final completedGoal = updatedGoal.copyWith(
          isCompleted: true,
          completionDate: DateTime.now(),
          // endDate уже установлен в updatedGoal, поэтому не нужно его устанавливать снова
        );

        final updatedAdditionalGoals = state.additionalGoals
            .where((g) => g.id != event.goalId)
            .toList();

        final updatedArchivedGoals = [...state.archivedGoals, completedGoal];

        // Сохраняем изменения
        final updatedUser = _userRepository.user.copyWith(
          additionalGoals: updatedAdditionalGoals,
        );
        _userRepository.user = updatedUser;
        await _userRepository.saveUserToLocal();

        // Сохраняем архив
        _userRepository.archivedGoals = updatedArchivedGoals;
        await _userRepository.saveArchivedGoalsToLocal();

        emit(
          state.copyWith(
            isLoading: false,
            additionalGoals: updatedAdditionalGoals,
            archivedGoals: updatedArchivedGoals,
          ),
        );

        // Убираем Get.snackbar отсюда
      } else {
        // Не все подзадачи завершены - просто обновляем цель
        final updatedAdditionalGoals = List<AdditionalGoal>.from(
          state.additionalGoals,
        );
        updatedAdditionalGoals[goalIndex] = updatedGoal;

        // Сохраняем изменения
        final updatedUser = _userRepository.user.copyWith(
          additionalGoals: updatedAdditionalGoals,
        );
        _userRepository.user = updatedUser;
        await _userRepository.saveUserToLocal();

        emit(
          state.copyWith(
            isLoading: false,
            additionalGoals: updatedAdditionalGoals,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onMoveToArchive(
    MoveToArchiveEvent event,
    Emitter<GoalState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final completedGoal = event.goal.copyWith(
        isCompleted: true,
        completionDate: DateTime.now(),
        endDate: DateTime.now(), // Добавляем endDate
      );

      final updatedAdditionalGoals = state.additionalGoals
          .where((g) => g.id != event.goal.id)
          .toList();

      final updatedArchivedGoals = [...state.archivedGoals, completedGoal];

      // Сохраняем изменения
      final updatedUser = _userRepository.user.copyWith(
        additionalGoals: updatedAdditionalGoals,
      );
      _userRepository.user = updatedUser;
      await _userRepository.saveUserToLocal();

      // Сохраняем архив
      _userRepository.archivedGoals = updatedArchivedGoals;
      await _userRepository.saveArchivedGoalsToLocal();

      emit(
        state.copyWith(
          isLoading: false,
          additionalGoals: updatedAdditionalGoals,
          archivedGoals: updatedArchivedGoals,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Сброс состояния блока (без emit)
  void reset() {
    Logger.i('GoalBloc: состояние сброшено');
  }
}
