part of 'goal_bloc.dart';

class GoalState extends Equatable {
  final bool isLoading;
  final String? error;
  final UserGoal mainGoal;
  final List<AdditionalGoal> additionalGoals;
  final List<AdditionalGoal> goalTypes;
  final List<AdditionalGoal> archivedGoals; // Добавляем архив

  const GoalState({
    required this.isLoading,
    this.error,
    required this.mainGoal,
    required this.additionalGoals,
    required this.goalTypes,
    required this.archivedGoals, // Добавляем архив
  });

  factory GoalState.initial() => GoalState(
    isLoading: false,
    mainGoal: UserGoal.init(),
    additionalGoals: const [],
    goalTypes: const [],
    archivedGoals: const [], // Инициализируем пустой архив
  );

  GoalState copyWith({
    bool? isLoading,
    String? error,
    UserGoal? mainGoal,
    List<AdditionalGoal>? additionalGoals,
    List<AdditionalGoal>? goalTypes,
    List<AdditionalGoal>? archivedGoals, // Добавляем архив
  }) {
    return GoalState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      mainGoal: mainGoal ?? this.mainGoal,
      additionalGoals: additionalGoals ?? this.additionalGoals,
      goalTypes: goalTypes ?? this.goalTypes,
      archivedGoals: archivedGoals ?? this.archivedGoals, // Добавляем архив
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    error,
    mainGoal,
    additionalGoals,
    goalTypes,
    archivedGoals, // Добавляем архив
  ];
}
