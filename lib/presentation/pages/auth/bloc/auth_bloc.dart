import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/data/models/user.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  Timer? _errorTimer;
  AuthBloc() : super(AuthState.initial()) {
    on<AuthEmailEvent>(_onAuthEmailEvent);
    on<RegEmailEvent>(_onRegEmailEvent);
    on<SendCodeEvent>(_onSendCodeEvent);
    on<ClearErrorEvent>(_onClearErrorEvent);
  }

  UserRepository repo = Get.find<UserRepository>();

  /// авторизация по email
  Future<void> _onAuthEmailEvent(
    AuthEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final answer = await repo.authEmail(
      email: event.email,
      password: event.password,
    );

    if (answer.isEmpty) {
      emit(state.copyWith(user: repo.user, status: AuthStatus.successEnter));
    } else {
      clearErrorWithShow(emit, answer);
    }
  }

  /// регистрация по email
  Future<void> _onRegEmailEvent(
    RegEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final answer = await repo.regEmail(
      email: event.email,
      password: event.password,
    );
    if (answer.isEmpty) {
      emit(state.copyWith(status: AuthStatus.successEnter, email: event.email));
    } else {
      clearErrorWithShow(emit, answer);
    }
  }

  @override
  Future<void> close() {
    _errorTimer?.cancel();
    return super.close();
  }

  /// очистка ошибки
  Future<void> _onClearErrorEvent(
    ClearErrorEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(error: ''));
  }

  /// подтверждение кода
  Future<void> _onSendCodeEvent(
    SendCodeEvent event,
    Emitter<AuthState> emit,
  ) async {
    final answer = await repo.checkCode(email: state.email, code: event.code);
    if (answer.isEmpty) {
      emit(state.copyWith(status: AuthStatus.successEnter));
    }
  }

  /// очистка ошибки и показа ошибки
  Future<void> clearErrorWithShow(Emitter<AuthState> emit, String error) async {
    emit(state.copyWith(error: error, status: AuthStatus.error));
    _errorTimer?.cancel();
    _errorTimer = Timer(const Duration(seconds: 8), () {
      add(const ClearErrorEvent());
    });
  }
}
