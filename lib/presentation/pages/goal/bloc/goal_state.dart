part of 'goal_bloc.dart';

class GoalState extends Equatable {
  final bool isLoading;
  final String error;
  final bool isListChange;
  final UserGoal mainGoal;
  final List<AdditionalGoal> additionalGoals;
  final List<AdditionalGoal> goalTypes; // Добавляем типы целей

  const GoalState({
    required this.isLoading,
    required this.error,
    required this.isListChange,
    required this.mainGoal,
    required this.additionalGoals,
    required this.goalTypes,
  });

  GoalState copyWith({
    bool? isLoading,
    String? error,
    UserGoal? mainGoal,
    List<AdditionalGoal>? additionalGoals,
    List<AdditionalGoal>? goalTypes,
  }) {
    final shouldToggleList = additionalGoals != null || mainGoal != null || goalTypes != null;
    return GoalState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isListChange: shouldToggleList ? !isListChange : isListChange,
      mainGoal: mainGoal ?? this.mainGoal,
      additionalGoals: additionalGoals ?? this.additionalGoals,
      goalTypes: goalTypes ?? this.goalTypes,
    );
  }

  factory GoalState.initial() => GoalState(
    isLoading: false,
    error: '',
    isListChange: false,
    mainGoal: Get.find<UserRepository>().user.mainGoal,
    additionalGoals: Get.find<UserRepository>().user.additionalGoals,
    goalTypes: [], // Будет загружено через блок
  );

  @override
  List<Object?> get props => [
    isLoading,
    error,
    isListChange,
    mainGoal,
    additionalGoals,
    goalTypes,
  ];
}
