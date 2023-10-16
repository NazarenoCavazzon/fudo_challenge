import 'package:bloc/bloc.dart';
import 'package:data_persistence/data_persistence.dart';
import 'package:equatable/equatable.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({
    required this.dataPersistenceRepository,
  }) : super(const LoginState());

  final DataPersistenceRepository dataPersistenceRepository;

  static const allowedUser = 'challenge@fudo';
  static const allowedPassword = 'password';

  Future<void> login({
    required String username,
    required String password,
  }) async {
    emit(state.copyWith(status: LoginStatus.loading));

    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (username != allowedUser || password != allowedPassword) {
        emit(state.copyWith(status: LoginStatus.badCredentials));
        return;
      }

      await dataPersistenceRepository.setLoggedIn(status: true);

      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      emit(state.copyWith(status: LoginStatus.error));
    }
  }
}
