import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'food_event.dart';
part 'food_state.dart';

class FoodBloc extends Bloc<FoodEvent, FoodState> {
  FoodBloc() : super(FoodState.initial()) {
    on<FoodEvent>((event, emit) {});
  }
}
