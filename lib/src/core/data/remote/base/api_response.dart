import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:result_dart/result_dart.dart';

import 'api_error.dart';
import 'meta_response.dart';

part 'api_response.freezed.dart';
part 'api_response.g.dart';

abstract class GenericObject<T> {
  T Function(Map<String, dynamic>) fromJsonT;

  GenericObject(this.fromJsonT);

  T genericObject(dynamic data) {
    return fromJsonT(data);
  }
}

class ResponseWrapper<T> extends GenericObject<T> {
  late T response;

  ResponseWrapper(super.fromJsonT);

  factory ResponseWrapper.init(
      {required T Function(Map<String, dynamic>) fromJsonT,
      required dynamic data}) {
    final wrapper = ResponseWrapper<T>(fromJsonT);
    wrapper.response = wrapper.genericObject(data);
    return wrapper;
  }
}

@Freezed(genericArgumentFactories: true)
class StatusApiResponse with _$StatusApiResponse {
  const factory StatusApiResponse({
    required String message,
    required int? statusCode,
  }) = _StatusApiResponse;

  factory StatusApiResponse.fromJson(Map<String, dynamic> json) =>
      _$StatusApiResponseFromJson(json);
}

@Freezed(genericArgumentFactories: true)
class SingleApiResponse<T> with _$SingleApiResponse<T> {
  const factory SingleApiResponse(T data) = _SingleApiResponse;

  factory SingleApiResponse.fromJson(
          Map<String, dynamic> json, T Function(Object?) fromJsonT) =>
      _$SingleApiResponseFromJson(json, fromJsonT);
}

@Freezed(genericArgumentFactories: true)
class ListApiResponse<T> with _$ListApiResponse<T> {
  const factory ListApiResponse(List<T> data) = _ListApiResponse;

  factory ListApiResponse.fromJson(
          Map<String, dynamic> json, T Function(Object?) fromJsonT) =>
      _$ListApiResponseFromJson(json, fromJsonT);
}

@Freezed(genericArgumentFactories: true)
class PagingApiResponse<T> with _$PagingApiResponse<T> {
  const factory PagingApiResponse({
    required List<T> data,
    required MetaResponse meta,
  }) = _PagingApiResponse;

  factory PagingApiResponse.fromJson(
          Map<String, dynamic> json, T Function(Object?) fromJsonT) =>
      _$PagingApiResponseFromJson(
          {
            'data': json['data']['data'],
            'meta': json['data']['meta'],
          },
          // json['data'],
          fromJsonT);
}

@Freezed(genericArgumentFactories: true)
class PaginatedApiResponse<T> with _$PaginatedApiResponse<T> {
  const factory PaginatedApiResponse({
    required List<T> data,
    required PaginationResponse pagination,
  }) = _PaginatedApiResponse;

  factory PaginatedApiResponse.fromJson(
          Map<String, dynamic> json, T Function(Object?) fromJsonT) =>
      _$PaginatedApiResponseFromJson(json, fromJsonT);
}

@Freezed(genericArgumentFactories: true)
class PaginationResponse with _$PaginationResponse {
  const factory PaginationResponse({
    required int totalPages,
    required int totalItems,
    required int pageSize,
    required int pageIndex,
  }) = _PaginationResponse;

  factory PaginationResponse.fromJson(Map<String, dynamic> json) =>
      _$PaginationResponseFromJson(json);
}

extension FoldedSingleApiResponse<T extends Object>
    on Result<SingleApiResponse<T>, ApiError> {
  Result<T, ApiError> get folded => fold(
        (success) => Success(success.data),
        (failure) => Failure(failure),
      );
}

extension FoldedListApiResponse<T extends Object>
    on Result<ListApiResponse<T>, ApiError> {
  Result<List<T>, ApiError> get folded => fold(
        (success) => Success(success.data),
        (failure) => Failure(failure),
      );
}

@Freezed(genericArgumentFactories: true)
class PlanListApiResponse<T> with _$PlanListApiResponse<T> {
  const factory PlanListApiResponse({
    required List<T> data,
    required PlanPaginationData pagination,
  }) = _PlanListApiResponse;

  factory PlanListApiResponse.fromJson(
          Map<String, dynamic> json, T Function(Object?) fromJsonT) =>
      _$PlanListApiResponseFromJson(json, fromJsonT);
}

@freezed
class PlanPaginationData with _$PlanPaginationData {
  const factory PlanPaginationData({
    required int totalPages,
    required int totalItems,
    required int pageSize,
    required int pageIndex,
  }) = _PlanPaginationData;

  factory PlanPaginationData.fromJson(Map<String, dynamic> json) =>
      _$PlanPaginationDataFromJson(json);
}
