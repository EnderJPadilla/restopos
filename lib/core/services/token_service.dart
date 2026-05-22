import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../network/dio_client.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class TokenService {
  static const _storage = FlutterSecureStorage();

  // 🔑 Keys
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _empresaIdKey = 'empresa_id';
  static const _usuarioIdKey = 'usuario_id';
  static const _usuarioNameKey = 'usuario_name';
  static const _NameKey = 'name';

  /// ================================
  /// STORAGE CROSS PLATFORM
  /// ================================

  static Future<void> _write(String key, String value) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } else {
      await _storage.write(key: key, value: value);
    }
  }

  static Future<String?> _read(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } else {
      return await _storage.read(key: key);
    }
  }

  static Future<void> _delete(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } else {
      await _storage.delete(key: key);
    }
  }

  /// ================================
  /// ACCESS TOKEN
  /// ================================

  static Future<void> setAccessToken(String token) async {
    await _write(_accessTokenKey, token);
  }

  static Future<String?> getAccessToken() async {
    return await _read(_accessTokenKey);
  }

  /// ================================
  /// REFRESH TOKEN
  /// ================================

  static Future<void> setRefreshToken(String token) async {
    await _write(_refreshTokenKey, token);
  }

  static Future<String?> getRefreshToken() async {
    return await _read(_refreshTokenKey);
  }

  /// ================================
  /// EMPRESA
  /// ================================

  static Future<void> setEmpresaId(String empresaId) async {
    await _write(_empresaIdKey, empresaId);
  }

  static Future<String?> getEmpresaId() async {
    return await _read(_empresaIdKey);
  }

  /// ================================
  /// USUARIO NAME
  /// ================================

  static Future<void> setUsuarioName(String usuarioName) async {
    await _write(_usuarioNameKey, usuarioName);
  }

  static Future<String?> getUsuarioName() async {
    return await _read(_usuarioNameKey);
  }

  /// ================================
  /// USUARIO ID
  /// ================================

  static Future<void> setUsuarioId(String usuarioId) async {
    await _write(_usuarioIdKey, usuarioId);
  }

  static Future<String?> getUsuarioId() async {
    return await _read(_usuarioIdKey);
  }

  /// ================================
  /// NAME
  /// ================================

  static Future<void> setName(String name) async {
    await _write(_NameKey, name);
  }

  static Future<String?> getName() async {
    return await _read(_NameKey);
  }

  /// ================================
  /// VALIDAR SESIÓN
  /// ================================

  static Future<bool> hasValidSession() async {
    final token = await getAccessToken();
    if (token == null) return false;

    if (JwtDecoder.isExpired(token)) {
      return await refreshToken();
    }

    return true;
  }

  /// ================================
  /// REFRESH TOKEN
  /// ================================

  static Future<bool> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();

      if (refreshToken == null) return false;

      final response = await ApiClient.dio.post(
        '/auth/refresh',
        data: {
          'refresh_token': refreshToken,
        },
        options: Options(
          headers: {
            'Authorization': null, // evita loop de interceptor
          },
        ),
      );

      final newAccessToken = response.data['access_token'];
      final newRefreshToken = response.data['refresh_token'];

      if (newAccessToken == null) return false;

      await setAccessToken(newAccessToken);

      if (newRefreshToken != null) {
        await setRefreshToken(newRefreshToken);
      }

      return true;
    } catch (_) {
      await clear();
      return false;
    }
  }

  /// ================================
  /// LOGOUT / CLEAR SESSION
  /// ================================

  static Future<void> clear() async {
    await _delete(_accessTokenKey);
    await _delete(_refreshTokenKey);
    await _delete(_empresaIdKey);
    await _delete(_usuarioIdKey);
    await _delete(_usuarioNameKey);
    await _delete(_NameKey);
  }
}