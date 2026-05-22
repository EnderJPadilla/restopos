class Usuario {
  // personal
  final String usuarioId;
  final String empleadoId;
  final String nombres;
  final String apellidos;
  final String tipoDocumento;
  final String numeroDocumento;
  final String correo;
  final String telefono;
  final DateTime? fechaNacimiento;
  final bool activo;
  final String? genero;
  final String? pais;
  final String? departamento;
  final String? ciudad;
  final String? direccion;
  final String? nombreContactoEmergencia;
  final String? telefonoContactoEmergencia;
  final String? parentescoContactoEmergencia;

  // empleo
  // final String skuEmpleado;
  final String? departamentoEmpleado;
  final String? cargoEmpleado;
  final String? tipoContrato;
  final DateTime? fechaIngreso;
  final DateTime? fechaRetiro;
  // Datos bancarios
  final double? salario;
  final String? periodoPago;
  final String? banco;
  // final String titularCuenta;
  final String? numeroCuenta;
  // final String tipoCuenta;

  // Datos de acceso
  final String nombreUsuario;
  // final String password;
  final String rol;
  final bool cambioPin;
  final bool eliminado;
  final DateTime fechaCreacion;

  // Permisos
  final Map<String, dynamic>? permisos;

  Usuario({
    // Personal
    required this.usuarioId,
    required this.empleadoId,
    required this.nombres,
    required this.apellidos,
    required this.tipoDocumento,
    required this.numeroDocumento,
    required this.correo,
    required this.telefono,
    required this.fechaNacimiento,
    required this.activo,
    this.genero,
    this.pais,
    this.departamento,
    this.ciudad,
    this.direccion,
    this.nombreContactoEmergencia,
    this.telefonoContactoEmergencia,
    this.parentescoContactoEmergencia,
    // Empleo
    // required this.skuEmpleado,
    this.departamentoEmpleado,
    this.cargoEmpleado,
    this.tipoContrato,
    this.fechaIngreso,
    this.fechaRetiro,
    // Datos bancarios
    this.salario,
    this.periodoPago,
    this.banco,
    // required this.titularCuenta,
    this.numeroCuenta,
    // required this.tipoCuenta,
    // Datos de acceso
    required this.nombreUsuario, 
    required this.rol, 
    // required this.password, 
    required this.cambioPin,
    required this.eliminado,
    required this.fechaCreacion,
    // Permisos
    this.permisos,
  });

  Usuario copyWith({
    String? usuarioId,
    String? empleadoId,
    String? nombres,
    String? apellidos,
    String? tipoDocumento,
    String? numeroDocumento,
    String? correo,
    String? telefono,
    DateTime? fechaNacimiento,
    String? genero,
    String? pais,
    String? departamento,
    String? ciudad,
    String? direccion,
    String? nombreContactoEmergencia,
    String? telefonoContactoEmergencia,
    String? parentescoContactoEmergencia,
    bool? activo,
    // Empleo
    // String? skuEmpleado,
    String? departamentoEmpleado,
    String? cargoEmpleado,
    String? tipoContrato,
    DateTime? fechaIngreso,
    DateTime? fechaRetiro,
    // Datos bancarios
    double? salario,
    String? periodoPago,
    String? banco,
    // String? titularCuenta,
    String? numeroCuenta,
    // String? tipoCuenta,
    // Datos de acceso
    String? nombreUsuario, 
    String? rol, 
    // String? password, 
    bool? cambioPin, 
    bool? eliminado,
    DateTime? fechaCreacion,
    // Permisos
    Map<String, dynamic>? permisos
  }) {
    return Usuario(
      usuarioId: usuarioId ?? this.usuarioId,
      empleadoId: empleadoId ?? this.empleadoId,
      nombres: nombres ?? this.nombres,
      apellidos: apellidos ?? this.apellidos,
      tipoDocumento: tipoDocumento ?? this.tipoDocumento,
      numeroDocumento: numeroDocumento ?? this.numeroDocumento,
      correo: correo ?? this.correo,
      telefono: telefono ?? this.telefono,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      activo: activo ?? this.activo,
      genero: genero ?? this.genero,
      pais: pais ?? this.pais,
      departamento: departamento ?? this.departamento,
      ciudad: ciudad ?? this.ciudad,
      direccion: direccion ?? this.direccion,
      nombreContactoEmergencia: nombreContactoEmergencia ?? this.nombreContactoEmergencia,
      telefonoContactoEmergencia: telefonoContactoEmergencia ?? this.telefonoContactoEmergencia,
      parentescoContactoEmergencia: parentescoContactoEmergencia ?? this.parentescoContactoEmergencia,
      // Empleo
      // skuEmpleado: skuEmpleado ?? this.skuEmpleado, 
      departamentoEmpleado: departamentoEmpleado ?? this.departamentoEmpleado, 
      cargoEmpleado: cargoEmpleado ?? this.cargoEmpleado, 
      tipoContrato: tipoContrato ?? this.tipoContrato, 
      fechaIngreso: fechaIngreso ?? this.fechaIngreso,
      fechaRetiro: fechaRetiro ?? this.fechaRetiro,
      salario: salario ?? this.salario,
      periodoPago: periodoPago ?? this.periodoPago,
      banco: banco ?? this.banco,
      // titularCuenta: titularCuenta ?? this.titularCuenta,
      numeroCuenta: numeroCuenta ?? this.numeroCuenta,
      // tipoCuenta: tipoCuenta ?? this.tipoCuenta,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario, 
      rol: rol ?? this.rol, 
      // password: password ?? this.password, 
      cambioPin: cambioPin ?? this.cambioPin,
      eliminado: eliminado ?? this.eliminado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      permisos: permisos ?? this.permisos,
    );
  }

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    usuarioId: json["usuario_id"],
    empleadoId: json["empleado_id"],
    nombres: json["nombres"],
    apellidos: json["apellidos"],
    tipoDocumento: json["tipo_documento"],
    numeroDocumento: json["numero_documento"],
    correo: json["correo"],
    telefono: json["telefono"],
    fechaNacimiento: json["fecha_nacimiento"] != null 
      ? DateTime.parse(json["fecha_nacimiento"]) 
      : DateTime(1900, 1, 1),
    activo: json["activo"],
    genero: json["genero"],
    pais: json["pais"],
    departamento: json["departamento"],
    ciudad: json["ciudad"],
    direccion: json["direccion"],
    nombreContactoEmergencia: json["nombre_contacto_emergencia"],
    telefonoContactoEmergencia: json["telefono_contacto_emergencia"],
    parentescoContactoEmergencia: json["parentesco_contacto_emergencia"],
    // Empleo
    // skuEmpleado: json["sku_empleado"],
    departamentoEmpleado: json["departamento_empleado"],
    cargoEmpleado: json["cargo_empleado"],
    tipoContrato: json["tipo_contrato"],
    fechaIngreso: json["fecha_ingreso"] != null ? DateTime.parse(json["fecha_ingreso"]) : null,
    fechaRetiro: json["fecha_retiro"] != null ? DateTime.parse(json["fecha_retiro"]) : null,
    // Datos bancarios
    salario: json["salario"] != null ? (json["salario"] as num).toDouble() : null,
    periodoPago: json["periodo_pago"],
    banco: json["banco"],
    // titularCuenta: json["titular_cuenta"],
    numeroCuenta: json["numero_cuenta"],
    // tipoCuenta: json["tipo_cuenta"],
    // Datos de acceso
    nombreUsuario: json["nombre_usuario"], 
    rol: json["rol"], 
    // password: '', // No se incluye en la respuesta por seguridad
    cambioPin: json["cambio_pin"] ?? false,
    eliminado: json["eliminado"] ?? false,
    fechaCreacion: DateTime.parse(json["fecha_creacion"]),
    // Permisos
    permisos: json['permisos'],
  );

}


class Permiso {
  final String key;
  final bool activo;

  Permiso({
    required this.key,
    required this.activo,
  });

  Permiso copyWith({
    String? key,
    bool? activo,
  }) {
    return Permiso(
      key: key ?? this.key,
      activo: activo ?? this.activo,
    );
  }

  factory Permiso.fromJson(Map<String, dynamic> json) => Permiso(
    key: json["key"],
    activo: json["activo"],
  );

  Map<String, dynamic> toJson() => {
    "key": key,
    "activo": activo,
  };

}
