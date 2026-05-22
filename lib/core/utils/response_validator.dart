String? extractMessage(dynamic response, {String? rootKey}) {
  if (response == null) return null;

  // Si viene anidado en una clave raíz
  if (rootKey != null && response is Map && response[rootKey] != null) {
    final inner = response[rootKey];
    if (inner is Map && inner['mensaje'] != null) return inner['mensaje']?.toString();
    if (inner is Map && inner['message'] != null) return inner['message']?.toString();
    if (inner is String) return inner;
  }

  if (response is Map) {
    if (response.containsKey('mensaje')) return response['mensaje']?.toString();
    if (response.containsKey('message')) return response['message']?.toString();

    // Buscar en un nivel dentro del map
    for (final v in response.values) {
      if (v is Map && v.containsKey('mensaje')) return v['mensaje']?.toString();
      if (v is Map && v.containsKey('message')) return v['message']?.toString();
    }
  }

  if (response is String) return response;

  return null;
}

bool isErrorMessage(String mensaje) {
  final m = mensaje.toLowerCase();
  return m.contains('error') || m.startsWith('error:');
}
