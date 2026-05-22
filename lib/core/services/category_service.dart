import 'package:dio/dio.dart';
import 'package:restopos/core/services/token_service.dart';
import 'package:restopos/models/category_model.dart';
import '../network/dio_client.dart';

class CategoryService {
  static final Dio _dio = ApiClient.dio;

  static Future<List<dynamic>> validateCategoryName({
    required String categoryName,
  }) async {
    try {
      final empresaId = await TokenService.getEmpresaId();
      final Response response = await ApiClient.dio.post(
        '/categorias/validar_nombre_categoria',
        data: {
          'empresa_id': empresaId,
          'categoryName': categoryName,
        },
      );

      final data = response.data;

      if (response.statusCode != 200) {
        throw Exception(
          'Error al validar nombre de la categoria (${response.statusCode})',
        );
      }

      return data is List ? data : [data];

    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error inesperado al validar nombre de la categoria: $e');
    }
  }

  static Future<List<Category>> obtenerCategorias() async {
    try {
      final empresaId = await TokenService.getEmpresaId();
      final response = await _dio.post(
        '/categorias/listar_categorias',
        data: {
          'empresa_id': empresaId,
        }
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Error al obtener categorias (${response.statusCode})',
        );
      }

      final List categoriasJson =
        response.data['categorias'] as List? ?? [];

      // print('productosJson: $productosJson');
      print('Enviando respuesta categorias.......');

      return categoriasJson
        .map((json) => Category.fromJson(json))
        .toList();

    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error inesperado al obtener categorias: $e');
    }
  }

  static Future<Map<String, dynamic>> crearCategoria(
    Map<String, dynamic> payload,
  ) async {
    try {
      final empresaId = await TokenService.getEmpresaId();
      final response = await _dio.post(
        '/categorias/nueva_categoria',
        data: {
          'empresa_id': empresaId,
          'dataCategoria': payload
        },
      );

      if (response.statusCode != 201 &&
          response.statusCode != 200) {
        throw Exception(
          'No se pudo crear el categoria (${response.statusCode})',
        );
      }
      
      return response.data;

    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error inesperado al crear categoria: $e');
    }
  }

  static Future<Map<String, dynamic>> actualizarCategoria(
    Map<String, dynamic> payload,
  ) async {
    try {
      final empresaId = await TokenService.getEmpresaId();
      final response = await _dio.put(
        '/categorias/actualizar_categoria',
        data: {
          'empresa_id': empresaId,
          'dataCategoria': payload
        },
      );

      if (response.statusCode != 201 &&
          response.statusCode != 200) {
        throw Exception(
          'No se pudo actualizar el categoria (${response.statusCode})',
        );
      }

      return response.data;

    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error inesperado al actualizar categoria: $e');
    }
  }

  static Future<String> updateActivo(
    String id, bool activo
  ) async {
    try {
      final empresaId = await TokenService.getEmpresaId();
      final response = await _dio.put(
        '/categorias/categoria_activa',
        data: {
          'empresa_id': empresaId,
          'categoria_id': id,
          'activo': activo
        },
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
          'No se pudo actualizar la categoria (${response.statusCode})',
        );
      }

      return response.data["categoria"]["mensaje"] as String;

    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error inesperado al crear categoria: $e');
    }

  }

  
  static Future<String> deleteCategoria(
    String id
  ) async {
    try {
      final empresaId = await TokenService.getEmpresaId();
      final response = await _dio.delete(
        '/categorias/eliminar_categoria',
        data: {
          'empresa_id': empresaId,
          'categoria_id': id,
        },
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
          'No se pudo eliminar la categoria (${response.statusCode})',
        );
      }

      return response.data["categoria"]["mensaje"] as String;

    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error inesperado al eliminar la categoria: $e');
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
