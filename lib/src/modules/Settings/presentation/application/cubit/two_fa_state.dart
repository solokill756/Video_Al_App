part of 'two_fa_cubit.dart';

@freezed
class TwoFAState with _$TwoFAState {
  const factory TwoFAState.initial() = _Initial;
  const factory TwoFAState.loadingLink() = _LoadingLink;
  const factory TwoFAState.loadedLink(String qrCodeUri) = _LoadedLink;
  const factory TwoFAState.enabling(String? previousUri) = _Enabling;
  const factory TwoFAState.disabling() = _Disabling;
  const factory TwoFAState.success(String message) = _Success;
  const factory TwoFAState.error(String message, String? previousUri) = _Error;
}
