import 'package:injectable/injectable.dart';
import 'package:dmvgenie/src/modules/upload/data/model/plan_model.dart';
import 'package:dmvgenie/src/modules/upload/data/remote/plan_api_service.dart';
import 'package:dmvgenie/src/modules/plan/domain/repository/plan_repository.dart';

@Injectable(as: PlanRepository)
class PlanRepositoryImpl implements PlanRepository {
  final PlanApiService _planApiService;

  PlanRepositoryImpl({required PlanApiService planApiService})
      : _planApiService = planApiService;

  @override
  Future<PlanListResponse> getAllPlans({
    required int pageIndex,
    required int pageSize,
  }) async {
    final response = await _planApiService.getAllPlans(
      pageIndex: pageIndex,
      pageSize: pageSize,
    );
    final pagination = PaginationInfo(
      totalItems: response.pagination.totalItems,
      totalPages: response.pagination.totalPages,
      pageSize: response.pagination.pageSize,
      pageIndex: response.pagination.pageIndex,
    );
    return PlanListResponse(
      data: response.data,
      pagination: pagination,
    );
  }

  @override
  Future<Plan> getPlanDetail({
    required int planId,
  }) async {
    final response = await _planApiService.getPlanDetail(id: planId);
    return response.data;
  }

  @override
  Future<RegisterPlanResponse> registerPlan({
    required String planType,
  }) async {
    final body = {'planType': planType};
    final response = await _planApiService.registerPlan(body: body);
    return response.data;
  }
}
