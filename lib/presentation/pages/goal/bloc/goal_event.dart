part of 'goal_bloc.dart';

sealed class GoalEvent extends Equatable {
  const GoalEvent();

  @override
  List<Object> get props => [];
}

class LoadGoalsEvent extends GoalEvent {
  const LoadGoalsEvent();
}

class LoadGoalTypesEvent extends GoalEvent {
  const LoadGoalTypesEvent();
}

class SetMainGoalEvent extends GoalEvent {
  final UserGoal goal;
  const SetMainGoalEvent(this.goal);

  @override
  List<Object> get props => [goal];
}

class AddAdditionalGoalEvent extends GoalEvent {
  final AdditionalGoal goal;
  const AddAdditionalGoalEvent(this.goal);

  @override
  List<Object> get props => [goal];
}

class RemoveAdditionalGoalEvent extends GoalEvent {
  final String goalId;
  const RemoveAdditionalGoalEvent(this.goalId);

  @override
  List<Object> get props => [goalId];
}

class UpdateAdditionalGoalEvent extends GoalEvent {
  final AdditionalGoal goal;
  const UpdateAdditionalGoalEvent(this.goal);

  @override
  List<Object> get props => [goal];
}

class AddGoalTemplateEvent extends GoalEvent {
  final AdditionalGoal goal;

  const AddGoalTemplateEvent(this.goal);

  @override
  List<Object> get props => [goal];
}
