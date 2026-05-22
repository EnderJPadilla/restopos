// import 'package:jwt_decoder/jwt_decoder.dart';
// import '../services/token_service.dart';

// class AuthGuard {
//   /// Determina si el usuario puede acceder a rutas protegidas
//   static Future<bool> canActivate() async {
//     final accessToken = await TokenService.getAccessToken();

//     // No hay token
//     if (accessToken == null || accessToken.isEmpty) {
//       return false;
//     }

//     // Token corrupto o inválido
//     try {
//       JwtDecoder.decode(accessToken);
//     } catch (_) {
//       await TokenService.clear();
//       return false;
//     }

//     // Token expirado
//     final bool isExpired = JwtDecoder.isExpired(accessToken);

//     if (isExpired) {
//       final bool refreshed = await TokenService.refreshToken();

//       // No se pudo refrescar
//       if (!refreshed) {
//         await TokenService.clear();
//         return false;
//       }

//       // Token renovado correctamente
//       final newToken = await TokenService.getAccessToken();
//       return newToken != null && newToken.isNotEmpty;
//     }

//     // Token válido y activo
//     return true;
//   }
// }

import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/token_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final initialSessionProvider = Provider<bool>((ref) {
  return false;
});

class AuthGuard {

  static Future<bool> canActivate() async {

    // Esperar un pequeño tiempo para asegurar carga del storage en Web
    await Future.delayed(const Duration(milliseconds: 50));

    final accessToken = await TokenService.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      return false;
    }

    try {
      JwtDecoder.decode(accessToken);
    } catch (_) {
      await TokenService.clear();
      return false;
    }

    final bool isExpired = JwtDecoder.isExpired(accessToken);

    if (isExpired) {

      final bool refreshed = await TokenService.refreshToken();

      if (!refreshed) {
        await TokenService.clear();
        return false;
      }

      final newToken = await TokenService.getAccessToken();
      return newToken != null && newToken.isNotEmpty;
    }

    return true;
  }
}