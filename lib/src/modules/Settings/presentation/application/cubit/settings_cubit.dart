import 'package:bloc/bloc.dart';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../data/model/user_profile_model.dart';
import '../../../domain/repository/settings_repository.dart';

part 'settings_state.dart';
part 'settings_cubit.freezed.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settingsRepository;
  SettingsCubit(this._settingsRepository)
      : super(const SettingsState.initial());

  /// Load settings from local storage
  Future<void> loadSettings() async {
    emit(const SettingsState.loading());
    final result = await _settingsRepository.getCurrentUser();
    result.fold((user) {
      emit(SettingsState.loaded(
        user: user,
      ));
    }, (error) {
      error.maybeWhen(
        (code, message) => emit(SettingsState.error(error.message)),
        orElse: () {
          emit(SettingsState.error(error.message));
        },
      );
    });
  }

  /// Toggle notification
  void toggleNotification(bool isEnabled) {
    if (state is _Loaded) {
      final currentState = state as _Loaded;
      emit(SettingsState.loaded(
        isNotificationEnabled: isEnabled,
        isAutoPlay: currentState.isAutoPlay,
        user: currentState.user,
      ));
      _saveSettings();
    }
  }

  /// Toggle auto play
  void toggleAutoPlay(bool isAutoPlay) {
    if (state is _Loaded) {
      final currentState = state as _Loaded;
      emit(SettingsState.loaded(
        isNotificationEnabled: currentState.isNotificationEnabled,
        isAutoPlay: isAutoPlay,
        user: currentState.user,
      ));
      _saveSettings();
    }
  }

  /// Private method to save settings
  Future<void> _saveSettings() async {
    // TODO: Implement saving settings to SharedPreferences or local storage
    try {
      await Future.delayed(
          const Duration(milliseconds: 100)); // Simulate saving
      // Save to SharedPreferences here
    } catch (e) {
      emit(SettingsState.error('Failed to save settings: ${e.toString()}'));
    }
  }

  Future<void> logout() async {
    emit(const SettingsState.loading());
    await _settingsRepository.logout();
    emit(const SettingsState.initial());
  }

  Future<void> updateProfile({
    required String name,
    required String phoneNumber,
    String? avatarPath,
  }) async {
    emit(const SettingsState.updatingProfile());
    final result = await _settingsRepository.updateProfile(
      name: name,
      phoneNumber: phoneNumber,
      avatar: avatarPath,
    );
    result.fold((user) {
      emit(SettingsState.updateProfileSuccess(user));
      loadSettings();
    }, (error) {
      error.maybeWhen(
        (code, message) =>
            emit(SettingsState.updatedProfileFailure(error.message)),
        orElse: () {
          emit(SettingsState.updatedProfileFailure(error.message));
        },
      );
    });
  }

  Future<void> uploadAvatar({
    required String filePath,
  }) async {
    emit(const SettingsState.uploadingAvatar());
    final result = await _settingsRepository.uploadAvatar(filePath: filePath);
    result.fold((user) {
      emit(SettingsState.uploadAvatarSuccess('Avatar uploaded successfully'));
      loadSettings();
    }, (error) {
      error.maybeWhen(
        (code, message) =>
            emit(SettingsState.uploadAvatarFailure(error.message)),
        orElse: () {
          emit(SettingsState.uploadAvatarFailure(error.message));
        },
      );
    });
  }

  Future<void> removeAvatar() async {
    emit(const SettingsState.uploadingAvatar());
    final result = await _settingsRepository.removeAvatar();
    result.fold((user) {
      emit(SettingsState.uploadAvatarSuccess('Avatar removed successfully'));
      loadSettings();
    }, (error) {
      error.maybeWhen(
        (code, message) =>
            emit(SettingsState.uploadAvatarFailure(error.message)),
        orElse: () {
          emit(SettingsState.uploadAvatarFailure(error.message));
        },
      );
    });
  }

  Future<void> getLinkFor2FA() async {
    emit(const SettingsState.twoFALoadingLink());
    final result = await _settingsRepository.getLinkFor2FA();
    result.fold((link) {
      emit(SettingsState.twoFALoadedLink(link));
    }, (error) {
      error.maybeWhen(
        (code, message) => emit(SettingsState.twoFAError(error.message, null)),
        orElse: () {
          emit(SettingsState.twoFAError(error.message, null));
        },
      );
    });
  }

  Future<void> enable2FA({required String otpCode, String? previousUri}) async {
    emit(SettingsState.twoFAEnabling(previousUri));
    final result = await _settingsRepository.enable2FA(otpCode: otpCode);
    result.fold((response) {
      emit(SettingsState.twoFASuccess(response.message));

      loadSettings();
    }, (error) {
      error.maybeWhen(
        (code, message) =>
            emit(SettingsState.twoFAError(error.message, previousUri)),
        orElse: () {
          emit(SettingsState.twoFAError(error.message, previousUri));
        },
      );
    });
  }

  Future<void> disable2FA(
      {required String otpCode, String? previousUri}) async {
    emit(const SettingsState.twoFADisabling());
    final result = await _settingsRepository.disable2FA(otpCode: otpCode);
    result.fold((response) {
      emit(SettingsState.twoFASuccess(response.message));
      loadSettings();
    }, (error) {
      error.maybeWhen(
        (code, message) =>
            emit(SettingsState.twoFAError(error.message, previousUri)),
        orElse: () {
          emit(SettingsState.twoFAError(error.message, previousUri));
        },
      );
    });
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    emit(const SettingsState.changingPassword());
    final result = await _settingsRepository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    result.fold((response) {
      emit(SettingsState.changePasswordSuccess(response.message));
    }, (error) {
      error.maybeWhen(
        (code, message) =>
            emit(SettingsState.changePasswordFailure(error.message)),
        orElse: () {
          emit(SettingsState.changePasswordFailure(error.message));
        },
      );
    });
  }
}
