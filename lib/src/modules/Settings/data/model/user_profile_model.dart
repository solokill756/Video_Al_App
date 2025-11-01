import 'package:freezed_annotation/freezed_annotation.dart';
part 'user_profile_model.freezed.dart';
part 'user_profile_model.g.dart';

@freezed
class UserProfileModel with _$UserProfileModel {
  const factory UserProfileModel({
    required int id,
    required String name,
    required String email,
    required bool isEnable2FA,
    required String phoneNumber,
    String? avatar,
    PlanModel? plan,
  }) = _UserProfileModel;
  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);
}

@freezed
class PlanModel with _$PlanModel {
  const factory PlanModel({
    required int id,
    required String planType,
  }) = _PlanModel;
  factory PlanModel.fromJson(Map<String, dynamic> json) =>
      _$PlanModelFromJson(json);
}
