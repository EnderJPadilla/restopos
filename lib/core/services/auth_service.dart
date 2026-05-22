import 'package:dio/dio.dart';
import '../network/dio_client.dart';
import 'token_service.dart';

class AuthService {

  static Future<List<dynamic>> validateUser({
    required String userName,
  }) async {
    try {
      final Response response = await ApiClient.dio.post(
        '/auth/validate_user',
        data: {
          'usuario': userName,
        },
      );

      final data = response.data;

      if (response.statusCode != 200 || data == null) {
        return [
          {
            'authenticated': false,
            'message': 'Error: ${response.statusCode}',
          }
        ];
      }

      if (data['authenticated'] != true) {
        return [
          {
            'authenticated': false,
            'message': data['message'] ?? 'Usuario no válido',
          }
        ];
      }

      return data is List ? data : [data];

    } on DioException catch (e) {
      return [
        {
          'authenticated': false,
          'message': e.response?.data ?? e.message,
        }
      ];
    } catch (e) {
      return [
        {
          'authenticated': false,
          'message': e.toString(),
        }
      ];
    }
  }

  static Future<List<dynamic>> login({
    required String usuario,
    required String password,
    required String empresaId,
  }) async {
    try {
      final Response response = await ApiClient.dio.post(
        '/auth/login',
        data: {
          'usuario': usuario,
          'password': password,
          'empresa_id': empresaId,
        },
      );

      final data = response.data;

      if (response.statusCode != 200 || data == null) {
        return [
          {
            'authenticated': false,
            'message': 'Error: ${response.statusCode}',
          }
        ];
      }

      final accessToken =
        data['access_token'] ?? data['accessToken'];
      final refreshToken =
        data['refresh_token'] ?? data['refreshToken'];
      final userId =
        data['usuario']['usuario_id'] ?? data['usuario']['userId'];
      final name =
        data['usuario']['nombre_completo'] ?? data['usuario']['nombre'] ?? usuario;

      if (accessToken == null || accessToken.toString().isEmpty) {
        return [
          {
            'authenticated': false,
            'message': 'Token no recibido',
          }
        ];
      }

      // Guardar sesión
      await TokenService.setAccessToken(accessToken);

      if (refreshToken != null) {
        await TokenService.setRefreshToken(refreshToken);
      }

      await TokenService.setUsuarioId(userId.toString());
      await TokenService.setEmpresaId(empresaId);
      await TokenService.setUsuarioName(usuario);
      await TokenService.setName(name);

      return data is List ? data : [data];

    } on DioException catch (e) {
      return [
        {
          'authenticated': false,
          'message': e.response?.data ?? e.message,
        }
      ];
    } catch (e) {
      return [
        {
          'authenticated': false,
          'message': e.toString(),
        }
      ];
    }
  }

  static Future<void> logout() async {
    try {
      await ApiClient.dio.post(
        '/auth/logout',
        data: {
          'usuario': await TokenService.getUsuarioId(),
          'empresa_id': await TokenService.getEmpresaId(),
          'accessToken': await TokenService.getAccessToken(),
          'refreshToken': await TokenService.getRefreshToken(),
        },
      );
    } catch (_) {
      // Ignorar error del backend
    } finally {
      // Limpieza total de sesión
      await TokenService.clear();
    }
  }
}
