import 'package:flutter/material.dart';
import 'package:restopos/widget/app_inputs.dart';

class PricesTab extends StatefulWidget {
  final TextEditingController precioVentaController;
  final TextEditingController costoController;
  final TextEditingController impuestoController;
  final TextEditingController precioDespuesImpuestoController;
  final TextEditingController precioEspecialController;

  final DateTime? fechaInicioPromo;
  final DateTime? fechaFinPromo;
  final bool impuestoIncluido;

  final ValueChanged<DateTime?> onFechaInicioChanged;
  final ValueChanged<DateTime?> onFechaFinChanged;
  final ValueChanged<bool> onImpuestoIncluidoChanged;

  const PricesTab({
    super.key,
    required this.precioVentaController,
    required this.costoController,
    required this.impuestoController,
    required this.precioDespuesImpuestoController,
    required this.precioEspecialController,
    required this.fechaInicioPromo,
    required this.fechaFinPromo,
    required this.impuestoIncluido,
    required this.onFechaInicioChanged,
    required this.onFechaFinChanged,
    required this.onImpuestoIncluidoChanged,
  });

  @override
  State<PricesTab> createState() => _PricesTabState();
}

class _PricesTabState extends State<PricesTab>
    with AutomaticKeepAliveClientMixin {
  bool _actualizandoPrecio = false;
  late final TextEditingController _fechaInicioController;
  late final TextEditingController _fechaFinController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    /// Inicializar fechas
    _fechaInicioController = TextEditingController(
      text: widget.fechaInicioPromo != null
      ? _formatDate(widget.fechaInicioPromo!)
      : '',
    );

    _fechaFinController = TextEditingController(
      text: widget.fechaFinPromo != null
      ? _formatDate(widget.fechaFinPromo!)
      : '',
    );

    /// Inicializar valores monetarios en 0
    _initMoneyController(widget.costoController);
    _initMoneyController(widget.precioVentaController);
    _initMoneyController(widget.precioDespuesImpuestoController);
    _initMoneyController(widget.precioEspecialController);

    widget.precioVentaController.addListener(_limpiarCeroInicialPrecioVenta);
    widget.precioVentaController.addListener(_recalcularPrecioConImpuesto);
    widget.impuestoController.addListener(_recalcularPrecioConImpuesto);
  }

  @override
  void dispose() {
    widget.precioVentaController.removeListener(_limpiarCeroInicialPrecioVenta);
    widget.precioVentaController.removeListener(_recalcularPrecioConImpuesto);
    widget.impuestoController.removeListener(_recalcularPrecioConImpuesto);

    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    super.dispose();
  }

  /// Coloca 0 solo si está vacío
  void _initMoneyController(TextEditingController controller) {
    if (controller.text.trim().isEmpty) {
      controller.text = '0';
    }
  }

  /// Evita que el 0 inicial afecte cuando el usuario escribe
  void _limpiarCeroInicialPrecioVenta() {
    final text = widget.precioVentaController.text;

    if (text.length > 1 && text.startsWith('0')) {
      widget.precioVentaController.text = text.replaceFirst(RegExp(r'^0+'), '');
      widget.precioVentaController.selection = TextSelection.collapsed(
        offset: widget.precioVentaController.text.length,
      );
    }
  }

  void _recalcularPrecioConImpuesto() {
    if (_actualizandoPrecio) return;

    final precioVenta = _parseMoney(widget.precioVentaController.text);
    final tasa = _parseMoney(widget.impuestoController.text);

    if (precioVenta <= 0) {
      widget.precioDespuesImpuestoController.text = '0';
      return;
    }

    double precioFinal = precioVenta;

    if (widget.impuestoIncluido && tasa > 0) {
      precioFinal += precioVenta * (tasa / 100);
    }

    _actualizandoPrecio = true;
    widget.precioDespuesImpuestoController.text =
      precioFinal.toStringAsFixed(0);
    _actualizandoPrecio = false;
  }

  /// Convierte texto formateado COP a double real
  double _parseMoney(String value) {
    return double.tryParse(
      value.replaceAll(RegExp(r'[^\d]'), ''),
    ) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          /// PRECIO Y COSTO
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _boxDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Precio y Costo', icon: Icons.attach_money),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: appMoneyInput(
                        controller: widget.costoController,
                        label: 'Costo',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: appMoneyInput(
                        controller: widget.precioVentaController,
                        label: 'Precio de venta *',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: appDecimalInput(
                        controller: widget.impuestoController,
                        label: 'Tasa de impuesto (%)',
                        validator: (v) {
                          if (v == null || v.isEmpty) return null;
                          final value = double.tryParse(v);
                          if (value == null || value < 0) {
                            return 'Tasa inválida';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    Switch(
                      value: widget.impuestoIncluido,
                      activeColor: const Color(0xFFE49E22),
                      onChanged: (value) {
                        widget.onImpuestoIncluidoChanged(value);
                        if(value) {
                          _recalcularPrecioConImpuesto();
                        } else {
                          widget.precioDespuesImpuestoController.text = 
                            widget.precioVentaController.text;
                        }
                      },
                    ),

                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Impuesto incluido',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: appReadonlyInput(
                        controller: widget.precioDespuesImpuestoController,
                        label: 'Precio después de Impuesto',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// PRECIO ESPECIAL
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _boxDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle(
                  'Precio Especial / Promoción',
                  icon: Icons.money_off,
                ),
                const SizedBox(height: 16),

                appMoneyInput(
                  controller: widget.precioEspecialController,
                  label: 'Precio especial',
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: appDateInput(
                        context: context,
                        controller: _fechaInicioController,
                        label: 'Fecha Inicio',
                        onDateSelected: (date) {
                          _fechaInicioController.text = _formatDate(date);
                          widget.onFechaInicioChanged(date);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: appDateInput(
                        context: context,
                        controller: _fechaFinController,
                        label: 'Fecha Fin',
                        onDateSelected: (date) {
                          _fechaFinController.text = _formatDate(date);
                          widget.onFechaFinChanged(date);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/'
    '${date.year}';

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: const Color(0xFF0F1318),
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(color: Colors.black54, blurRadius: 8),
      ],
    );
  }

  Widget _sectionTitle(
    String text, {
    required IconData icon,
  }) =>
  Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
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
}
