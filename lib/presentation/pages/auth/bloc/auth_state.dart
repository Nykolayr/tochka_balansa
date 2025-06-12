part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final User user;
  final AuthStatus status;
  final String error;
  final bool isReg;
  final String code;
  final String email;

  const AuthState({
    required this.user,
    required this.status,
    required this.error,
    required this.isReg,
    required this.code,
    required this.email,
  });

  factory AuthState.initial() => AuthState(
    user: User.initial(),
    status: AuthStatus.initial,
    error: '',
    isReg: false,
    code: '',
    email: '',
  );

  AuthState copyWith({
    User? user,
    AuthStatus? status,
    String? error,
    String? phone,
    bool? isReg,
    String? code,
    String? email,
  }) {
    return AuthState(
      user: user ?? this.user,
      status: status ?? this.status,
      error: error ?? this.error,
      isReg: isReg ?? this.isReg,
      code: code ?? this.code,
      email: email ?? this.email,
    );
  }

  @override
  List<Object?> get props => [user, status, error, isReg, code, email];
}

enum AuthStatus {
  initial,
  loading,
  successEnter,
  successRegister,
  successCode,
  successAccept,
  error;

  bool get isSuccessEnter => this == AuthStatus.successEnter;
  bool get isSuccessRegister => this == AuthStatus.successRegister;
  bool get isSuccessCode => this == AuthStatus.successCode;
  bool get isSuccessAccept => this == AuthStatus.successAccept;
  bool get isError => this == AuthStatus.error;
  bool get isLoading => this == AuthStatus.loading;
  bool get isInitial => this == AuthStatus.initial;
}
