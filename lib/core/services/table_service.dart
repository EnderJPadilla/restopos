import 'package:dio/dio.dart';
import 'package:restopos/core/services/token_service.dart';
import 'package:restopos/models/table_model.dart';
import '../network/dio_client.dart';

class TableService {
  static final Dio _dio = ApiClient.dio;

  static Future<List<dynamic>> validateTableNumber({
    required int tableNumber,
  }) async {
    try {
      final empresaId = await TokenService.getEmpresaId();
      final Response response = await ApiClient.dio.post(
        '/tables/validar_numero_mesa',
        data: {
          'empresa_id': empresaId,
          'tableNumber': tableNumber,
        },
      );

      final data = response.data;

      if (response.statusCode != 200) {
        throw Exception(
          'Error al validar número de la mesa (${response.statusCode})',
        );
      }

      return data is List ? data : [data];

    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error inesperado al validar número de la mesa: $e');
    }
  }

  static Future<List<dynamic>> validateTableName({
    required String tableName,
  }) async {
    try {
      final empresaId = await TokenService.getEmpresaId();
      final Response response = await ApiClient.dio.post(
        '/tables/validar_nombre_mesa',
        data: {
          'empresa_id': empresaId,
          'tableName': tableName,
        },
      );

      final data = response.data;

      if (response.statusCode != 200) {
        throw Exception(
          'Error al validar nombre de la mesa (${response.statusCode})',
        );
      }

      return data is List ? data : [data];

    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error inesperado al validar nombre de la mesa: $e');
    }
  }

  static Future<List<TableModel>> obtenerMesas() async {
    try {
      final empresaId = await TokenService.getEmpresaId();
      final response = await _dio.post(
        '/tables/listar_mesas',
        data: {
          'empresa_id': empresaId,
        }
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Error al obtener mesas (${response.statusCode})',
        );
      }

      final List mesasJson =
        response.data['mesas'] as List? ?? [];

      print('mesasJson: $mesasJson');
      print('Enviando respuesta mesas.......');

      return mesasJson
        .map((json) => TableModel.fromJson(json))
        .toList();

    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error inesperado al obtener mesas: $e');
    }
  }

  static Future<Map<String, dynamic>> crearMesa(
    Map<String, dynamic> payload,
  ) async {
    try {
      final empresaId = await TokenService.getEmpresaId();
      final response = await _dio.post(
        '/tables/nueva_mesa',
        data: {
          'empresa_id': empresaId,
          'dataTable': payload
        },
      );

      if (response.statusCode != 201 &&
          response.statusCode != 200) {
        throw Exception(
          'No se pudo crear la mesa (${response.statusCode})',
        );
      }
      
      return response.data;

    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error inesperado al crear mesa: $e');
    }
  }

  static Future<Map<String, dynamic>> actualizarMesa(
    Map<String, dynamic> payload,
  ) async {
    try {
      final empresaId = await TokenService.getEmpresaId();
      final response = await _dio.put(
        '/tables/actualizar_mesa',
        data: {
          'empresa_id': empresaId,
          'dataTable': payload
        },
      );

      if (response.statusCode != 201 &&
          response.statusCode != 200) {
        throw Exception(
          'No se pudo actualizar la mesa (${response.statusCode})',
        );
      }

      return response.data;

    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error inesperado al actualizar mesa: $e');
    }
  }

  static Future<String> updateActivo(
    String id, bool activo
  ) async {
    try {
      final empresaId = await TokenService.getEmpresaId();
      final response = await _dio.put(
        '/tables/mesa_activa',
        data: {
          'empresa_id': empresaId,
          'mesa_id': id,
          'activo': activo
        },
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
          'No se pudo actualizar la mesa (${response.statusCode})',
        );
      }

      return response.data["mesa"]["mensaje"] as String;

    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error inesperado al actualizar mesa: $e');
    }

  }

  
  static Future<String> deleteMesa(
    String id
  ) async {
    try {
      final empresaId = await TokenService.getEmpresaId();
      final response = await _dio.delete(
        '/tables/eliminar_mesa',
        data: {
          'empresa_id': empresaId,
          'mesa_id': id,
        },
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
          'No se pudo eliminar la mesa (${response.statusCode})',
        );
      }

      return response.data["mesa"]["mensaje"] as String;

    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error inesperado al eliminar la mesa: $e');
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
