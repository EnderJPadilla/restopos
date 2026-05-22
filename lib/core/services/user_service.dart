import 'package:dio/dio.dart';
import 'package:restopos/core/services/token_service.dart';
import 'package:restopos/models/usuario_model.dart';
import '../network/dio_client.dart';

class UserService {
  static final Dio _dio = ApiClient.dio;

  static Future<List<dynamic>> validateUserName({
    required String userName,
  }) async {
    try {
      final empresaId = await TokenService.getEmpresaId();
      final Response response = await ApiClient.dio.post(
        '/usuarios/validar_nombre_usuario',
        data: {
          'empresa_id': empresaId,
          'userName': userName,
        },
      );

      final data = response.data;

      if (response.statusCode != 200) {
        throw Exception(
          'Error al validar nombre del usuario (${response.statusCode})',
        );
      }

      return data is List ? data : [data];

    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error inesperado al validar nombre del usuario: $e');
    }
  }

  static Future<List<Usuario>> obtenerUsuarios() async {
    try {
      final empresaId = await TokenService.getEmpresaId();
      final response = await _dio.post(
        '/usuarios/listar_usuarios',
        data: {
          'empresa_id': empresaId,
        }
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Error al obtener usuarios (${response.statusCode})',
        );
      }

      final List usuariosJson =
        response.data['usuarios'] as List? ?? [];

      // print('usuariosJson: $usuariosJson');
      print('Enviando respuesta usuarios.......');
      // print('Usuarios obtenidos: ${usuariosJson}');

      return usuariosJson
        .map((json) => Usuario.fromJson(json))
        .toList();

    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error inesperado al obtener usuarios: $e');
    }
  }

  static Future<dynamic> crearUsuario(
    Map<String, dynamic> payload,
  ) async {
    try {
      final empresaId = await TokenService.getEmpresaId();
      final response = await _dio.post(
        '/usuarios/nuevo_usuario',
        data: {
          'empresa_id': empresaId,
          'dataUsuario': payload
        },
      );

      if (response.statusCode != 201 &&
          response.statusCode != 200) {
        throw Exception(
          'No se pudo crear el usuario (${response.statusCode})',
        );
      }

      return response.data;

    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error inesperado al crear usuario: $e');
    }
  }

  static Future<String> updateActivo(
    String empleadoId, String usuarioId, bool activo
  ) async {
    try {
      final empresaId = await TokenService.getEmpresaId();
      final response = await _dio.put(
        '/usuarios/usuario_activo',
        data: {
          'empresa_id': empresaId,
          'empleado_id': empleadoId,
          'usuario_id': usuarioId,
          'activo': activo
        },
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
          'No se pudo actualizar el usuario (${response.statusCode})',
        );
      }

      return response.data["usuario"]["mensaje"] as String;

    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error inesperado al actualizar usuario: $e');
    }

  }

  static Future<dynamic> actualizarUsuario(
    Map<String, dynamic> payload,
  ) async {
    try {
      final empresaId = await TokenService.getEmpresaId();
      final response = await _dio.put(
        '/usuarios/actualizar_usuario',
        data: {
          'empresa_id': empresaId,
          'dataUsuario': payload
        },
      );

      if (response.statusCode != 201 &&
          response.statusCode != 200) {
        throw Exception(
          'No se pudo actualizar el usuario (${response.statusCode})',
        );
      }

      return response.data;

    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error inesperado al actualizar usuario: $e');
    }
  }

  // static Future<String> updateDisponible(
  //   String id, bool disponible
  // ) async {
  //   try {
  //     final empresaId = await TokenService.getEmpresaId();
  //     final response = await _dio.put(
  //       '/productos/producto_disponible',
  //       data: {
  //         'empresa_id': empresaId,
  //         'producto_id': id,
  //         'disponible': disponible
  //       },
  //     );

  //     if (response.statusCode != 201 && response.statusCode != 200) {
  //       throw Exception(
  //         'No se pudo actualizar el producto (${response.statusCode})',
  //       );
  //     }

  //     return response.data["producto"]["mensaje"] as String;

  //   } on DioException catch (e) {
  //     throw _handleDioError(e);
  //   } catch (e) {
  //     throw Exception('Error inesperado al crear producto: $e');
  //   }

  // }

  
  static Future<String> deleteUsuario(
    String id
  ) async {
    try {
      final empresaId = await TokenService.getEmpresaId();
      final response = await _dio.delete(
        '/usuarios/eliminar_usuario',
        data: {
          'empresa_id': empresaId,
          'usuario_id': id,
        },
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
          'No se pudo eliminar el usuario (${response.statusCode})',
        );
      }

      return response.data["usuario"]["mensaje"] as String;

    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error inesperado al eliminar usuario: $e');
    }

  }
  
  // MANEJO DE ERRORES
  static Exception _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;

      if (data is Map && data.containsKey('message')) {
        return Exception(data['message']);
      }

      return Exception(
        'Error del servidor (${e.response?.statusCode})',
      );
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Tiempo de espera agotado');
    }

    if (e.type == DioExceptionType.connectionError) {
      return Exception('No hay conexión con el servidor');
    }

    return Exception(e.message ?? 'Error de red');
  }


}
