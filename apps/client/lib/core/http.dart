import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/core/errors.dart';
import 'package:client/core/storage.dart';

// GlobalKey para navegação, necessário para o AuthInterceptor
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Provider do Dio para injeção nos datasources
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  setupDio(dio);
  return dio;
});

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await SecureStorage.clear();
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }

    String errorMessage = 'Erro inesperado';
    int statusCode = err.response?.statusCode ?? -1;

    switch (statusCode) {
      case 400:
        errorMessage = 'Dados inválidos';
        break;
      case 403:
        errorMessage = 'Sem permissão';
        break;
      case 404:
        errorMessage = 'Não encontrado';
        break;
      case 409:
        final data = err.response?.data;
        errorMessage =
            'Conflito: ${data is Map ? data['error'] ?? 'conflito' : 'conflito'}';
        break;
      default:
        if (err.type == DioExceptionType.connectionError) {
          errorMessage = 'Sem conexão com a internet';
        } else {
          final data = err.response?.data;
          if (data is Map && data.containsKey('message')) {
            errorMessage = data['message'];
          }
        }
        break;
    }

    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        error: AppException(errorMessage, statusCode),
        response: err.response,
      ),
    );
  }
}

void setupDio(Dio dio) {
  // Para emulador Android: http://10.0.2.2:3030/api
  // Para iOS simulator / web: http://localhost:3030/api
  // Para produção: https://api.repfinder.com/api
  // const String apiBaseUrl = 'http://10.0.2.2:3030/api';
  const String apiBaseUrl = 'http://localhost:3030/api';

  dio.options.baseUrl = apiBaseUrl;
  dio.options.connectTimeout = const Duration(seconds: 10);
  dio.options.receiveTimeout = const Duration(seconds: 10);

  final cacheOptions = CacheOptions(
    store: MemCacheStore(),
    policy: CachePolicy.request,
    hitCacheOnErrorExcept: [401, 403],
    maxStale: const Duration(hours: 1),
  );

  dio.interceptors.addAll([
    DioCacheInterceptor(options: cacheOptions),
    AuthInterceptor(),
  ]);
}
