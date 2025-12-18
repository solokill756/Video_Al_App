part of 'settings_cubit.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState.initial() = _Initial;
  const factory SettingsState.loading() = _Loading;
  const factory SettingsState.loaded(
      {@Default(true) bool isNotificationEnabled,
      @Default(false) bool isAutoPlay,
      required UserProfileModel user,
      String? twoFaLink}) = _Loaded;
  const factory SettingsState.error(String message) = _Error;
  const factory SettingsState.updateProfileSuccess(UserProfileModel user) =
      _UpdateProfileSuccess;
  const factory SettingsState.updatedProfileFailure(String message) =
      _UpdateProfileFailure;
  const factory SettingsState.updatingProfile() = _UpdatingProfile;
  const factory SettingsState.uploadAvatarSuccess(String message) =
      _UploadAvatarSuccess;
  const factory SettingsState.uploadingAvatar() = _UploadingAvatar;
  const factory SettingsState.uploadAvatarFailure(String message) =
      _UploadAvatarFailure;
  const factory SettingsState.changingPassword() = ChangingPassword;
  const factory SettingsState.changePasswordSuccess(String message) =
      ChangePasswordSuccess;
  const factory SettingsState.changePasswordFailure(String message) =
      ChangePasswordFailure;
}
