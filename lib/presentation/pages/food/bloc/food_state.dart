part of 'food_bloc.dart';

sealed class FoodState extends Equatable {
  const FoodState();
  
  @override
  List<Object> get props => [];
}

final class FoodInitial extends FoodState {}
