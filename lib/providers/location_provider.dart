import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/location_model.dart';
import '../core/services/location_service.dart';

/// CACHE GLOBAL
final List<Location> listPaises = [];
final List<Location> listDepartamentos = [];
final List<Location> listCiudades = [];

/// SELECCIONADOS
final paisSeleccionadoProvider = StateProvider<Location?>((ref) => null);
final departamentoSeleccionadoProvider = StateProvider<Location?>((ref) => null);
final ciudadSeleccionadaProvider = StateProvider<Location?>((ref) => null);

/// PAÍSES
final paisesProvider = FutureProvider<List<Location>>((ref) async {
  if (listPaises.isNotEmpty) return listPaises;
  final res = await LocationService.obtenerPaises();
  listPaises
    ..clear()
    ..addAll(res);
  return res;
});

/// DEPARTAMENTOS
final departamentosProvider = FutureProvider<List<Location>>((ref) async {
  final pais = ref.watch(paisSeleccionadoProvider);
  if (pais == null) return [];

  final res = await LocationService.obtenerDepartamentos(pais.nombre);
  listDepartamentos
    ..clear()
    ..addAll(res);

  return res;
});

/// CIUDADES
final ciudadesProvider = FutureProvider<List<Location>>((ref) async {
  final depto = ref.watch(departamentoSeleccionadoProvider);
  if (depto == null) return [];

  final res = await LocationService.obtenerCiudades(depto.nombre);
  listCiudades
    ..clear()
    ..addAll(res);

  return res;
});

final locationControllerProvider =
    StateNotifierProvider<LocationController, bool>((ref) {
  return LocationController(ref);
});


/// CONTROLLER PRO
class LocationController extends StateNotifier<bool> {
  final Ref ref;
  LocationController(this.ref) : super(false);

  Future<void> preloadLocation({
    required String pais,
    required String departamento,
    required String ciudad,
  }) async {
    state = true;

    // PAÍSES
    final paises = await ref.read(paisesProvider.future);
    final paisObj = paises.firstWhere(
      (p) => p.nombre == pais,
      orElse: () => paises.first,
    );
    ref.read(paisSeleccionadoProvider.notifier).state = paisObj;

    // DEPARTAMENTOS
    final departamentos = await ref.read(departamentosProvider.future);
    final deptoObj = departamentos.firstWhere(
      (d) => d.nombre == departamento,
      orElse: () => departamentos.first,
    );
    ref.read(departamentoSeleccionadoProvider.notifier).state = deptoObj;

    // CIUDADES
    final ciudades = await ref.read(ciudadesProvider.future);
    final ciudadObj = ciudades.firstWhere(
      (c) => c.nombre == ciudad,
      orElse: () => ciudades.first,
    );
    ref.read(ciudadSeleccionadaProvider.notifier).state = ciudadObj;

    state = false;
  }
}
