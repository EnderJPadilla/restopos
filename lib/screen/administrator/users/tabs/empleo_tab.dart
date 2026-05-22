import 'package:flutter/material.dart';
import 'package:restopos/widget/app_inputs.dart';

class EmpleoTab extends StatefulWidget {
  
  // final TextEditingController skuController;
  final String? areaSeleccionada;
  final List<String> areas;
  final TextEditingController puestoController;
  // final double? salario;
  final TextEditingController salarioController;
  final List<String> tiposContrato;
  final String? tipoContratoSeleccionado;
  final List<String> bancos;
  final String? bancoSeleccionado;
  final TextEditingController numeroCuentaController;
  final List<String> periodosPago;
  final String? periodoPagoSeleccionado;
  final DateTime? fechaIngreso;

  final ValueChanged<String?> onAreaChanged;
  final ValueChanged<String?> onTipoContratoChanged;
  final ValueChanged<String?> onBancoChanged;
  final ValueChanged<String?> onPeriodoPagoChanged;
  final ValueChanged<DateTime> onFechaIngresoChanged;

  const EmpleoTab({
    super.key,
    // required this.skuController,
    required this.areaSeleccionada,
    required this.areas,
    required this.puestoController,
    // required this.salario,
    required this.salarioController,
    required this.tiposContrato,
    required this.tipoContratoSeleccionado,
    required this.bancos,
    required this.bancoSeleccionado,
    required this.numeroCuentaController,
    required this.periodosPago,
    required this.periodoPagoSeleccionado,
    required this.fechaIngreso,
    
    required this.onAreaChanged,
    required this.onTipoContratoChanged,
    required this.onBancoChanged,
    required this.onPeriodoPagoChanged,
    required this.onFechaIngresoChanged,
  });

  @override
  State<EmpleoTab> createState() => _EmpleoTabState();
}

class _EmpleoTabState extends State<EmpleoTab>
  with AutomaticKeepAliveClientMixin {

  late final TextEditingController _fechaIngresoController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    /// Inicializar fechas
    _fechaIngresoController = TextEditingController(
      text: widget.fechaIngreso != null
      ? _formatDate(widget.fechaIngreso!)
      : '',
    );
  }

  @override
  void didUpdateWidget(covariant EmpleoTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Sincronizar controlador de fecha si cambió desde el padre
    if (oldWidget.fechaIngreso != widget.fechaIngreso) {
      _fechaIngresoController.text = widget.fechaIngreso != null
        ? _formatDate(widget.fechaIngreso!)
        : '';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/'
    '${date.year}';
    
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF121821),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _datosLaboralesCard(context),
          const SizedBox(height: 20),
          _salarioBancariosCard(context),
        ],
      ),
    );
  }

  _datosLaboralesCard(BuildContext context) {
    return _baseCard(
      title: "Datos Laborales",
      subtitle: "Información sobre el empleo del usuario",
      icon: Icons.work_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Expanded(
              //   child: appTextInput(
              //     controller: widget.skuController,
              //     label: 'Sku de Empleado *',
              //     hint: 'Ej: EMP-001',
              //     validator: (v) =>
              //       v == null || v.isEmpty ? 'Campo requerido' : null,
              //   ),
              // ),
              // const SizedBox(width: 16),
              // Expanded(
              //   child: DropdownButtonFormField<String>(
              //     value: widget.rolSeleccionado,
              //     items: widget.roles
              //       .map(
              //         (c) => DropdownMenuItem(
              //           value: c,
              //           child: Text(c, style: const TextStyle(color: Colors.white)),
              //         ),
              //       )
              //       .toList(),
              //     onChanged: widget.onRolChanged,
              //     validator: (v) =>
              //       v == null ? 'Seleccione un rol' : null,
              //     decoration: appDecoration('Rol en el Sistema *'),
              //     dropdownColor: const Color(0xFF0B0F14),
              //   ),
              // ),              
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: widget.areaSeleccionada,
                  items: widget.areas
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c, style: const TextStyle(color: Colors.white)),
                      ),
                    )
                    .toList(),
                  onChanged: widget.onAreaChanged,
                  validator: (v) =>
                    v == null ? 'Seleccione un area' : null,
                  decoration: appDecoration('Area del usuario *'),
                  dropdownColor: const Color(0xFF0B0F14),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: appTextInput(
                  controller: widget.puestoController,
                  label: 'Puesto *',
                  hint: 'Ej: Mesero Senior',
                  validator: (v) =>
                    v == null || v.isEmpty ? 'Campo requerido' : null,
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: widget.tipoContratoSeleccionado,
                  items: widget.tiposContrato
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c, style: const TextStyle(color: Colors.white)),
                      ),
                    )
                    .toList(),
                  onChanged: widget.onTipoContratoChanged,
                  validator: (v) =>
                    v == null ? 'Tipo de Contrato requerido' : null,
                  decoration: appDecoration('Tipo de Contrato *'),
                  dropdownColor: const Color(0xFF0B0F14),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: appDateInput(
                  context: context,
                  controller: _fechaIngresoController,
                  label: 'Fecha de Ingreso *',
                  onDateSelected: (date) {
                    _fechaIngresoController.text = _formatDate(date);
                    widget.onFechaIngresoChanged(date);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _salarioBancariosCard(BuildContext context) {
    return _baseCard(
      title: "Salario y Datos Bancarios",
      subtitle: "Información para pago de nómina",
      icon: Icons.assured_workload,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: appMoneyInput(
                  controller: widget.salarioController,
                  label: 'Salario',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: widget.periodoPagoSeleccionado,
                  items: widget.periodosPago
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c, style: const TextStyle(color: Colors.white)),
                      ),
                    )
                    .toList(),
                  onChanged: widget.onPeriodoPagoChanged,
                  validator: (v) =>
                    v == null ? 'Periodo de Pago requerido' : null,
                  decoration: appDecoration('Periodo de Pago *'),
                  dropdownColor: const Color(0xFF0B0F14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: widget.bancoSeleccionado,
                  items: widget.bancos
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c, style: const TextStyle(color: Colors.white)),
                      ),
                    )
                    .toList(),
                  onChanged: widget.onBancoChanged,
                  validator: (v) =>
                    v == null ? 'Banco' : null,
                  decoration: appDecoration('Banco *'),
                  dropdownColor: const Color(0xFF0B0F14),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: appTextInput(
                  controller: widget.numeroCuentaController,
                  label: 'Número de Cuenta *',
                  hint: 'Número de cuenta bancaria',
                  validator: (v) =>
                    v == null || v.isEmpty ? 'Campo requerido' : null,
                ),
              )
              
            ],
          ),
        ],
      ),
    );
  }

  _baseCard({
    required String title,
    required String? subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Colors.white54)),
        ],
        const SizedBox(height: 20),
        child,
      ],
    );
  }


}

