import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:dmvgenie/src/modules/upload/data/model/plan_model.dart';
import 'package:dmvgenie/src/modules/plan/domain/repository/plan_repository.dart';

import 'plan_state.dart';

@injectable
class PlanCubit extends Cubit<PlanState> {
  final PlanRepository planRepository;

  PlanCubit({required this.planRepository}) : super(const PlanState.initial());

  /// Lấy danh sách tất cả các gói dịch vụ
  Future<void> loadPlans({int pageIndex = 1, int pageSize = 10}) async {
    try {
      emit(const PlanState.loading());
      final planListResponse = await planRepository.getAllPlans(
        pageIndex: pageIndex,
        pageSize: pageSize,
      );
      emit(PlanState.plansLoaded(plans: planListResponse.data));
    } catch (e) {
      emit(PlanState.error(message: 'Lỗi tải danh sách gói dịch vụ: $e'));
    }
  }

  /// Lấy chi tiết một gói dịch vụ
  Future<Plan?> getPlanDetail(int planId) async {
    try {
      final plan = await planRepository.getPlanDetail(planId: planId);
      return plan;
    } catch (e) {
      emit(PlanState.error(message: 'Lỗi lấy chi tiết gói dịch vụ: $e'));
      return null;
    }
  }

  /// Đăng ký một gói dịch vụ
  Future<void> registerPlan(String planType) async {
    try {
      emit(const PlanState.registering());
      final registerResponse =
          await planRepository.registerPlan(planType: planType);
      emit(PlanState.registerSuccess(
        message: 'Đăng ký gói dịch vụ thành công!',
        message2: registerResponse.message,
      ));
    } catch (e) {
      emit(PlanState.error(message: 'Lỗi đăng ký gói dịch vụ: $e'));
    }
  }

  /// Reset state về initial
  void reset() {
    emit(const PlanState.initial());
  }
}
