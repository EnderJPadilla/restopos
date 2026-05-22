import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restopos/core/services/product_service.dart';
import 'package:restopos/core/utils/response_validator.dart';
import '../models/product_model.dart';

// Providers para productos
final productProvider =
    ChangeNotifierProvider<ProductProvider>((ref) {
  return ProductProvider();
});

// Para obtener lista de productos
final productsProvider = FutureProvider.autoDispose((ref) async {
  return await ProductService.obtenerProductos();
});

// Producto seleccionado para edición
final selectedProductProvider = StateProvider<Producto?>((ref) => null);


class ProductProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> crearProducto(
    Map<String, dynamic> payload,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ProductService.crearProducto(payload);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> actualizarProducto(
    Map<String, dynamic> payload
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ProductService.actualizarProducto(payload);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> eliminarProducto(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final mensaje = await ProductService.deleteProducto(id);
      final msg = extractMessage(mensaje, rootKey: 'producto');
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
