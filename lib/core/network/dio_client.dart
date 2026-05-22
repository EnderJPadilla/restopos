import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'auth_interceptor.dart';

class ApiClient {
  ApiClient._();

  static Dio? _dio;

  static void init(GoRouter router) {
    _dio ??= Dio(
      BaseOptions(
        baseUrl: 'http://127.0.0.1:3500/api',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptors (orden IMPORTANTE)
    _dio!.interceptors.clear();
    _dio!.interceptors.add(AuthInterceptor(router));
    _dio!.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  static Dio get dio {
    if (_dio == null) {
      throw Exception('ApiClient no inicializado. Llama ApiClient.init(router)');
    }
    return _dio!;
  }
}
