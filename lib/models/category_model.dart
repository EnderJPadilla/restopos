class Category {
  final String id;
  final String nombre;
  final String descripcion;
  final bool activo;
  final int numeroProductos;

  Category({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.activo,
    required this.numeroProductos
  });

  Category copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    bool? activo,
  }) {
    return Category(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      activo: activo ?? this.activo,
      numeroProductos: numeroProductos ?? this.numeroProductos
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is Category && id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json["id"].toString(),
      nombre: json["nombre"],
      descripcion: json["descripcion"],
      activo: json["activo"] ?? false,
      numeroProductos: json["numero_productos"] ?? 0
    );
  }
}
