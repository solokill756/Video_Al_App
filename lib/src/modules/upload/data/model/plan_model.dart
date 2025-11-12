import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan_model.freezed.dart';
part 'plan_model.g.dart';

@freezed
class Plan with _$Plan {
  const factory Plan({
    required int id,
    required String planType,
    required String name,
    required String description,
    required double price,
    int? durationInDays,
    required Map<String, dynamic> features,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Plan;

  factory Plan.fromJson(Map<String, dynamic> json) => _$PlanFromJson(json);
}

@freezed
class PlanListResponse with _$PlanListResponse {
  const factory PlanListResponse({
    required List<Plan> data,
    required PaginationInfo pagination,
  }) = _PlanListResponse;

  factory PlanListResponse.fromJson(Map<String, dynamic> json) =>
      _$PlanListResponseFromJson(json);
}

@freezed
class PaginationInfo with _$PaginationInfo {
  const factory PaginationInfo({
    required int totalItems,
    required int totalPages,
    required int pageSize,
    required int pageIndex,
  }) = _PaginationInfo;

  factory PaginationInfo.fromJson(Map<String, dynamic> json) =>
      _$PaginationInfoFromJson(json);
}

@freezed
class RegisterPlanResponse with _$RegisterPlanResponse {
  const factory RegisterPlanResponse({
    required String message,
    required Map<String, dynamic>? subscription,
  }) = _RegisterPlanResponse;

  factory RegisterPlanResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterPlanResponseFromJson(json);
}
