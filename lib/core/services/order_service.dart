import 'package:dio/dio.dart';
import 'package:restopos/core/services/token_service.dart';
import 'package:restopos/models/order_model.dart';
import '../network/dio_client.dart';

class OrdersService {
  static final Dio _dio = ApiClient.dio;

  static Future<List<Order>> obtenerPedidos() async {
    try {
      final empresaId = await TokenService.getEmpresaId();
      final response = await _dio.post(
        '/settings/listar_pedidos',
        data: {
          'empresa_id': empresaId,
        }
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Error al obtener configuraciones (${response.statusCode})',
        );
      }

      final List pedidosJson =
        response.data['pedidos'] as List? ?? [];

      // print('productosJson: $productosJson');
      print('Enviando respuesta pedidos.......');

      return pedidosJson
        .map((json) => Order.fromJson(json))
        .toList();

    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error inesperado al obtener pedidos: $e');
    }
  }

  static Future<Map<String, dynamic>> guardarPedidos(
    Map<String, dynamic> payload,
  ) async {
    try {
      final empresaId = await TokenService.getEmpresaId();
      final response = await _dio.post(
        '/settings/guardar_pedidos',
        data: {
          'empresa_id': empresaId,
          'dataPedidos': payload
        },
      );

      if (response.statusCode != 201 &&
          response.statusCode != 200) {
        throw Exception(
          'No se pudo guardar el pedido (${response.statusCode})',
        );
      }

      return response.data;

    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error inesperado al guardar el pedido: $e');
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
