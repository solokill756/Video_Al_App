import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/data/remote/base/api_response.dart';
import '../model/plan_model.dart';

part 'plan_api_service.g.dart';

@injectable
@RestApi()
abstract class PlanApiService {
  @factoryMethod
  factory PlanApiService(Dio dio, {@Named('baseUrl') String? baseUrl}) =
      _PlanApiService;

  // Get All Plans
  @GET('/plans')
  Future<PlanListApiResponse<Plan>> getAllPlans({
    @Query('pageIndex') required int pageIndex,
    @Query('pageSize') required int pageSize,
  });

  // Get Plan Detail
  @GET('/plans/{id}')
  Future<SingleApiResponse<Plan>> getPlanDetail({
    @Path('id') required int id,
  });

  // Register Plan
  @POST('/plans/register')
  Future<SingleApiResponse<RegisterPlanResponse>> registerPlan({
    @Body() required Map<String, String> body,
  });
}
