import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restopos/providers/users_provider.dart';
import 'package:restopos/providers/location_provider.dart';
import 'package:restopos/models/usuario_model.dart';

import 'package:restopos/screen/administrator/users/tabs/general_tab.dart';
import 'package:restopos/screen/administrator/users/tabs/empleo_tab.dart';
import 'package:restopos/screen/administrator/users/tabs/acceso_tab.dart';
import 'package:restopos/screen/administrator/users/tabs/permisos_tab.dart';

// final rolSeleccionadoProvider = StateProvider<String>((ref) => "");

class NewUserScreen extends ConsumerStatefulWidget {
  const NewUserScreen({super.key});

  @override
  ConsumerState<NewUserScreen> createState() => _NewUserScreenState();
}

class _NewUserScreenState extends ConsumerState<NewUserScreen> {
  final _formKey = GlobalKey<FormState>();

  String _text(String? v) => v ?? '';
  // String _int(int? v) => (v ?? 0).toString();
  String _double(double? v) => (v ?? 0).toString();

  // General
  final nombresController = TextEditingController();
  final apellidosController = TextEditingController();
  final correoController = TextEditingController();
  final telefonoController = TextEditingController();
  DateTime? fechaNacimientoController;
  bool activo = true;
  final generos = ['Masculino', 'Femenino', 'Otro'];
  String? generoSeleccionado;
  final tiposDocumentos = ['CC', 'CE', 'PAS', 'PPT', 'PEP'];
  String? tipoDocumentoSeleccionado;
  final numeroDocumentoController = TextEditingController();
  // Dirección
  final direccionController = TextEditingController();
  String? paisSeleccionado;
  String? ciudadSeleccionada;
  String? departamentoSeleccionado;
  // Contacto de emergencia
  final nombreContactoEmergenciaController = TextEditingController();
  final telefonoContactoEmergenciaController = TextEditingController();
  String? parentescoSeleccionado;
  final parentescos = ['Padre', 'Madre', 'Hermano(a)', 'Cónyuge', 'Amigo(a)', 'Otro'];


  // Empleo
  // final skuController = TextEditingController();
  String? rolSeceleccionado;
  String? areaSeleccionada;
  DateTime? fechaIngresoController;
  final puestoController = TextEditingController();
  String? tipoContratoSeleccionado;
  final salarioController = TextEditingController();
  String? periodoPagoSeleccionado;
  String? bancoSeleccionado;
  final numeroCuentaController = TextEditingController();
  final puestoEmpleadoController = TextEditingController();
  
  final listRoles = ["Administrador", "Mesero", "Cajero"];
  final listAreas = ["Cocina", "Caja", "Mesas", "Administración"];
  final listTiposContrato = ["Indefinido", "Temporal", "Practicante", "Tiempo Completo", "Medio Tiempo"];
  final listBancos = ["Banco de la República", "Banco Popular", "Banco de Bogotá", "Bancolombia", "BBVA", "Davivienda"];
  final listPeriodosPago = ["Semanal", "Quincenal", "Mensual"];

  // Acceso
  final nombreUsuarioController = TextEditingController();
  String? rolSeleccionado;
  final pinSecretController = TextEditingController();
  bool cambioPin = false;
  String? onRolChanged;
  bool onCambioPinChanged = true;

  // Permisos
  // Map<String, List<Permiso>>? permisosUsuario;
  Map<String, bool> permisosUsuario = {};

  // modo editar
  bool isEditMode = false;
  String? empleadoId;
  String? usuarioId;


  @override
  void initState() {
    super.initState();

    final usuarioSeleccionado = ref.read(selectedUserProvider);
    if (usuarioSeleccionado == null) {
      _resetForm();
    } else {
      _cargarFrom(usuarioSeleccionado);
    }
  }

  void _resetForm() {
    // General
    nombresController.clear();
    apellidosController.clear();
    tipoDocumentoSeleccionado = null;
    numeroDocumentoController.clear();
    correoController.clear();
    telefonoController.clear();
    fechaNacimientoController = null;
    generoSeleccionado = null;

    direccionController.clear();
    paisSeleccionado = null;
    departamentoSeleccionado = null;
    ciudadSeleccionada = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paisSeleccionadoProvider.notifier).state = null;
      ref.read(departamentoSeleccionadoProvider.notifier).state = null;
      ref.read(ciudadSeleccionadaProvider.notifier).state = null;
    });

    nombreContactoEmergenciaController.clear();
    telefonoContactoEmergenciaController.clear();
    parentescoSeleccionado = null;
    activo = true;

    // Empleo
    // skuController.clear();
    areaSeleccionada = null;
    puestoController.clear();
    tipoContratoSeleccionado = null;
    fechaIngresoController = null;

    salarioController.clear();
    periodoPagoSeleccionado = null;
    bancoSeleccionado = null;
    numeroCuentaController.clear();
    // Acceso
    nombreUsuarioController.clear();
    rolSeleccionado = null;
    pinSecretController.clear();
    cambioPin = false;
    // Permisos
    permisosUsuario = <String, bool>{};

    // Edit mode
    isEditMode = false;
    empleadoId = null;

    setState(() {});
  }

  void _cargarFrom(usuario) {
    isEditMode = true;
    usuarioId = usuario.usuarioId;
    empleadoId = usuario.empleadoId;
    // print('Entrando en edición: ${isEditMode}');

    nombresController.text = _text(usuario.nombres);
    apellidosController.text = _text(usuario.apellidos);
    tipoDocumentoSeleccionado = usuario.tipoDocumento;
    numeroDocumentoController.text = _text(usuario.numeroDocumento);
    correoController.text = _text(usuario.correo);
    telefonoController.text = _text(usuario.telefono);
    fechaNacimientoController = usuario.fechaNacimiento;
    generoSeleccionado = usuario.genero;

    direccionController.text = _text(usuario.direccion);
    paisSeleccionado = usuario.pais;
    departamentoSeleccionado = usuario.departamento;
    ciudadSeleccionada = usuario.ciudad;

    nombreContactoEmergenciaController.text = _text(usuario.nombreContactoEmergencia);
    telefonoContactoEmergenciaController.text = _text(usuario.telefonoContactoEmergencia);
    parentescoSeleccionado = usuario.parentescoContactoEmergencia;
    activo = usuario.activo;

    // Empleo
    // skuController.text = _text(usuario.skuEmpleado);
    areaSeleccionada = usuario.departamentoEmpleado;
    puestoController.text = _text(usuario.cargoEmpleado);
    tipoContratoSeleccionado = usuario.tipoContrato;
    fechaIngresoController = usuario.fechaIngreso;

    salarioController.text = _double(usuario.salario);
    periodoPagoSeleccionado = usuario.periodoPago;
    bancoSeleccionado = usuario.banco;
    numeroCuentaController.text = _text(usuario.numeroCuenta);

    // Acceso
    nombreUsuarioController.text = _text(usuario.nombreUsuario);
    rolSeleccionado = usuario.rol;
    cambioPin = usuario.cambioPin;
    
    // Permisos
    permisosUsuario = (usuario.permisos as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, value == true),
    );
    
    setState(() {});
  }


  @override
  void dispose() {
    nombresController.dispose();
    apellidosController.dispose();
    correoController.dispose();
    telefonoController.dispose();
    numeroDocumentoController.dispose();
    direccionController.dispose();
    nombreContactoEmergenciaController.dispose();
    telefonoContactoEmergenciaController.dispose();
    // skuController.dispose();
    puestoController.dispose();
    salarioController.dispose();
    numeroCuentaController.dispose();
    nombreUsuarioController.dispose();
    pinSecretController.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditMode ? 'Editar Usuario' : 'Nuevo Usuario',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              const Text(
                'Complete la información del usuario',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          actions: [
            if (isEditMode)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                tooltip: 'Eliminar usuario',
                onPressed: _confirmarEliminarUsuario,
              ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                ref.read(selectedUserProvider.notifier).state = null;
                setState(() {
                  isEditMode = false;
                });
                context.go('/admin/users');
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white70)
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _guardarUsuario,
              icon: const Icon(Icons.save),
              label: Text(isEditMode ? 'Actualizar' : 'Guardar Usuario'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE49E22),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),

        body: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _tabs(),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: TabBarView(
                  children: [
                    GeneralTab(
                      nombresController: nombresController,
                      apellidosController: apellidosController,
                      correoController: correoController,
                      telefonoController: telefonoController,
                      fechaNacimiento: fechaNacimientoController,
                      activo: activo,
                      generos: generos,
                      generoSeleccionado: generoSeleccionado,
                      tiposDocumentos: tiposDocumentos,
                      tipoDocumentoSeleccionado: tipoDocumentoSeleccionado,
                      numeroDocumentoController: numeroDocumentoController,
                      direccionController: direccionController,
                      paisSeleccionado: paisSeleccionado,
                      ciudadSeleccionada: ciudadSeleccionada,
                      departamentoSeleccionado: departamentoSeleccionado,
                      nombreContactoEmergenciaController: nombreContactoEmergenciaController,
                      telefonoContactoEmergenciaController: telefonoContactoEmergenciaController,
                      parentescos: parentescos,
                      parentescoSeleccionado: parentescoSeleccionado,
                      onTipoDocumentoChanged: (tipo) => setState(() => tipoDocumentoSeleccionado = tipo),
                      onFechaNacimientoChanged: (date) => setState(() => fechaNacimientoController = date),
                      onActivoChanged: (v) => setState(() => activo = v),
                      onGeneroChanged: (genero) => setState(() => generoSeleccionado = genero),
                      onPaisChanged: (pais) => setState(() => paisSeleccionado = pais),
                      onDepartamentoChanged: (departamento) => setState(() => departamentoSeleccionado = departamento), 
                      onCiudadChanged: (ciudad) => setState(() => ciudadSeleccionada = ciudad),
                      onParentescoChanged: (parentesco) => setState(() => parentescoSeleccionado = parentesco),
                    ),
                    EmpleoTab(
                      // skuController: skuController,
                      areaSeleccionada: areaSeleccionada,
                      fechaIngreso: fechaIngresoController,
                      puestoController: puestoController,
                      tipoContratoSeleccionado: tipoContratoSeleccionado,
                      salarioController: salarioController,
                      periodoPagoSeleccionado: periodoPagoSeleccionado,
                      bancoSeleccionado: bancoSeleccionado,
                      numeroCuentaController: numeroCuentaController,

                      areas: listAreas,
                      tiposContrato: listTiposContrato,
                      bancos: listBancos,
                      periodosPago: listPeriodosPago,

                      onAreaChanged: (area) => setState(() => areaSeleccionada = area),
                      onTipoContratoChanged: (tipo) => setState(() => tipoContratoSeleccionado = tipo),
                      onBancoChanged: (banco) => setState(() => bancoSeleccionado = banco),
                      onPeriodoPagoChanged: (periodo) => setState(() => periodoPagoSeleccionado = periodo),
                      onFechaIngresoChanged: (date) => setState(() => fechaIngresoController = date),
                    ),
                    AccesoTab(
                      nombreUsuarioController: nombreUsuarioController,
                      rolSeleccionado: rolSeleccionado,
                      roles: listRoles,
                      pinSecretController: pinSecretController,
                      cambioPin: cambioPin,
                      isEditMode: isEditMode,
                      onRolChanged: (v) => setState(() => rolSeleccionado = v),
                      onCambioPinChanged: (v) => setState(() => cambioPin = v)
                    ),
                    PermisosTab(
                      permisos: permisosUsuario,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabs() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 430,
        height: 50,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF121821),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const TabBar(
          isScrollable: true,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: Color(0xEC0B0F14),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          tabs: [
            Tab(text: 'Personal'),
            Tab(text: 'Empleo'),
            Tab(text: 'Acceso'),
            Tab(text: 'Permisos'),
          ],
        ),
      ),
    );
  }

  Future<void> _guardarUsuario() async {
    final provider = ref.read(usersProvider);

    final payload = _buildUserPayload();

    final success = isEditMode
      ? await provider.actualizarUsuario(payload)
      : await provider.crearUsuario(payload);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Usuario guardado correctamente' : provider.error ?? 'Error'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      ref.invalidate(userProvider);
      context.go('/admin/users');
    }
  }

  Map<String, dynamic> _buildUserPayload() {
    
    final paisSeleccionado = ref.read(paisSeleccionadoProvider);
    final departamentoSeleccionado = ref.read(departamentoSeleccionadoProvider);
    final ciudadSeleccionada = ref.read(ciudadSeleccionadaProvider);
    final permisosUsuario = ref.read(permisosProvider);

    final permisosPlano = <String, bool>{};
    permisosUsuario.forEach((grupo, lista) {
      for (var p in lista) {
        permisosPlano[p.key] = p.activo;
      }
    });

    final salario = salarioController.text
      .replaceAll('.', '')
      .replaceAll('\$', '')
      .trim();

    return {
      'usuario_id': isEditMode ? usuarioId : null,
      'empleado_id': isEditMode ? empleadoId : null,
      'general': {
        'nombres': nombresController.text.trim(),
        'apellidos': apellidosController.text.trim(),
        'tipo_documento': tipoDocumentoSeleccionado,
        'numero_documento': numeroDocumentoController.text.trim(),
        'correo': correoController.text.trim(),
        'telefono': telefonoController.text.trim(),
        'fecha_nacimiento': fechaNacimientoController?.toIso8601String(),
        'genero': generoSeleccionado,
        'direccion': direccionController.text.trim(),
        'pais': paisSeleccionado?.nombre,
        'departamento': departamentoSeleccionado?.nombre,
        'ciudad': ciudadSeleccionada?.nombre,
        'nombre_contacto_emergencia': nombreContactoEmergenciaController.text.trim(),
        'telefono_contacto_emergencia': telefonoContactoEmergenciaController.text.trim(),
        'parentesco_contacto_emergencia': parentescoSeleccionado,
      },
      'empleo': {
        // 'sku': skuController.text.trim(),
        'area': areaSeleccionada,
        'fecha_ingreso': fechaIngresoController?.toIso8601String(),
        'puesto': puestoController.text.trim(),
        'tipo_contrato': tipoContratoSeleccionado,
        'salario': salario,
        'periodo_pago': periodoPagoSeleccionado,
        'banco': bancoSeleccionado,
        'numero_cuenta': numeroCuentaController.text.trim(),
      },
      'acceso': {
        'nombre_usuario': nombreUsuarioController.text.trim(),
        'rol': rolSeleccionado,
        'pin_secret': pinSecretController.text.trim(),
        'cambio_pin': cambioPin,
      },
      'permisos': permisosPlano,
    };
  }

  Future<void> _confirmarEliminarUsuario() async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text('Confirmar eliminación'),
            ],
          ),
          content: const Text(
            '¿Estás seguro de eliminar este Usuario?\n\nEsta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _eliminarUsuario();
    }
  }

  Future<void> _eliminarUsuario() async {
    final provider = ref.read(usersProvider);

    if (usuarioId == null) return;

    final success = await provider.eliminarUsuario(usuarioId!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Usuario eliminado' : provider.error ?? 'Error'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      ref.invalidate(userProvider);
      ref.read(selectedUserProvider.notifier).state = null;
      context.go('/admin/users');
    }
  }


}
