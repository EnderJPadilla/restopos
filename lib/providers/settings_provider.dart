import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restopos/core/services/settings_service.dart';
import 'package:restopos/core/utils/response_validator.dart';
import '../models/settings_model.dart';

// Providers para consultar settings
final settingProvider =
    StateNotifierProvider<settingNotifier, List<Setting>>((ref) {
  return settingNotifier(ref);
});

// Loading por settings (anti-loop)
final settingsLoadingProvider =
  StateProvider.family<bool, String>((ref, id) => false);
// Loading global para refresh
final refreshLoadingProvider = StateProvider<bool>((ref) => false);


class settingNotifier extends StateNotifier<List<Setting>> {
  final Ref ref;
  
  settingNotifier(this.ref) : super([]) {
    cargarSettings();
  }

  // Cargar categorias
  Future<void> cargarSettings() async {
    try {
      print('Cargando configuraciones.......');
      final settings = await SettingsService.obtenerSettings();
      print('Configuraciones cargadas.......');
      state = settings;
    } catch (e) {
      state = [];
    }
    
  }

}

final configuracionesListadas = Provider<List<Setting>>((ref) {
  final configuraciones = ref.watch(settingProvider);
  // print('configuraciones en Provider: $configuraciones');
  return configuraciones;
});


// Providers para registrar configuraciones
final settingsProvider =
    ChangeNotifierProvider<SettingsProvider>((ref) {
  return SettingsProvider();
});


class SettingsProvider extends ChangeNotifier {
  
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> actualizarSettings(
    Map<String, dynamic> payload
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await SettingsService.actualizarSettings(payload);
      final msg = extractMessage(result, rootKey: 'configuraciones');
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