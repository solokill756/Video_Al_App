import 'package:bloc/bloc.dart';
import 'package:dmvgenie/src/core/data/local/storage.dart';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../data/model/user_profile_model.dart';
import '../../../domain/repository/settings_repository.dart';

part 'settings_state.dart';
part 'settings_cubit.freezed.dart';

@Singleton()
class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settingsRepository;
  SettingsCubit(this._settingsRepository)
      : super(const SettingsState.initial());
  UserProfileModel? _user;

  /// Load settings from local storage
  Future<void> loadSettings({bool isReload = false}) async {
    if (isReload) {
      emit(const SettingsState.loading());
      final result = await _settingsRepository.getCurrentUser();
      result.fold((user) {
        _user = user;
        Storage.setUserProfile(_user);
        emit(SettingsState.loaded(
          user: _user!,
        ));
      }, (error) {
        error.maybeWhen(
          (code, message) => emit(SettingsState.error(error.message)),
          orElse: () {
            emit(SettingsState.error(error.message));
          },
        );
      });
    } else {
      if (Storage.userProfile != null) {
        emit(SettingsState.loaded(user: Storage.userProfile!));
      } else {
        emit(SettingsState.error('User not found'));
      }
    }
  }

  /// Reload settings silently (không emit loading state nếu đã có data)
  /// Dùng khi muốn refresh data mà không làm gián đoạn UI
  Future<void> reloadSettingsSilently() async {
    // Lưu state hiện tại để giữ UI
    final currentState = state;
    bool? isNotificationEnabled;
    bool? isAutoPlay;
    String? twoFaLink;
    bool wasLoaded = false;

    // Kiểm tra xem state hiện tại có phải là loaded không
    currentState.maybeWhen(
      loaded: (notif, auto, user, twoFa) {
        wasLoaded = true;
        isNotificationEnabled = notif;
        isAutoPlay = auto;
        twoFaLink = twoFa;
      },
      orElse: () {
        wasLoaded = false;
      },
    );

    final result = await _settingsRepository.getCurrentUser();
    result.fold((user) {
      // Nếu trước đó đã có data, giữ nguyên các settings và chỉ cập nhật user
      if (wasLoaded && isNotificationEnabled != null && isAutoPlay != null) {
        emit(SettingsState.loaded(
          isNotificationEnabled: isNotificationEnabled!,
          isAutoPlay: isAutoPlay!,
          user: user,
          twoFaLink: twoFaLink,
        ));
      } else {
        // Nếu chưa có data, emit loaded state bình thường
        emit(SettingsState.loaded(
          user: user,
        ));
      }
    }, (error) {
      // Nếu có lỗi và trước đó đã có data, giữ nguyên state cũ
      if (wasLoaded) {
        // Không emit error để không làm gián đoạn UI
        print('⚠️ Error reloading settings silently: ${error.message}');
      } else {
        error.maybeWhen(
          (code, message) => emit(SettingsState.error(error.message)),
          orElse: () {
            emit(SettingsState.error(error.message));
          },
        );
      }
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
      loadSettings(isReload: true);
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
      loadSettings(isReload: true);
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
      loadSettings(isReload: true);
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
