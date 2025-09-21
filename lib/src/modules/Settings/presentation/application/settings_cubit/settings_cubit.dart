import 'package:bloc/bloc.dart';
import 'package:dmvgenie/src/modules/Settings/domain/repository/settings_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

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
    try {
      // TODO: Implement loading settings from SharedPreferences or local storage
      await Future.delayed(
          const Duration(milliseconds: 500)); // Simulate loading

      emit(const SettingsState.loaded(
        isNotificationEnabled: true,
        isAutoPlay: false,
      ));
    } catch (e) {
      emit(SettingsState.error(e.toString()));
    }
  }

  /// Toggle notification
  void toggleNotification(bool isEnabled) {
    if (state is _Loaded) {
      final currentState = state as _Loaded;
      emit(SettingsState.loaded(
        isNotificationEnabled: isEnabled,
        isAutoPlay: currentState.isAutoPlay,
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
      ));
      _saveSettings();
    }
  }

  /// Reset all settings to default
  void resetSettings() {
    emit(const SettingsState.loaded(
      isNotificationEnabled: true,
      isAutoPlay: false,
    ));
    _saveSettings();
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
}
