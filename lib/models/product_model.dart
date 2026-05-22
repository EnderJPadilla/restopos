class Producto {
  final String id;
  final String nombre;
  final String sku;
  final String barcode;
  final String descripcionCorta;
  final String descripcion;
  final String categoria;
  final String icono;
  final bool disponible;
  final List<String> tags;
  final DateTime fecha_actualizacion;

  final bool impuestoIncluido;
  final double costo;
  final double precio;
  final int tasaImpuesto;
  final double precioDespuesImpuesto;
  final double precioEspecial;
  
  final bool controlarInventario;
  final int stockActual;
  final int stockMinimo;
  final String unidadMedida;

  final int tiempoPreparacion;
  final String areaPreparacion;
  final String notasPreparacion;
  final List<String> impresoras;
  
  final bool destacado;
  final bool mostrarPos;
  final bool mostrarOnline;

  Producto({
    required this.id,
    required this.nombre,
    required this.sku,
    required this.barcode,
    required this.descripcionCorta,
    required this.descripcion,
    required this.categoria,
    required this.icono,
    required this.disponible,
    required this.tags,
    required this.fecha_actualizacion,
    
    required this.costo,
    required this.precio,
    required this.impuestoIncluido,
    required this.tasaImpuesto,
    required this.precioDespuesImpuesto,
    required this.precioEspecial,

    required this.controlarInventario,
    required this.stockActual,
    required this.stockMinimo,
    required this.unidadMedida,

    required this.tiempoPreparacion,
    required this.areaPreparacion,
    required this.impresoras,
    required this.notasPreparacion,
    
    required this.destacado,
    required this.mostrarPos,
    required this.mostrarOnline,
  });

  Producto copyWith({
    bool? disponible,
  }) {
    return Producto(
      id: id,
      nombre: nombre,
      sku: sku,
      barcode: barcode,
      descripcionCorta: descripcionCorta,
      descripcion: descripcion,
      categoria: categoria,
      disponible: disponible ?? this.disponible,
      icono: icono,
      tags: tags,
      fecha_actualizacion: fecha_actualizacion,
      
      costo: costo,
      precio: precio,
      impuestoIncluido: impuestoIncluido,
      tasaImpuesto: tasaImpuesto,
      precioDespuesImpuesto: precioDespuesImpuesto,
      precioEspecial: precioEspecial,
      
      controlarInventario: controlarInventario,
      stockActual: stockActual,
      stockMinimo: stockMinimo,
      unidadMedida: unidadMedida,

      tiempoPreparacion: tiempoPreparacion,
      areaPreparacion: areaPreparacion,
      impresoras: impresoras,
      notasPreparacion: notasPreparacion,

      destacado: destacado,
      mostrarPos: mostrarPos,
      mostrarOnline: mostrarOnline,
    );
  }

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['producto_id'],
      nombre: json['nombre'],
      sku: json['sku'],
      barcode: json['barcode'] ?? '',
      descripcionCorta: json['descripcion_corta'] ?? '',
      descripcion: json['descripcion'] ?? '',
      categoria: json['categoria'] ?? '',
      icono: json['icono'] ?? 'default',
      disponible: json['disponible'] ?? true,
      tags: List<String>.from(json['tags'] ?? []),
      fecha_actualizacion: DateTime.parse(json['fecha_actualizado']),

      costo: (json['costo'] as num?)?.toDouble() ?? 0,
      precio: (json['precio_venta'] as num?)?.toDouble() ?? 0,
      impuestoIncluido: json['impuesto_incluido'] ?? true,
      tasaImpuesto: (json['tasa_impuesto'] as num?)?.toInt() ?? 0,
      precioDespuesImpuesto: (json['precio_con_impuesto'] as num?)?.toDouble() ?? 0,
      precioEspecial: (json['precio_especial'] as num?)?.toDouble() ?? 0,

      controlarInventario: json['controlar_inventario'] ?? false,
      stockActual: (json['stock_actual'] as num?)?.toInt() ?? 0,
      stockMinimo: (json['stock_minimo'] as num?)?.toInt() ?? 0,
      unidadMedida: json['unidad_medida'] ?? 'Pieza',

      tiempoPreparacion: (json['tiempo_preparacion'] as num?)?.toInt() ?? 0,
      areaPreparacion: json['area_preparacion'] ?? '',
      impresoras: (json['impresoras'] as List?)?.map((e) => e.toString()).toList() ?? [],
      notasPreparacion: json['notas_preparacion'] ?? '',

      destacado: json['destacado'] ?? false,
      mostrarPos: json['mostrarPos'] ?? true,
      mostrarOnline: json['mostrarOnline'] ?? true,
    );
  }

}



class PedidoItem {
  final Producto producto;
  int cantidad;

  PedidoItem({
    required this.producto,
    this.cantidad = 1
  });
}