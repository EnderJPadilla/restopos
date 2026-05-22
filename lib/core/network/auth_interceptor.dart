import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../services/token_service.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widget/session_manager.dart';

class AuthInterceptor extends Interceptor {
  final GoRouter router;
  bool _isRefreshing = false;
  final Dio _dio = Dio();

  AuthInterceptor(this.router);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await TokenService.getAccessToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Solo manejar 401
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Evitar loops infinitos
    if (_isRefreshing) {
      return handler.next(err);
    }

    _isRefreshing = true;

    try {
      final refreshed = await TokenService.refreshToken();

      if (!refreshed) {
        await _forceLogout();
        return handler.next(err);
      }

      // Obtener nuevo token
      final newToken = await TokenService.getAccessToken();

      // Reintentar la petición original
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newToken';

      final cloneReq = await _dio.fetch(opts);

      _isRefreshing = false;
      return handler.resolve(cloneReq);
    } catch (e) {
      await _forceLogout();
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  /// Logout global forzado
  Future<void> _forceLogout() async {
    await TokenService.clear();

    SessionManager().showSessionExpiredDialog(() {
      router.go('/login');
    });
  }
}
