import 'package:dio/dio.dart';

class ApiService {
  // URL de la API en el puerto 3000
  static const String baseUrl = 'http://localhost:3500';

  // Instancia de Dio
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  static Future<List<dynamic>> validatePin(String username, String pin) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {
          'usuario': username,
          'password': pin,
          'empresa': 'e8e06576-1de9-4626-855e-8e822128334f'
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data is List ? data : [data];
      } else {
        List errorData = [{
          "authenticated": false,
          "message": "Error del servidor: ${response.statusCode}"
        }];
        return errorData;
      }
    } on DioException catch (e) {
      String errorMessage;

      if (e.response?.statusCode == 401) {
        errorMessage = "Usuario o contraseña incorrectos";
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = "Tiempo de conexión agotado";
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = "Error de conexión: ${e.message}";
      } else {
        errorMessage = "Error: ${e.message}";
      }

      List errorData = [{
        "authenticated": false,
        "message": errorMessage
      }];
      return errorData;
    } catch (e) {
      List errorData = [{
        "authenticated": false,
        "message": "Error inesperado: $e"
      }];
      return errorData;
    }
  }

}
