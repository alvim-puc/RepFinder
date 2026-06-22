import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/core/errors.dart'; // Ajuste o import
import 'package:provider/core/storage.dart'; // Ajuste o import
import 'package:flutter_dotenv/flutter_dotenv.dart';

// GlobalKey para navegação, necessário para o AuthInterceptor
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Provider do Dio para injeção nos datasources
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  setupDio(dio);
  return dio;
});

void setupDio(Dio dio) {
  final apiBaseUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:3030/api';
  dio.options.baseUrl = apiBaseUrl;
  dio.options.connectTimeout = const Duration(seconds: 5);
  dio.options.receiveTimeout = const Duration(seconds: 3);

  // Cache options
  final cacheOptions = CacheOptions(
    store: MemCacheStore(),
    policy: CachePolicy.request,
    hitCacheOnErrorExcept: [401, 403],
    maxStale: const Duration(days: 7),
  );

  dio.interceptors.addAll([
    DioCacheInterceptor(options: cacheOptions),
    AuthInterceptor(),
    LogInterceptor(requestBody: true, responseBody: true),
  ]);
}

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
    // Trata o deslogar forçado se for 401
    if (err.response?.statusCode == 401) {
      await SecureStorage.clear();
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }

    // Transforma o DioException padrão em um AppException estruturado
    final appException = AppException.fromDioException(err);

    // Rejeita usando o AppException (o Dart aceitará pois ele herda de DioException)
    handler.reject(appException);
  }
}
