import 'package:dmvgenie/src/modules/upload/data/model/plan_model.dart';

abstract class PlanRepository {
  /// Lấy danh sách tất cả các gói dịch vụ
  Future<PlanListResponse> getAllPlans({
    required int pageIndex,
    required int pageSize,
  });

  /// Lấy chi tiết một gói dịch vụ
  Future<Plan> getPlanDetail({
    required int planId,
  });

  /// Đăng ký một gói dịch vụ
  Future<RegisterPlanResponse> registerPlan({
    required String planType,
  });
}
