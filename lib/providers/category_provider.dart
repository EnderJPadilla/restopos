import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restopos/core/services/category_service.dart';
import 'package:restopos/core/utils/response_validator.dart';
import '../models/category_model.dart';



/// SELECCIONADOS
final categoriaSeleccionadaProvider = StateProvider<Category?>((ref) => null);

// Providers para consultar categorias
final categoryProvider =
    StateNotifierProvider<categoryNotifier, List<Category>>((ref) {
  return categoryNotifier(ref);
});

// Loading por categoria (anti-loop)
final categoryLoadingProvider =
  StateProvider.family<bool, String>((ref, id) => false);
// Loading global para refresh
final refreshLoadingProvider = StateProvider<bool>((ref) => false);

// Categoria seleccionada para edición
final selectedCategoryProvider = StateProvider<Category?>((ref) => null);


class categoryNotifier extends StateNotifier<List<Category>> {
  final Ref ref;
  
  categoryNotifier(this.ref) : super([]) {
    cargarCategorias();
  }

  // Cargar categorias
  Future<void> cargarCategorias() async {
    try {
      print('Cargando categorias.......');
      final categorias = await CategoryService.obtenerCategorias();
      print('Categorias cargada.......');
      state = categorias;
    } catch (e) {
      state = [];
    }
  }

  Future<bool> validateCategoryName(
    String categoryName,
    BuildContext context
  ) async {
    final loading = ref.read(categoryLoadingProvider(categoryName).notifier);

    // evita doble ejecución
    if (loading.state) return false;
    loading.state = true;

    try {
      final result = await CategoryService.validateCategoryName(categoryName: categoryName);

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
  Future<void> toggleActivo(String categoryId, bool value, BuildContext context) async {
    final loading = ref.read(categoryLoadingProvider(categoryId).notifier);

    // evita doble ejecución
    if (loading.state) return;
    loading.state = true;

    // Backup para rollback
    final backup = state;

    // Optimistic UI
    state = [
      for (final p in state)
        if (p.id == categoryId) p.copyWith(activo: value) else p,
    ];

    try {
      final mensaje = await CategoryService.updateActivo(categoryId, value);
      final msg = extractMessage(mensaje, rootKey: 'categoria') ?? mensaje;

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
          content: Text('Error al actualizar el estado de la categoria.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      loading.state = false;
    }
  }

}

final categoriasListadas = Provider<List<Category>>((ref) {
  final categorias = ref.watch(categoryProvider);
  return categorias;
});


// Providers para registrar categorias
final categoriasProvider =
    ChangeNotifierProvider<CategoriasProvider>((ref) {
  return CategoriasProvider();
});


class CategoriasProvider extends ChangeNotifier {
  
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> crearCategoria(
    Map<String, dynamic> payload,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await CategoryService.crearCategoria(payload);
      final msg = extractMessage(result, rootKey: 'categoria');
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

  Future<bool> actualizarCategoria(
    Map<String, dynamic> payload
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await CategoryService.actualizarCategoria(payload);
      final msg = extractMessage(result, rootKey: 'categoria');
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

  Future<bool> eliminarCategoria(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final mensaje = await CategoryService.deleteCategoria(id);
      final msg = extractMessage(mensaje, rootKey: 'categoria');
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