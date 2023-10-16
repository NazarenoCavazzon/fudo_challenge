part of 'login_cubit.dart';

enum LoginStatus {
  initial,
  loading,
  success,
  error,
  badCredentials,
}

class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.initial,
  });

  bool get isInitial => status == LoginStatus.initial;
  bool get isLoading => status == LoginStatus.loading;
  bool get isSuccess => status == LoginStatus.success;
  bool get isError => status == LoginStatus.error;
  bool get isBadCredentials => status == LoginStatus.badCredentials;

  final LoginStatus status;

  LoginState copyWith({
    LoginStatus? status,
  }) {
    return LoginState(
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [
        status,
      ];
}
