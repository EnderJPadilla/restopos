import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restopos/models/product_model.dart';
import 'package:restopos/core/services/product_service.dart';
import 'package:restopos/core/utils/response_validator.dart';

final productosProvider =
    StateNotifierProvider<ProductosNotifier, List<Producto>>((ref) {
  return ProductosNotifier(ref);
});

// Loading por producto (anti-loop)
final productLoadingProvider =
  StateProvider.family<bool, String>((ref, id) => false);
// Loading global para refresh
final refreshLoadingProvider = StateProvider<bool>((ref) => false);



class ProductosNotifier extends StateNotifier<List<Producto>> {
  final Ref ref;

  ProductosNotifier(this.ref) : super([]) {
    cargarProductos();
  }

  // Cargar productos
  Future<void> cargarProductos() async {
    try {
      print('Cargando productos.......');
      final productos = await ProductService.obtenerProductos();
      print('Respuesta cargada.......');
      state = productos;
    } catch (e) {
      state = [];
    }
  }

  // Toggle disponible PRO
  Future<void> toggleDisponible(String id, bool value, BuildContext context,) async {
    final loading = ref.read(productLoadingProvider(id).notifier);

    // evita doble ejecución
    if (loading.state) return;
    loading.state = true;

    // Backup para rollback
    final backup = state;

    // Optimistic UI
    state = [
      for (final p in state)
        if (p.id == id) p.copyWith(disponible: value) else p,
    ];

    try {
      final mensaje = await ProductService.updateDisponible(id, value);
      final msg = extractMessage(mensaje, rootKey: 'producto') ?? mensaje;

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
          content: Text('Error al actualizar el producto'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      loading.state = false;
    }
  }

}


final searchQueryProvider = StateProvider<String>((ref) => '');

final categoriaSeleccionadaProvider = StateProvider<String>((ref) => 'Todos');

final productosfiltradosProvider = Provider<List<Producto>>((ref) {
  final productos = ref.watch(productosProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final categoriaSeleccionada = ref.watch(categoriaSeleccionadaProvider);

  final filtrados = productos.where((producto) {
    final coincideNombre =
      producto.nombre.toLowerCase().contains(searchQuery);

    final coincideDescripcion =
      producto.descripcion.toLowerCase().contains(searchQuery);

    final coincideCategoria = categoriaSeleccionada == 'Todos' ||
      producto.categoria == categoriaSeleccionada;

    return (coincideNombre || coincideDescripcion) && coincideCategoria;
  }).toList();

  filtrados.sort((a, b) => b.fecha_actualizacion.compareTo(a.fecha_actualizacion));

  return filtrados;

});

final categoriasProvider = Provider<List<String>>((ref) {
  final productos = ref.watch(productosProvider);
  final categorias = <String>{'Todos'};

  for (final producto in productos) {
    categorias.add(producto.categoria);
  }

  return categorias.toList();
});
