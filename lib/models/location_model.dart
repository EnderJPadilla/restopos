class Location {
  final String id;
  final String nombre;

  Location({
    required this.id,
    required this.nombre,
  });

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is Location && id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json["id"].toString(),
      nombre: json["nombre"],
    );
  }
}
