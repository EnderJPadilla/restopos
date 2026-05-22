import 'package:dio/dio.dart';
import 'package:restopos/core/services/token_service.dart';
import 'package:restopos/models/product_model.dart';
import '../network/dio_client.dart';

class ProductService {
  static final Dio _dio = ApiClient.dio;

  static Future<List<Producto>> obtenerProductos() async {
    try {
      final empresaId = await TokenService.getEmpresaId();
      final response = await _dio.post(
        '/productos/listar_productos',
        data: {
          'empresa_id': empresaId,
        }
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Error al obtener productos (${response.statusCode})',
        );
      }

      final List productosJson =
        response.data['productos']?['data']?['productos'] as List? ?? [];

      // print('productosJson: $productosJson');
      print('Enviando respuesta productos.......');

      return productosJson
        .map((json) => Producto.fromJson(json))
        .toList();

    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error inesperado al obtener productos: $e');
    }
  }

  static Future<void> crearProducto(
    Map<String, dynamic> payload,
  ) async {
    try {
      final empresaId = await TokenService.getEmpresaId();
      final response = await _dio.post(
        '/productos/nuevo_producto',
        data: {
          'empresa_id': empresaId,
          'dataProducto': payload
        },
      );

      if (response.statusCode != 201 &&
          response.statusCode != 200) {
        throw Exception(
          'No se pudo crear el producto (${response.statusCode})',
        );
      }

    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error inesperado al crear producto: $e');
    }
  }

  static Future<void> actualizarProducto(
    Map<String, dynamic> payload,
  ) async {
    try {
      final empresaId = await TokenService.getEmpresaId();
      final response = await _dio.put(
        '/productos/actualizar_producto',
        data: {
          'empresa_id': empresaId,
          'dataProducto': payload
        },
      );

      if (response.statusCode != 201 &&
          response.statusCode != 200) {
        throw Exception(
          'No se pudo actualizar el producto (${response.statusCode})',
        );
      }

    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error inesperado al actualizar producto: $e');
    }
  }

  static Future<String> updateDisponible(
    String id, bool disponible
  ) async {
    try {
      final empresaId = await TokenService.getEmpresaId();
      final response = await _dio.put(
        '/productos/producto_disponible',
        data: {
          'empresa_id': empresaId,
          'producto_id': id,
          'disponible': disponible
        },
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
          'No se pudo actualizar el producto (${response.statusCode})',
        );
      }

      return response.data["producto"]["mensaje"] as String;

    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error inesperado al crear producto: $e');
    }

  }

  
  static Future<String> deleteProducto(
    String id
  ) async {
    try {
      final empresaId = await TokenService.getEmpresaId();
      final response = await _dio.delete(
        '/productos/eliminar_producto',
        data: {
          'empresa_id': empresaId,
          'producto_id': id,
        },
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
          'No se pudo actualizar el producto (${response.statusCode})',
        );
      }

      return response.data["producto"]["mensaje"] as String;

    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error inesperado al crear producto: $e');
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
