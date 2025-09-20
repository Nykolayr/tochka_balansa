import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:tochka_balansa/data/models/gender.dart';
import 'package:tochka_balansa/data/models/health/activity_level.dart';
import 'package:tochka_balansa/data/models/user.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';
import 'package:tochka_balansa/data/repositories/daily_events_repository.dart';
import 'package:tochka_balansa/data/models/health/daily_event.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  Timer? _errorTimer;
  AuthBloc() : super(AuthState.initial()) {
    on<AuthEmailEvent>(_onAuthEmailEvent);
    on<RegEmailEvent>(_onRegEmailEvent);
    on<SendCodeEvent>(_onSendCodeEvent);
    on<ClearErrorEvent>(_onClearErrorEvent);
    on<SaveUserDataEvent>(_onSaveUserDataEvent);
  }

  UserRepository repo = Get.find<UserRepository>();

  /// сохранение данных пользователя
  Future<void> _onSaveUserDataEvent(
    SaveUserDataEvent event,
    Emitter<AuthState> emit,
  ) async {
    await repo.saveUserData(
      event.name,
      event.weight,
      event.height,
      event.birthDate,
      event.gender,
      event.activityLevel, // НОВОЕ поле
    );

    // После сохранения данных пользователя обновляем BMR событие
    try {
      final eventsRepo = Get.find<DailyEventsRepository>();
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      // Удаляем старое BMR событие если есть
      final existingEvents = eventsRepo.getEventsForDate(todayDate);
      final oldBMREvents = existingEvents
          .where((event) => event is BurnedEvent && event.type == EventType.bmr)
          .toList();

      for (final oldEvent in oldBMREvents) {
        await eventsRepo.removeEvent(oldEvent.id);
        Logger.i('Удалено старое BMR событие: ${oldEvent.id}');
      }

      // Добавляем новое BMR событие с правильными данными пользователя
      await eventsRepo.addBMRForNewDay(todayDate);

      Logger.i('BMR событие обновлено после ввода данных пользователя');
    } catch (e) {
      Logger.e(
        'Ошибка обновления BMR события после ввода данных пользователя: $e',
      );
    }
  }

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

  /// Сброс состояния блока (без emit)
  void reset() {
    Logger.i('AuthBloc: состояние сброшено');
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
