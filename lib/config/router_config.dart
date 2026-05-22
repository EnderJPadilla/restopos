import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import 'package:restopos/core/services/token_service.dart';

import 'package:restopos/screen/login_screen.dart';
import 'package:restopos/screen/pin_screen.dart';

import 'package:restopos/screen/administrator/home_admin.dart';
import 'package:restopos/screen/administrator/dashboard/dashboard_screen.dart';
import 'package:restopos/screen/administrator/menu/pages/menu_screen.dart';
import 'package:restopos/screen/administrator/menu/pages/new_product_screen.dart';
import 'package:restopos/screen/administrator/reports/reports_screen.dart';
import 'package:restopos/screen/administrator/settings/settings_screen.dart';
import 'package:restopos/screen/administrator/users/pages/new_user_screen.dart';
import 'package:restopos/screen/administrator/users/pages/users_screen.dart';

import 'package:restopos/screen/waiter/home_waiter.dart';
import 'package:restopos/screen/waiter/order_screen.dart';

final _authRefreshNotifier = ValueNotifier<bool>(false);

final goRouterProvider = Provider<GoRouter>((ref) {

  // Escuchar cambios de autenticación
  ref.listen<AsyncValue<AuthState>>(authProvider, (prev, next) {
    final prevAuth = prev?.value?.isAuthenticated ?? false;
    final nextAuth = next.value?.isAuthenticated ?? false;

    if (prevAuth != nextAuth) {
      _authRefreshNotifier.value = !_authRefreshNotifier.value;
    }
  });

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,

    refreshListenable: _authRefreshNotifier,

    // redirect: (context, state) async {

    //   final authAsync = ref.read(authProvider);

    //   // Mientras el provider carga
    //   if (authAsync.isLoading) {
    //     return null;
    //   }

    //   final auth = authAsync.value ?? AuthState.empty;

    //   final location = state.matchedLocation;
    //   final isLogin = location == '/login';
    //   final isPin = location.startsWith('/pin');
    //   final isAdmin = location.startsWith('/admin');
    //   final isMesero = location.startsWith('/mesero');

    //   // 🔑 Verificar si existe token almacenado
    //   final token = await TokenService.getAccessToken();
    //   final hasStoredToken = token != null && token.isNotEmpty;

    //   /// -------------------------
    //   /// USUARIO NO AUTENTICADO
    //   /// -------------------------
    //   if (!auth.isAuthenticated) {

    //     // Si hay token guardado permitir acceso mientras se restaura sesión
    //     if (hasStoredToken) {
    //       return null;
    //     }

    //     if (isLogin || isPin) {
    //       return null;
    //     }

    //     return '/login';
    //   }

    //   /// -------------------------
    //   /// USUARIO AUTENTICADO
    //   /// -------------------------
    //   final userRole = auth.userRole?.trim().toLowerCase() ?? '';

    //   // Validación estricta ADMIN
    //   if (isAdmin && userRole != 'administrador') {
    //     return '/login';
    //   }

    //   // Validación estricta MESERO
    //   if (isMesero && userRole != 'mesero') {
    //     return '/login';
    //   }

    //   // Si usuario autenticado intenta ir a login
    //   if (isLogin) {
    //     if (userRole == 'administrador') {
    //       return '/admin/dashboard';
    //     } else if (userRole == 'mesero') {
    //       return '/mesero';
    //     }

    //     return '/login';
    //   }

    //   // PIN se controla en su propia pantalla
    //   if (isPin) {
    //     return null;
    //   }

    //   return null;
    // },
    redirect: (context, state) {
      final authAsync = ref.read(authProvider);

      if (authAsync.isLoading) return null;

      final auth = authAsync.value ?? AuthState.empty;

      final location = state.matchedLocation;
      final isLogin = location == '/login';
      final isPin = location.startsWith('/pin');
      final isAdmin = location.startsWith('/admin');
      final isMesero = location.startsWith('/mesero');

      /// 🔴 NO AUTENTICADO
      if (!auth.isAuthenticated) {
        if (isLogin || isPin) return null;
        return '/login';
      }

      /// 🟢 AUTENTICADO
      final role = auth.userRole?.toLowerCase() ?? '';

      if (isAdmin && role != 'administrador') {
        return '/login';
      }

      if (isMesero && role != 'mesero') {
        return '/login';
      }

      if (isLogin) {
        if (role == 'administrador') return '/admin/dashboard';
        if (role == 'mesero') return '/mesero';
      }

      return null;
    },

    routes: [

      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),

      GoRoute(
        path: '/pin/:user',
        name: 'pin',
        builder: (context, state) {
          final user = state.pathParameters['user'] ?? '';
          return PinScreen(user: user);
        },
      ),

      ShellRoute(
        builder: (_, __, child) => HomeAdmin(child: child),
        routes: [

          GoRoute(
            path: '/admin/dashboard',
            builder: (_, __) => const Dashboard(),
          ),

          GoRoute(
            path: '/admin/menu',
            builder: (_, __) => const MenuScreen(),
          ),

          GoRoute(
            path: '/admin/menu/nuevo',
            builder: (_, __) => const NewProduct(),
          ),

          GoRoute(
            path: '/admin/menu/editar',
            builder: (context, state) => const NewProduct(),
          ),

          GoRoute(
            path: '/admin/users',
            builder: (_, __) => const UsuariosScreen(),
          ),

          GoRoute(
            path: '/admin/users/nuevo',
            builder: (_, __) => const NewUserScreen(),
          ),

          GoRoute(
            path: '/admin/users/editar',
            builder: (context, state) => const NewUserScreen(),
          ),

          GoRoute(
            path: '/admin/settings',
            builder: (_, __) => const SettingsScreen(),
          ),

          GoRoute(
            path: '/admin/reports',
            builder: (_, __) => const ReportsScreen(),
          ),
        ],
      ),

      GoRoute(
        path: '/mesero',
        builder: (context, state) {
          return const HomeWaiter();
        },
        routes: [
          GoRoute(
            path: 'registrar_pedido',
            builder: (context, state) {
              return PedidoScreen();
            },
          ),
        ],
      ),
    ],
  );
});

