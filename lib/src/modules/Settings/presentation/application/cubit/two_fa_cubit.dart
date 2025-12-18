import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/repository/settings_repository.dart';

part 'two_fa_state.dart';
part 'two_fa_cubit.freezed.dart';

@Singleton()
class TwoFACubit extends Cubit<TwoFAState> {
  final SettingsRepository _settingsRepository;

  TwoFACubit(this._settingsRepository) : super(const TwoFAState.initial());

  /// Lấy QR code link cho 2FA setup
  Future<void> getLinkFor2FA() async {
    emit(const TwoFAState.loadingLink());
    final result = await _settingsRepository.getLinkFor2FA();
    result.fold((link) {
      emit(TwoFAState.loadedLink(link));
    }, (error) {
      error.maybeWhen(
        (code, message) => emit(TwoFAState.error(error.message, null)),
        orElse: () {
          emit(TwoFAState.error(error.message, null));
        },
      );
    });
  }

  /// Enable 2FA với OTP code
  Future<void> enable2FA({required String otpCode}) async {
    // Lưu lại URI trước đó nếu có
    String? previousUri;
    state.maybeWhen(
      loadedLink: (uri) => previousUri = uri,
      orElse: () {},
    );

    emit(TwoFAState.enabling(previousUri));
    final result = await _settingsRepository.enable2FA(otpCode: otpCode);
    result.fold((response) {
      emit(TwoFAState.success(response.message));
    }, (error) {
      error.maybeWhen(
        (code, message) => emit(TwoFAState.error(error.message, previousUri)),
        orElse: () {
          emit(TwoFAState.error(error.message, previousUri));
        },
      );
    });
  }

  /// Disable 2FA với OTP code
  Future<void> disable2FA({required String otpCode}) async {
    // Lưu lại URI trước đó nếu có
    String? previousUri;
    state.maybeWhen(
      loadedLink: (uri) => previousUri = uri,
      orElse: () {},
    );

    emit(const TwoFAState.disabling());
    final result = await _settingsRepository.disable2FA(otpCode: otpCode);
    result.fold((response) {
      emit(TwoFAState.success(response.message));
    }, (error) {
      error.maybeWhen(
        (code, message) => emit(TwoFAState.error(error.message, previousUri)),
        orElse: () {
          emit(TwoFAState.error(error.message, previousUri));
        },
      );
    });
  }

  /// Reset state về initial để profile section không bị ảnh hưởng
  void reset() {
    emit(const TwoFAState.initial());
  }
}
