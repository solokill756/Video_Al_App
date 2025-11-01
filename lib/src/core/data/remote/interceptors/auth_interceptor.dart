import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../common/utils/getit_utils.dart';
import '../../../../modules/app/app_router.dart';
import '../../local/storage.dart';

/// Auth interceptor to handle authentication headers and token refresh
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final List<String> _excludedPaths;

  AuthInterceptor(
    this._dio, {
    List<String> excludedPaths = const [],
  }) : _excludedPaths = excludedPaths;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip adding auth header for excluded paths (like login, register)
    if (_isExcludedPath(options.path)) {
      return handler.next(options);
    }

    try {
      final accessToken = await Storage.accessToken;

      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers[HttpHeaders.authorizationHeader] =
            'Bearer $accessToken';
      }
    } catch (e) {
      // If unable to get token, continue without authentication
      print('AuthInterceptor: Failed to get access token: $e');
    }

    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized error for token refresh
    if (err.response?.statusCode == 401) {
      try {
        final refreshed = await _refreshToken();

        if (refreshed) {
          // Retry the original request with new token
          final response = await _retryRequest(err.requestOptions);
          return handler.resolve(response);
        } else {
          // Refresh failed, clear tokens and redirect to login
          await _clearTokensAndRedirectToLogin();
        }
      } catch (e) {
        print('AuthInterceptor: Token refresh failed: $e');
        await _clearTokensAndRedirectToLogin();
      }
    }

    handler.next(err);
  }

  /// Check if the request path should be excluded from authentication
  bool _isExcludedPath(String path) {
    return _excludedPaths.any((excludedPath) => path.contains(excludedPath));
  }

  /// Attempt to refresh the access token using refresh token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await Storage.refreshToken;

      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      // Create a new Dio instance to avoid interceptor loops
      final dio = Dio();

      final response = await dio.post(
        '/auth/refresh', // Replace with your refresh endpoint
        data: {
          'refresh_token': refreshToken,
        },
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final newAccessToken = data['access_token'] as String?;
        final newRefreshToken = data['refresh_token'] as String?;

        if (newAccessToken != null) {
          await Storage.setAccessToken(newAccessToken);

          // Update refresh token if provided
          if (newRefreshToken != null) {
            await Storage.setRefreshToken(newRefreshToken);
          }

          return true;
        }
      }
    } catch (e) {
      print('AuthInterceptor: Refresh token request failed: $e');
    }

    return false;
  }

  /// Retry the original request with new access token
  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final accessToken = await Storage.accessToken;

    if (accessToken != null) {
      requestOptions.headers[HttpHeaders.authorizationHeader] =
          'Bearer $accessToken';
    }

    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
        responseType: requestOptions.responseType,
        contentType: requestOptions.contentType,
        receiveTimeout: requestOptions.receiveTimeout,
        sendTimeout: requestOptions.sendTimeout,
        extra: requestOptions.extra,
      ),
    );
  }

  /// Clear tokens and handle logout logic
  Future<void> _clearTokensAndRedirectToLogin() async {
    await Storage.removeAccessToken();
    await Storage.removeRefreshToken();

    final router = getIt<AppRouter>();
    router.replaceAll([const LoginRoute()]);
    print('AuthInterceptor: Tokens cleared, should redirect to login');
  }
}

/// Configuration class for AuthInterceptor
class AuthInterceptorConfig {
  final String refreshEndpoint;
  final List<String> excludedPaths;
  final Duration? timeout;
  final Map<String, String>? additionalHeaders;

  const AuthInterceptorConfig({
    this.refreshEndpoint = '/auth/refresh',
    this.excludedPaths = const [
      '/auth/login',
      '/auth/register',
      '/auth/refresh'
    ],
    this.timeout,
    this.additionalHeaders,
  });
}

/// Enhanced AuthInterceptor with configuration
class ConfigurableAuthInterceptor extends Interceptor {
  final Dio _dio;
  final AuthInterceptorConfig _config;

  ConfigurableAuthInterceptor(
    this._dio,
    this._config,
  );

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip adding auth header for excluded paths
    if (_isExcludedPath(options.path)) {
      return handler.next(options);
    }

    try {
      final accessToken = await Storage.accessToken;

      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers[HttpHeaders.authorizationHeader] =
            'Bearer $accessToken';
      }

      // Add additional headers if configured
      if (_config.additionalHeaders != null) {
        options.headers.addAll(_config.additionalHeaders!);
      }
    } catch (e) {
      print('ConfigurableAuthInterceptor: Failed to get access token: $e');
    }

    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      try {
        final refreshed = await _refreshToken();

        if (refreshed) {
          final response = await _retryRequest(err.requestOptions);
          return handler.resolve(response);
        } else {
          await _clearTokensAndRedirectToLogin();
        }
      } catch (e) {
        print('ConfigurableAuthInterceptor: Token refresh failed: $e');
        await _clearTokensAndRedirectToLogin();
      }
    }

    handler.next(err);
  }

  bool _isExcludedPath(String path) {
    return _config.excludedPaths
        .any((excludedPath) => path.contains(excludedPath));
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await Storage.refreshToken;

      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final dio = Dio();

      if (_config.timeout != null) {
        dio.options.connectTimeout = _config.timeout;
        dio.options.receiveTimeout = _config.timeout;
      }

      final response = await dio.post(
        _config.refreshEndpoint,
        data: {
          'refresh_token': refreshToken,
        },
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            ...?_config.additionalHeaders,
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final newAccessToken = data['access_token'] as String?;
        final newRefreshToken = data['refresh_token'] as String?;

        if (newAccessToken != null) {
          await Storage.setAccessToken(newAccessToken);

          if (newRefreshToken != null) {
            await Storage.setRefreshToken(newRefreshToken);
          }

          return true;
        }
      }
    } catch (e) {
      print('ConfigurableAuthInterceptor: Refresh token request failed: $e');
    }

    return false;
  }

  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final accessToken = await Storage.accessToken;

    if (accessToken != null) {
      requestOptions.headers[HttpHeaders.authorizationHeader] =
          'Bearer $accessToken';
    }

    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
        responseType: requestOptions.responseType,
        contentType: requestOptions.contentType,
        receiveTimeout: requestOptions.receiveTimeout,
        sendTimeout: requestOptions.sendTimeout,
        extra: requestOptions.extra,
      ),
    );
  }

  Future<void> _clearTokensAndRedirectToLogin() async {
    await Storage.removeAccessToken();
    await Storage.removeRefreshToken();

    // TODO: Implement navigation to login
    print(
        'ConfigurableAuthInterceptor: Tokens cleared, should redirect to login');
  }
}
