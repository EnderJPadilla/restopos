import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restopos/core/services/table_service.dart';
import 'package:restopos/core/utils/response_validator.dart';
import '../models/table_model.dart';



/// SELECCIONADOS
final tableSeleccionadaProvider = StateProvider<TableModel?>((ref) => null);

// Providers para consultar mesas
final tableProvider =
    StateNotifierProvider<tableNotifier, List<TableModel>>((ref) {
  return tableNotifier(ref);
});

// Loading por mesa (anti-loop)
final tableLoadingProvider =
  StateProvider.family<bool, String>((ref, id) => false);
// Loading global para refresh
final refreshLoadingProvider = StateProvider<bool>((ref) => false);

// Mesa seleccionada para edición
final selectedTableProvider = StateProvider<TableModel?>((ref) => null);


class tableNotifier extends StateNotifier<List<TableModel>> {
  final Ref ref;
  
  tableNotifier(this.ref) : super([]) {
    cargarMesas();
  }

  // Cargar mesas
  Future<void> cargarMesas() async {
    try {
      print('Cargando mesas.......');
      final mesas = await TableService.obtenerMesas();
      print('Mesas cargadas.......');
      state = mesas;
    } catch (e) {
      state = [];
    }
  }

  Future<bool> validateTableNumber(
    int tableNumber,
    BuildContext context
  ) async {
    final loading = ref.read(tableLoadingProvider(tableNumber.toString()).notifier);

    // evita doble ejecución
    if (loading.state) return false;
    loading.state = true;

    try {
      final result = await TableService.validateTableNumber(tableNumber: tableNumber);

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
          content: Text('Error al validar el número de la mesa.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      loading.state = false;
    }
    // Asegurar que siempre se devuelve un bool en todos los caminos de ejecución
    return false;
  }

  Future<bool> validateTableName(
    String tableName,
    BuildContext context
  ) async {
    final loading = ref.read(tableLoadingProvider(tableName).notifier);

    // evita doble ejecución
    if (loading.state) return false;
    loading.state = true;

    try {
      final result = await TableService.validateTableName(tableName: tableName);

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
          content: Text('Error al validar el nombre de la mesa.'),
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
  Future<void> toggleActivo(String tableId, bool value, BuildContext context) async {
    final loading = ref.read(tableLoadingProvider(tableId).notifier);

    // evita doble ejecución
    if (loading.state) return;
    loading.state = true;

    // Backup para rollback
    final backup = state;

    // Optimistic UI
    state = [
      for (final p in state)
        if (p.id == tableId) p.copyWith(activo: value) else p,
    ];

    try {
      final mensaje = await TableService.updateActivo(tableId, value);
      final msg = extractMessage(mensaje, rootKey: 'mesa') ?? mensaje;

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
          content: Text('Error al actualizar el estado de la mesa.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      loading.state = false;
    }
  }

}

final mesasListadas = Provider<List<TableModel>>((ref) {
  final mesas = ref.watch(tableProvider);
  return mesas;
});


// Providers para registrar mesas
final mesasProvider =
    ChangeNotifierProvider<MesasProvider>((ref) {
  return MesasProvider();
});


class MesasProvider extends ChangeNotifier {
  
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> crearMesa(
    Map<String, dynamic> payload,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await TableService.crearMesa(payload);
      final msg = extractMessage(result, rootKey: 'mesa');
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

  Future<bool> actualizarMesa(
    Map<String, dynamic> payload
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await TableService.actualizarMesa(payload);
      final msg = extractMessage(result, rootKey: 'mesa');
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

  Future<bool> eliminarMesa(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final mensaje = await TableService.deleteMesa(id);
      final msg = extractMessage(mensaje, rootKey: 'mesa');
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