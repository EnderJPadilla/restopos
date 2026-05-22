import 'package:flutter/material.dart';
import 'package:restopos/widget/app_inputs.dart';

class InventoryTab extends StatelessWidget {
  final bool controlarInventario;
  final ValueChanged<bool> onControlarInventarioChanged;

  final TextEditingController stockController;
  final TextEditingController alertaStockController;

  final String unidadMedida;
  final ValueChanged<String?> onUnidadMedidaChanged;

  const InventoryTab({
    super.key,
    required this.controlarInventario,
    required this.onControlarInventarioChanged,
    required this.stockController,
    required this.alertaStockController,
    required this.unidadMedida,
    required this.onUnidadMedidaChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _boxDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Control de Inventario', icon: Icons.inventory),
              const SizedBox(height: 16),

              Row(
                children: [
                  Switch(
                    value: controlarInventario,
                    activeColor: const Color(0xFFE49E22),
                    onChanged: onControlarInventarioChanged,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Controlar inventario',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: appIntInput(
                      controller: stockController,
                      label: 'Cantidad en Stock',
                      enabled: controlarInventario,
                      validator: controlarInventario
                        ? (v) =>
                          (v == null || v.isEmpty) ? 'Requerido' : null
                        : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: appIntInput(
                      controller: alertaStockController,
                      label: 'Alerta de Stock Bajo',
                      enabled: controlarInventario,
                      validator: controlarInventario
                        ? (v) =>
                          (v == null || v.isEmpty) ? 'Requerido' : null
                        : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: unidadMedida,
                      decoration: appDecoration(
                        'Unidad de Medida',
                        hasError: false,
                      ),
                      dropdownColor: const Color(0xFF121821),
                      style: const TextStyle(color: Colors.white),
                      onChanged:
                        controlarInventario ? onUnidadMedidaChanged : null,
                      disabledHint: Text(
                        unidadMedida,
                        style: const TextStyle(color: Colors.white38),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Pieza', child: Text('Pieza')),
                        DropdownMenuItem(value: 'Kilogramo', child: Text('Kilogramo')),
                        DropdownMenuItem(value: 'Litro', child: Text('Litro')),
                        DropdownMenuItem(value: 'Porción', child: Text('Porción')),
                        DropdownMenuItem(value: 'Orden', child: Text('Orden')),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

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

}
