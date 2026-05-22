import 'package:flutter/material.dart';
import 'package:restopos/models/location_model.dart';
import 'package:restopos/widget/app_inputs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restopos/providers/location_provider.dart';

class GeneralTab extends ConsumerStatefulWidget {

  // Personal
  final TextEditingController nombresController;
  final TextEditingController apellidosController;
  final TextEditingController correoController;
  final TextEditingController telefonoController;

  final DateTime? fechaNacimiento;
  final ValueChanged<DateTime?> onFechaNacimientoChanged;
  
  final bool activo;
  final ValueChanged<bool> onActivoChanged;

  final List<String> generos;
  final String? generoSeleccionado;
  final ValueChanged<String?> onGeneroChanged;

  final List<String> tiposDocumentos;
  final String? tipoDocumentoSeleccionado;
  final TextEditingController numeroDocumentoController;
  final ValueChanged<String?> onTipoDocumentoChanged;

  // Dirección
  final TextEditingController direccionController;
  final String? paisSeleccionado;
  final String? ciudadSeleccionada;
  final String? departamentoSeleccionado;
  final ValueChanged<String?> onPaisChanged;
  final ValueChanged<String?> onCiudadChanged;
  final ValueChanged<String?> onDepartamentoChanged;

  // Emergencia
  final TextEditingController nombreContactoEmergenciaController;
  final TextEditingController telefonoContactoEmergenciaController;
  final List<String> parentescos;
  final String? parentescoSeleccionado;
  final ValueChanged<String?> onParentescoChanged;


  const GeneralTab({
    super.key,
    // Personal
    required this.nombresController,
    required this.apellidosController,
    required this.correoController,
    required this.telefonoController,
    required this.fechaNacimiento,
    required this.onFechaNacimientoChanged,
    required this.activo,
    required this.onActivoChanged,
    required this.generos,
    required this.generoSeleccionado,
    required this.onGeneroChanged,
    required this.tiposDocumentos,
    required this.tipoDocumentoSeleccionado,
    required this.numeroDocumentoController,
    required this.onTipoDocumentoChanged,

    // Direccion
    required this.direccionController,
    required this.paisSeleccionado,
    required this.ciudadSeleccionada,
    required this.departamentoSeleccionado,
    required this.onPaisChanged,
    required this.onCiudadChanged,
    required this.onDepartamentoChanged, 
    // Emergencia
    required this.nombreContactoEmergenciaController,
    required this.telefonoContactoEmergenciaController,
    required this.parentescos,
    required this.parentescoSeleccionado,
    required this.onParentescoChanged,
  });

  @override
  ConsumerState<GeneralTab> createState() => _GeneralTabState();
}


class _GeneralTabState extends ConsumerState<GeneralTab>
  with AutomaticKeepAliveClientMixin {

  late final TextEditingController _fechaNacimientoController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    /// Inicializar fechas
    _fechaNacimientoController = TextEditingController(
      text: widget.fechaNacimiento != null
      ? _formatDate(widget.fechaNacimiento!)
      : '',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller = ref.read(locationControllerProvider.notifier);

      if (widget.paisSeleccionado != null &&
          widget.departamentoSeleccionado != null &&
          widget.ciudadSeleccionada != null
      ) {
        await controller.preloadLocation(
          pais: widget.paisSeleccionado!,
          departamento: widget.departamentoSeleccionado!,
          ciudad: widget.ciudadSeleccionada!,
        );
      }
    });

  }

  @override
  void didUpdateWidget(covariant GeneralTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si la fecha de nacimiento cambió desde el padre (por ejemplo al entrar en modo edición), actualizar el controlador
    if (oldWidget.fechaNacimiento != widget.fechaNacimiento) {
      _fechaNacimientoController.text = widget.fechaNacimiento != null
        ? _formatDate(widget.fechaNacimiento!)
        : '';
    }
  }

  @override
  void dispose() {
    _fechaNacimientoController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/'
    '${date.year}';

  @override
  Widget build(BuildContext context) {
    super.build(context);
  
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF121821),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionCard(
              title: "Información Personal",
              subtitle: "Datos básicos del empleado",
              icon: Icons.person,
              child: _personalForm(context),
            ),
            const SizedBox(height: 20),
            _sectionCard(
              title: "Dirección",
              subtitle: "Datos básicos del empleado",
              icon: Icons.location_on,
              child: _direccionForm(context),
            ),
            const SizedBox(height: 20),
            _sectionCard(
              title: "Contacto de Emergencia",
              subtitle: "Persona a contactar en caso de emergencia",
              icon: Icons.health_and_safety_rounded,
              child: _emergenciaForm(context),
            ),
          ],
        ),
      ),
    );
  }


  Widget _sectionTitle( 
    String text, 
    { required IconData icon}
  ) =>
  Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(title, icon: icon),
        if (subtitle.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              subtitle,
              style: const TextStyle(color: Colors.white54)
            ),
          ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }


  Widget _personalForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: appTextInput(
                controller: widget.nombresController,
                label: 'Nombres *',
                hint: 'Ej: Carlos Alberto',
                validator: (v) =>
                  v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: appTextInput(
                controller: widget.apellidosController,
                label: 'Apellidos *',
                hint: 'Ej: Pérez Gómez',
                validator: (v) =>
                  v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: widget.tipoDocumentoSeleccionado,
                items: widget.tiposDocumentos
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c, style: const TextStyle(color: Colors.white)),
                    ),
                  )
                  .toList(),
                onChanged: widget.onTipoDocumentoChanged,
                validator: (v) =>
                  v == null ? 'Seleccione tipo de documento' : null,
                decoration: appDecoration('Tipo de Documento *'),
                dropdownColor: const Color(0xFF0B0F14),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: appIntInput(
                controller: widget.numeroDocumentoController,
                label: 'Número de Documento *',
                hint: 'Ej: 123456789',
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo requerido';
                  return null;
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: appTextInput(
                controller: widget.correoController,
                label: 'Correo Electrónico',
                hint: 'Ej: carlos.perez@example.com',
                // validator: (v) {
                //   if (v == null || v.isEmpty) return 'Campo requerido';
                //   if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                //     return 'Correo inválido';
                //   }
                //   return null;
                // },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: appIntInput(
                controller: widget.telefonoController,
                label: 'Teléfono *',
                hint: 'Ej: 312-555-1234',
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo requerido';
                  if (!RegExp(r'^\d{3}-\d{3}-\d{4}$').hasMatch(v)) {
                    return 'Formato de teléfono inválido (Ej: 312-555-1234)';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: appDateInput(
                context: context,
                controller: _fechaNacimientoController,
                label: 'Fecha de Nacimiento',
                onDateSelected: (date) {
                  _fechaNacimientoController.text = _formatDate(date);
                  widget.onFechaNacimientoChanged(date);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: widget.generoSeleccionado,
                items: widget.generos
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c, style: const TextStyle(color: Colors.white)),
                    ),
                  )
                  .toList(),
                onChanged: widget.onGeneroChanged,
                validator: (v) =>
                  v == null ? 'Seleccione un género' : null,
                decoration: appDecoration('Género *'),
                dropdownColor: const Color(0xFF0B0F14),
              ),
            )
          ],
        ),
        
      ],
    );
  }

  Widget _direccionForm(BuildContext context) {

    final paises = ref.watch(paisesProvider);
    final departamentos = ref.watch(departamentosProvider);
    final ciudades = ref.watch(ciudadesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: appTextInput(
                controller: widget.direccionController,
                label: 'Dirección *',
                hint: 'Ej: Cra / Calle 45 #123-45',
                validator: (v) =>
                  v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<Location>(
                value: ref.watch(paisSeleccionadoProvider),
                items: paises.when(
                  data: (list) => list.map((p) {
                    return DropdownMenuItem<Location>(
                      value: p,
                      child: Text(
                        p.nombre,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  loading: () => [],
                  error: (_, __) => [],
                ),
                onChanged: (value) {
                  ref.read(paisSeleccionadoProvider.notifier).state = value;
                  ref.read(departamentoSeleccionadoProvider.notifier).state = null;
                  ref.read(ciudadSeleccionadaProvider.notifier).state = null;
                },
                validator: (v) => v == null ? 'Seleccione un país' : null,
                decoration: appDecoration('País *'),
                dropdownColor: const Color(0xFF0B0F14),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<Location>(
                value: ref.watch(departamentoSeleccionadoProvider),
                items: departamentos.when(
                  data: (list) => list.map((p) {
                    return DropdownMenuItem<Location>(
                      value: p,
                      child: Text(
                        p.nombre,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  loading: () => [],
                  error: (_, __) => [],
                ),
                onChanged: (value) {
                  ref.read(departamentoSeleccionadoProvider.notifier).state = value;
                  ref.read(ciudadSeleccionadaProvider.notifier).state = null;
                },
                validator: (v) => v == null ? 'Seleccione un Departamento' : null,
                decoration: appDecoration('Departamento *'),
                dropdownColor: const Color(0xFF0B0F14),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<Location>(
                value: ref.watch(ciudadSeleccionadaProvider),
                items: ciudades.when(
                  data: (list) => list.map((p) {
                    return DropdownMenuItem<Location>(
                      value: p,
                      child: Text(
                        p.nombre,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  loading: () => [],
                  error: (_, __) => [],
                ),
                onChanged: (value) {
                  ref.read(ciudadSeleccionadaProvider.notifier).state = value;
                },
                validator: (v) => v == null ? 'Seleccione una ciudad' : null,
                decoration: appDecoration('Ciudad *'),
                dropdownColor: const Color(0xFF0B0F14),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _emergenciaForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: appTextInput(
                controller: widget.nombreContactoEmergenciaController,
                label: 'Nombre Completo *',
                hint: 'Ej: María López',
                validator: (v) =>
                  v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: appIntInput(
                controller: widget.telefonoContactoEmergenciaController,
                label: 'Teléfono *',
                hint: 'Ej: 312-555-1234',
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo requerido';
                  if (!RegExp(r'^\d{3}-\d{3}-\d{4}$').hasMatch(v)) {
                    return 'Formato de teléfono inválido (Ej: 312-555-1234)';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: widget.parentescoSeleccionado,
                items: widget.parentescos
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c, style: const TextStyle(color: Colors.white)),
                    ),
                  )
                  .toList(),
                onChanged: widget.onParentescoChanged,
                validator: (v) =>
                  v == null ? 'Seleccione un parentesco' : null,
                decoration: appDecoration('Parentesco *'),
                dropdownColor: const Color(0xFF0B0F14),
              ),
            ),
          ],
        ),
      ],
    );
  }



}