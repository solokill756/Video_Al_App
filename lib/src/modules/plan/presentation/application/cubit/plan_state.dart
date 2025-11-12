import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dmvgenie/src/modules/upload/data/model/plan_model.dart';

part 'plan_state.freezed.dart';

@freezed
class PlanState with _$PlanState {
  const factory PlanState.initial() = Initial;

  const factory PlanState.loading() = Loading;

  const factory PlanState.plansLoaded({
    required List<Plan> plans,
  }) = PlansLoaded;

  const factory PlanState.registering() = Registering;

  const factory PlanState.registerSuccess({
    required String message,
    required String message2,
  }) = RegisterSuccess;

  const factory PlanState.error({required String message}) = Error;
}
