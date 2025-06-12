part of 'auth_bloc.dart';

class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

/// авторизация по email
class AuthEmailEvent extends AuthEvent {
  final String email;
  final String password;
  const AuthEmailEvent({required this.password, required this.email});
}

/// регистрация по email
class RegEmailEvent extends AuthEvent {
  final String email;
  final String password;
  const RegEmailEvent({required this.password, required this.email});
}

/// подтверждение кода
class SendCodeEvent extends AuthEvent {
  final String code;
  const SendCodeEvent({required this.code});
}

/// очистка ошибки
class ClearErrorEvent extends AuthEvent {
  const ClearErrorEvent();
}
