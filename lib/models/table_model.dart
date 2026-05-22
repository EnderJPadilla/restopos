
enum TableStatus { disponible, ocupada, reservada }

class TableModel {
  final String id;
  final int number;
  final String? name;
  final int maximumCapacity;
  final TableStatus status;
  final bool activo;
  final bool booking;

  TableModel({
    required this.id,
    required this.number,
    this.name,
    required this.maximumCapacity,
    required this.status,
    required this.activo,
    required this.booking,
  });

  TableModel copyWith({
    String? id,
    int? number,
    String? name,
    int? maximumCapacity,
    TableStatus? status,
    bool? activo,
    bool? booking,
  }) {
    return TableModel(
      id: id ?? this.id,
      number: number ?? this.number,
      name: name ?? this.name,
      maximumCapacity: maximumCapacity ?? this.maximumCapacity,
      status: status ?? this.status,
      activo: activo ?? this.activo,
      booking: booking ?? this.booking,
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is TableModel && id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json["id"].toString(),
      number: json["numero"],
      name: json["nombre"],
      maximumCapacity: json["capacidad"],
      status: json["estatus"] == "disponible"
          ? TableStatus.disponible
          : json["estatus"] == "ocupada"
              ? TableStatus.ocupada
              : TableStatus.reservada,
      activo: json["activo"] ?? false,
      booking: json["booking"] ?? false
    );
  }

}
