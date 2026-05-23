import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restopos/core/services/order_service.dart';
import 'package:restopos/core/utils/response_validator.dart';
import '../models/order_model.dart';

// Mesa seleccionada para pedido
final mesaSeleccionadaProvider = StateProvider<tableOrders?>((ref) => null);

// Pedido seleccionado para pedido
final selectedOrderProvider = StateProvider<Order?>((ref) => null);


// Providers para consultar pedidos
final ordersProvider =
    StateNotifierProvider<OrdersProvider, List<Order>>((ref) {
  return OrdersProvider(ref);
});


class OrdersProvider extends StateNotifier<List<Order>> {
  final Ref ref;
  
  OrdersProvider(this.ref) : super([]) {
    cargarOrders();
  }

  // Cargar categorias
  Future<void> cargarOrders() async {
    try {
      print('Cargando pedidos.......');
      final pedidos = await OrdersService.obtenerPedidos();
      print('Pedidos cargados.......');
      state = pedidos;
    } catch (e) {
      state = [];
    }
    
  }
    
}



// Providers para registrar pedidos
final orderProvider =
    ChangeNotifierProvider<OrderProvider>((ref) {
  return OrderProvider();
});


class OrderProvider extends ChangeNotifier {
  
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> guardarPedidos(
    Map<String, dynamic> payload
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await OrdersService.guardarPedidos(payload);
      final msg = extractMessage(result, rootKey: 'pedido');
      if (msg != null && isErrorMessage(msg)) {
        _error = msg;
        return false;
      }
      if (msg != 'Pedido registrado correctamente') {
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