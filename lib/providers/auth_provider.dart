import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restopos/core/services/auth_service.dart';
import 'package:restopos/core/utils/response_validator.dart';
import 'package:restopos/core/services/token_service.dart';

/// Provider de autenticación
final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>(
  (ref) => AuthNotifier()..restoreSession(),
);


class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final bool userValidated;
  final String? username;
  final String? userId;
  final String? userRole;
  final String? userBusiness;
  final String? errorMessage;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = true,
    this.userValidated = false,
    this.username,
    this.userId,
    this.userRole,
    this.userBusiness,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    bool? userValidated,
    String? username,
    String? userId,
    String? userRole,
    String? userBusiness,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      userValidated: userValidated ?? this.userValidated,
      username: username ?? this.username,
      userId: userId ?? this.userId,
      userRole: userRole ?? this.userRole,
      userBusiness: userBusiness ?? this.userBusiness,
      errorMessage: errorMessage,
    );
  }

  static const empty = AuthState();
}


class AuthNotifier extends StateNotifier<AsyncValue<AuthState>> {
  AuthNotifier() : super(const AsyncValue.data(AuthState.empty));


  // Future<void> restoreSession() async {
  //   try {
  //     final hasSession = await TokenService.hasValidSession();

  //     if (!hasSession) {
  //       state = const AsyncValue.data(AuthState.empty);
  //       return;
  //     }

  //     final empresaId = await TokenService.getEmpresaId();

  //     state = AsyncValue.data(
  //       AuthState(
  //         isAuthenticated: true,
  //         userValidated: true,
  //         userBusiness: empresaId,
  //       ),
  //     );
  //   } catch (_) {
  //     state = const AsyncValue.data(AuthState.empty);
  //   }
  // }
  Future<void> restoreSession() async {
    try {
      state = const AsyncValue.data(AuthState(isLoading: true));

      final hasSession = await TokenService.hasValidSession();

      if (!hasSession) {
        state = const AsyncValue.data(AuthState.empty);
        return;
      }

      final empresaId = await TokenService.getEmpresaId();

      state = AsyncValue.data(
        AuthState(
          isAuthenticated: true,
          isLoading: false,
          userValidated: true,
          userBusiness: empresaId,
        ),
      );
    } catch (_) {
      state = const AsyncValue.data(AuthState.empty);
    }
  }


  Future<bool> validateUser(String username) async {
    state = const AsyncValue.loading();

    try {
      final result = await AuthService.validateUser(userName: username);

      if (result.isEmpty) {
        state = const AsyncValue.data(
          AuthState(errorMessage: 'Respuesta vacía de la API'),
        );
        return false;
      }

      final data = result[0];
      print('Respuesta de validateUser: $data'); // Debug log
      final bool isValid = data['authenticated'];
      print('isValid: $isValid'); // Debug log
      final userData = data['message'] ?? data['usuario'];

      if (!isValid) {
        state = AsyncValue.data(
          AuthState(
            errorMessage: data?['message'] ?? 'Usuario invalido.',
          ),
        );
        return false;
      }

      final serverMsg = extractMessage(userData);
      if (serverMsg != null && isErrorMessage(serverMsg)) {
        state = AsyncValue.data(
          AuthState(errorMessage: serverMsg),
        );
        return false;
      }

      final userBusiness = userData?['empresa_id'] ?? userData?['company_id'];

      state = AsyncValue.data(
        AuthState(
          userValidated: true,
          username: username,
          userBusiness: userBusiness?.toString(),
        ),
      );

      return true;
    } catch (e, stackTrace) {
      state = AsyncValue.error(
        'Error de conexión: $e',
        stackTrace,
      );
      return false;
    }
  }


  Future<bool> validatePin(
    String username,
    String password,
    String company,
  ) async {
    state = const AsyncValue.loading();

    try {
      final result = await AuthService.login(
        usuario: username,
        password: password,
        empresaId: company,
      );

      if (result.isEmpty) {
        state = const AsyncValue.data(
          AuthState(errorMessage: 'Respuesta vacía de la API'),
        );
        return false;
      }

      final data = result[0];
      final bool isValid = data['authenticated'] == true;
      final userData = data['usuario'];

      final serverMsg = extractMessage(userData);
      if (serverMsg != null && isErrorMessage(serverMsg)) {
        state = AsyncValue.data(
          AuthState(errorMessage: serverMsg),
        );
        return false;
      }

      if (!isValid) {
        state = AsyncValue.data(
          AuthState(
            errorMessage:
              userData?['message'] ??
              'Usuario o contraseña incorrectos',
          ),
        );
        return false;
      }

      final accessToken = data['accessToken'];
      final refreshToken = data['refreshToken'];

      if (accessToken != null) {
        await TokenService.setAccessToken(accessToken);
      }

      if (refreshToken != null) {
        await TokenService.setRefreshToken(refreshToken);
      }

      // await TokenService.setEmpresaId(userData?['empresa']);
      // await TokenService.setUsuarioId(userData?['usuario_id']);
      // await TokenService.setUsuarioName(username);
      // await TokenService.setName(userData?['nombres'] ?? '');

      state = AsyncValue.data(
        AuthState(
          isAuthenticated: true, // 👈 sesión real
          userValidated: true,
          username:
            userData?['nombre_usuario'] ??
            userData?['username'] ??
            username,
          userRole:
            userData?['rol'] ??
            userData?['role'],
          userBusiness:
            userData?['empresa'] ??
            userData?['company'],
        ),
      );

      return true;
    } catch (e, stackTrace) {
      state = AsyncValue.error(
        'Error de conexión: $e',
        stackTrace,
      );
      return false;
    }
  }

  /// ===============================
  /// LOGOUT GLOBAL
  /// ===============================
  Future<void> logout() async {
    await AuthService.logout();

    state = const AsyncValue.data(AuthState.empty);
  }
}
