part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final User user;
  final AuthStatus status;
  final String error;
  final bool isReg;
  final String code;

  const AuthState({
    required this.user,
    required this.status,
    required this.error,
    required this.isReg,
    required this.code,
  });

  factory AuthState.initial() => AuthState(
    user: User.initial(),
    status: AuthStatus.initial,
    error: '',
    isReg: false,
    code: '',
  );

  AuthState copyWith({
    User? user,
    AuthStatus? status,
    String? error,
    String? phone,
    bool? isReg,
    String? code,
  }) {
    return AuthState(
      user: user ?? this.user,
      status: status ?? this.status,
      error: error ?? this.error,
      isReg: isReg ?? this.isReg,
      code: code ?? this.code,
    );
  }

  @override
  List<Object?> get props => [user, status, error, isReg, code];
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
