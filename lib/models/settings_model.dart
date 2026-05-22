class Setting {
  final int impuesto;
  final int propina;
  final String moneda;
  final bool descuentos;
  final bool redondearTotales;
  final bool impresion;

  Setting({
    required this.impuesto,
    required this.propina,
    required this.moneda,
    required this.descuentos,
    required this.redondearTotales,
    required this.impresion
  });

  Setting copyWith({
    int impuesto = 0,
    int propina = 0,
    String moneda = '',
    bool descuentos = false,
    bool redondearTotales = false,
    bool impresion = false
  }) {
    return Setting(
      impuesto: impuesto,
      propina: propina,
      moneda: moneda,
      descuentos: descuentos,
      redondearTotales: redondearTotales,
      impresion: impresion
    );
  }

  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
      impuesto: json["impuesto_porcentaje"] ?? 0,
      propina: json["propina_porcentaje"] ?? 0,
      moneda: json["moneda"],
      descuentos: json["permite_descuentos"] ?? false,
      redondearTotales: json["redondear_totales"] ?? false,
      impresion: json["imprimir_tickets"] ?? false,
    );
  }
}
