part of 'food_bloc.dart';

class FoodState extends Equatable {
  final bool isLoading;
  final String error;
  final bool isListChange;

  const FoodState({
    required this.isLoading,
    required this.error,
    required this.isListChange,
  });

  FoodState copyWith({bool? isLoading, String? error, bool? isListChange}) {
    return FoodState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isListChange: isListChange ?? this.isListChange,
    );
  }

  factory FoodState.initial() =>
      FoodState(isLoading: false, error: '', isListChange: false);

  @override
  List<Object?> get props => [isLoading, error, isListChange];
}
