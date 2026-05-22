import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restopos/core/services/user_service.dart';
import '../models/usuario_model.dart';
import 'package:restopos/core/utils/response_validator.dart';

// Providers para consultar usuarios
final userProvider =
    StateNotifierProvider<UserNotifier, List<Usuario>>((ref) {
  return UserNotifier(ref);
});

// Loading por usuario (anti-loop)
final userLoadingProvider =
  StateProvider.family<bool, String>((ref, id) => false);
// Loading global para refresh
final refreshLoadingProvider = StateProvider<bool>((ref) => false);

// Usuario seleccionado para edición
final selectedUserProvider = StateProvider<Usuario?>((ref) => null);

// Rol seleccionado para permisos
final rolSeleccionadoProvider = StateProvider<String>((ref) => "");


class UserNotifier extends StateNotifier<List<Usuario>> {
  final Ref ref;
  
  UserNotifier(this.ref) : super([]) {
    cargarUsuarios();
  }

  // Cargar usuarios
  Future<void> cargarUsuarios() async {
    try {
      print('Cargando usuarios.......');
      final usuarios = await UserService.obtenerUsuarios();
      print('Respuesta cargada.......');
      state = usuarios;
    } catch (e) {
      state = [];
    }
  }

  Future<bool> validateUserName(
    String userName,
    BuildContext context
  ) async {
    final loading = ref.read(userLoadingProvider(userName).notifier);

    // evita doble ejecución
    if (loading.state) return false;
    loading.state = true;

    try {
      final result = await UserService.validateUserName(userName: userName);

      if (result.isEmpty) {
        return false;
      }

      final data = result[0];
      final bool isValid = data['validado'];

      if (!isValid) {
        return false;
      }

      return true;

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al actualizar el estado de la categoria.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      loading.state = false;
    }
    // Asegurar que siempre se devuelve un bool en todos los caminos de ejecución
    return false;
  }
  
  // Toggle activo
  Future<void> toggleActivo(String empleadoId, String usuarioId, bool value, BuildContext context,) async {
    final loading = ref.read(userLoadingProvider(empleadoId).notifier);

    // evita doble ejecución
    if (loading.state) return;
    loading.state = true;

    // Backup para rollback
    final backup = state;

    // Optimistic UI
    state = [
      for (final p in state)
        if (p.empleadoId == empleadoId && p.usuarioId == usuarioId) p.copyWith(activo: value) else p,
    ];

    try {
      final mensaje = await UserService.updateActivo(empleadoId, usuarioId, value);
      final msg = extractMessage(mensaje, rootKey: 'usuario') ?? mensaje;

      if (msg != null && isErrorMessage(msg)) {
        // Rollback y mostrar error del servidor
        state = backup;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.green,
          ),
        );
      }

    } catch (e) {
      // Rollback si falla API
      state = backup;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al actualizar el estado del usuario'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      loading.state = false;
    }
  }

}


// Providers para registrar usuarios
final usersProvider =
    ChangeNotifierProvider<UsersProvider>((ref) {
  return UsersProvider();
});


class UsersProvider extends ChangeNotifier {
  
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> crearUsuario(
    Map<String, dynamic> payload,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await UserService.crearUsuario(payload);
      final msg = extractMessage(result, rootKey: 'usuario');
      if (msg != null && isErrorMessage(msg)) {
        _error = msg;
        return false;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> actualizarUsuario(
    Map<String, dynamic> payload
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await UserService.actualizarUsuario(payload);
      final msg = extractMessage(result, rootKey: 'usuario');
      if (msg != null && isErrorMessage(msg)) {
        _error = msg;
        return false;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> eliminarUsuario(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final mensaje = await UserService.deleteUsuario(id);
      final msg = extractMessage(mensaje, rootKey: 'usuario');
      if (msg != null && isErrorMessage(msg)) {
        _error = msg;
        return false;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

}


final adminsFiltradosProvider = Provider<List<Usuario>>((ref) {
  final users = ref.watch(userProvider);
  final admins = users.where((usuario) => 
    usuario.rol == 'Administrador'
  ).toList();
  return admins;
});

final meserosFiltradosProvider = Provider<List<Usuario>>((ref) {
  final users = ref.watch(userProvider);
  final meseros = users.where((usuario) => 
    usuario.rol == 'Mesero'
  ).toList();
  return meseros;
});

final cajerosFiltradosProvider = Provider<List<Usuario>>((ref) {
  final users = ref.watch(userProvider);
  final cajeros = users.where((usuario) => 
    usuario.rol == 'Cajero'
  ).toList();
  return cajeros;
});



final permisosProvider =
    StateNotifierProvider<PermisosNotifier, Map<String, List<Permiso>>>((ref) {
  return PermisosNotifier();
});

class PermisosNotifier extends StateNotifier<Map<String, List<Permiso>>> {

  PermisosNotifier() : super(_defaultPermisos);

  // Estado inicial separado (no recrear notifier)
  static final _defaultPermisos = {
    "dashboard": [
      Permiso(key: "ver_dashboard", activo: false),
      Permiso(key: "ver_reportes", activo: false),
      Permiso(key: "exportar_reportes", activo: false),
    ],
    "pagos": [
      Permiso(key: "procesar_pagos", activo: false),
      Permiso(key: "pagos_efectivo", activo: false),
      Permiso(key: "pagos_tarjeta", activo: false),
      Permiso(key: "reembolsos", activo: false),
      Permiso(key: "abrir_caja", activo: false),
      Permiso(key: "cerrar_caja", activo: false),
      Permiso(key: "ver_historial_caja", activo: false),
    ],
    "pedidos": [
      Permiso(key: "crear_pedido", activo: false),
      Permiso(key: "editar_pedido", activo: false),
      Permiso(key: "cancelar_pedido", activo: false),
      Permiso(key: "aplicar_descuentos", activo: false),
    ],
    "usuarios": [
      Permiso(key: "ver_usuarios", activo: false),
      Permiso(key: "crear_usuarios", activo: false),
      Permiso(key: "editar_usuarios", activo: false),
      Permiso(key: "eliminar_usuarios", activo: false),
    ],
    "menu": [
      Permiso(key: "ver_menu", activo: false),
      Permiso(key: "editar_menu", activo: false),
      Permiso(key: "crear_productos", activo: false),
      Permiso(key: "eliminar_productos", activo: false),
    ],
    "mesas": [
      Permiso(key: "gestionar_mesas", activo: false),
      Permiso(key: "transferir_mesas", activo: false),
      Permiso(key: "ver_inventario", activo: false),
      Permiso(key: "editar_inventario", activo: false),
    ],
    "sistema": [
      Permiso(key: "ver_config", activo: false),
      Permiso(key: "editar_config", activo: false),
      Permiso(key: "impresoras", activo: false),
      Permiso(key: "reimprimir", activo: false),
    ],
  };

  // ================= TOGGLE =================
  void toggle(String group, String permisoKey) {
    final nuevo = {...state};

    nuevo[group] = nuevo[group]!
      .map((p) => p.key == permisoKey ? p.copyWith(activo: !p.activo) : p)
      .toList();

    state = nuevo;
  }

  // ================= ROL =================
  void aplicarRol(String rol) {
    final nuevo = {
      for (var g in state.keys)
        g: state[g]!.map((p) => p.copyWith(activo: false)).toList()
    };

    void activar(String g, String k) {
      final i = nuevo[g]!.indexWhere((p) => p.key == k);
      if (i != -1) nuevo[g]![i] = nuevo[g]![i].copyWith(activo: true);
    }

    if (rol == "Administrador") {
      for (var g in nuevo.keys) {
        nuevo[g] = nuevo[g]!.map((p) => p.copyWith(activo: true)).toList();
      }
    }

    if (rol == "Mesero") {
      activar("pedidos", "crear_pedido");
      activar("pedidos", "editar_pedido");
      activar("menu", "ver_menu");
      activar("mesas", "gestionar_mesas");
      activar("mesas", "transferir_mesas");
      activar("sistema", "reimprimir");
    }

    if (rol == "Cajero") {
      activar("pedidos", "aplicar_descuentos");
      activar("menu", "ver_menu");
      activar("pagos", "procesar_pagos");
      activar("pagos", "pagos_efectivo");
      activar("pagos", "pagos_tarjeta");
      activar("pagos", "reembolsos");
      activar("pagos", "abrir_caja");
      activar("pagos", "cerrar_caja");
      activar("pagos", "ver_historial_caja");
      activar("sistema", "reimprimir");
    }

    state = nuevo;
  }

  // ================= CARGAR JSON =================
  void cargarPermisos(Map<String, dynamic> json) {
    final nuevo = <String, List<Permiso>>{};

    for (final grupo in state.keys) {
      nuevo[grupo] = state[grupo]!.map((p) {
        final activo = json[p.key] == true;
        return p.copyWith(activo: activo);
      }).toList();
    }

    state = nuevo;
  }

  // ================= RESET =================
  void resetPermisos() {
    state = {
      for (var g in _defaultPermisos.keys)
        g: _defaultPermisos[g]!.map((p) => p.copyWith()).toList()
    };
  }

}