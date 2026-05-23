class Order {
  final String id;
  final String mesaId;
  final int comensales;
  final List<OrderItem> items;
  final String estado;
  final double subtotal;
  final double propina;
  final double iva;
  final double total;


  Order({
    required this.id,
    required this.mesaId,
    required this.items,
    required this.comensales,
    required this.estado,
    required this.subtotal,
    required this.propina,
    required this.iva,
    required this.total,
  });

  Order copyWith({
    String? id,
    String? mesaId,
    List<OrderItem>? items,
    int? comensales,
    String? estado,
    double? subtotal,
    double? propina,
    double? iva,
    double? total,
  }) {
    return Order(
      id: id ?? this.id,
      mesaId: mesaId ?? this.mesaId,
      items: items ?? this.items,
      comensales: comensales ?? this.comensales,
      estado: estado ?? this.estado,
      subtotal: subtotal ?? this.subtotal,
      propina: propina ?? this.propina,
      iva: iva ?? this.iva,
      total: total ?? this.total,
    );
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      mesaId: json['mesa_id'],
      items: (json['items'] as List)
        .map((item) => OrderItem.fromJson(item))
        .toList(),
      comensales: json['numero_personas'],
      estado: json['estado'],
      subtotal: double.parse(json['subtotal'].toString()),
      propina: double.parse(json['propina'].toString()),
      iva: double.parse(json['iva'].toString()),
      total: double.parse(json['total'].toString()),
    );
  }
}

class OrderItem {
  final String id;
  final String nombre;
  final int cantidad;
  final double precioUnitario;
  final double total;

  OrderItem({
    required this.id,
    required this.nombre,
    required this.cantidad,
    required this.precioUnitario,
    required this.total,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      nombre: json['nombre'],
      cantidad: json['cantidad'],
      precioUnitario: double.parse(json['precio_unitario'].toString()),
      total: double.parse(json['total'].toString()),
    );
  }
}

class tableOrders {
  final String mesaId;
  final int number;
  final String nombre;
  final int comensales;

  tableOrders({
    required this.mesaId,
    required this.number,
    required this.nombre,
    required this.comensales,
  });
}