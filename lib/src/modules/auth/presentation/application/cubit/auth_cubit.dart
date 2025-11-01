import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/models/register_request.dart';
import '../../../data/models/reset_password_request.dart';
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

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String otpCode,
    required String confirmPassword,
  }) async {
    emit(const AuthState.loading());

    final result = await _authRepository.register(
      request: RegisterRequest(
        email: email,
        password: password,
        name: name,
        phoneNumber: phoneNumber,
        otpCode: otpCode,
        confirmPassword: confirmPassword,
      ),
    );

    result.fold(
      (registerResponse) {
        emit(AuthState.registerSuccess(registerResponse));
      },
      (error) {
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

  Future<void> sendOtp({
    required String email,
    String type = 'REGISTER',
  }) async {
    emit(const AuthState.loadingSendOtp());

    final result = await _authRepository.sendOtp(
      email: email,
      type: type,
    );

    result.fold(
      (sendOtpResponse) {
        emit(AuthState.sendOtpSuccess(sendOtpResponse));
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

  Future<void> resetPassword(
      {required String newPassword,
      required String otpCode,
      required String newPasswordConfirm,
      required String email}) async {
    emit(const AuthState.loading());

    final request = ResetPasswordRequest(
      newPassword: newPassword,
      otpCode: otpCode,
      confirmNewPassword: newPasswordConfirm,
      email: email,
    );

    final result = await _authRepository.resetPassword(request);

    result.fold(
      (resetPasswordResponse) {
        emit(AuthState.resetPasswordSuccess('Reset password successfully'));
      },
      (error) {
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

  Future<void> verify2FA({required String otpCode}) async {
    emit(const AuthState.twoFactorAuthVerifying());

    final result = await _authRepository.verify2FA(otpCode: otpCode);

    result.fold(
      (response) {
        emit(const AuthState.twoFactorAuthVerifiedSuccess(
            '2FA verified successfully'));
      },
      (error) {
        error.maybeWhen(
          (code, message) =>
              emit(AuthState.twoFactorAuthVerifiedFailure(error.message)),
          orElse: () {
            emit(AuthState.twoFactorAuthVerifiedFailure(error.message));
          },
        );
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
