import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/repository/auth_repository.dart';
import 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(const AuthState.initial());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthState.loading());

    final result = await _authRepository.login(
      email: email,
      password: password,
    );

    result.fold(
      (loginResponse) {
        emit(AuthState.loginSuccess(loginResponse));
      },
      (error) {
        // Sử dụng pattern matching để check validation error
        error.maybeWhen(
          (code, message) => emit(AuthState.error(error.message)),
          validation: (statusCode, errors) {
            emit(AuthState.validationError(error));
          },
          orElse: () {
            emit(AuthState.error(error.message));
          },
        );
      },
    );
  }

  Future<void> refreshToken() async {
    final result = await _authRepository.refreshToken();

    result.fold(
      (loginResponse) {
        emit(AuthState.loginSuccess(loginResponse));
      },
      (error) {
        emit(AuthState.error(error.message));
      },
    );
  }

  void clearError() {
    emit(const AuthState.initial());
  }

  void reset() {
    emit(const AuthState.initial());
  }
}
