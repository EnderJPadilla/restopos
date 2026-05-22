import 'package:dio/dio.dart';
import 'package:restopos/models/location_model.dart';
import '../network/dio_client.dart';

class LocationService {
  static final Dio _dio = ApiClient.dio;

  static Future<List<Location>> obtenerPaises() async {
    try {
      final res = await _dio.post(
        "/locations/paises",
        data: {
          'accion': 'PAISES'
        },
      );

      return (res.data['paises'] as List)
        .map((e) => Location.fromJson(e))
        .toList();      
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  static Future<List<Location>> obtenerDepartamentos(String pais) async {
    try {
      final res = await _dio.post(
        "/locations/departamentos",
        data: {
          'accion': 'DEPARTAMENTOS',
          'filtro': pais
        },
      );

      return (res.data['departamentos'] as List)
        .map((e) => Location.fromJson(e))
        .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  static Future<List<Location>> obtenerCiudades(String depto) async {
    try {
      final res = await _dio.post(
        "/locations/ciudades",
        data: {
          "accion": "CIUDADES",
          "filtro": depto
        },
      );
      return (res.data['ciudades'] as List)
        .map((e) => Location.fromJson(e))
        .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  static String _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return "Tiempo de conexión agotado";
    }
    if (e.type == DioExceptionType.receiveTimeout) {
      return "Servidor tardó en responder";
    }
    if (e.response != null) {
      return "Error API: ${e.response?.statusCode} - ${e.response?.data}";
    }
    return "Error desconocido: ${e.message}";
  }

}
