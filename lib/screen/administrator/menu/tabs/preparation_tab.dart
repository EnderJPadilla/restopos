import 'package:flutter/material.dart';
import 'package:restopos/widget/app_inputs.dart';

class PreparationTab extends StatelessWidget {
  
  // Controllers
  final TextEditingController tiempoPreparacionController;
  final TextEditingController notasPreparacionController;

  // Área preparación
  final String? areaPreparacionSeleccionada;
  final List<String> areasPreparacion;
  final ValueChanged<String?> onAreaPreparacionChanged;

  // Impresora
  final String? impresoraSeleccionada;
  final List<String> impresoras;
  final ValueChanged<String?> onImpresoraChanged;

  const PreparationTab({
    super.key,
    required this.tiempoPreparacionController,
    required this.notasPreparacionController,
    required this.areaPreparacionSeleccionada,
    required this.impresoraSeleccionada,
    required this.areasPreparacion,
    required this.impresoras,
    required this.onAreaPreparacionChanged,
    required this.onImpresoraChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            padding: const EdgeInsets.all(16),
            decoration: _boxDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                _sectionTitle(
                  text: 'Preparación y Cocina',
                  icon: Icons.schedule,
                ),

                Row(
                  children: [
                    Expanded(child: _tiempoPreparacion()),
                    const SizedBox(width: 16),
                    Expanded(child: _areaPreparacion()),
                    const SizedBox(width: 16),
                    Expanded(child: _impresoraComandas()),
                  ],
                ),

                const SizedBox(height: 16),
                _notasPreparacion(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle({
    required String text,
    required IconData icon,
  }) {
    return Padding(
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

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: const Color(0xFF0F1318),
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(color: Colors.black54, blurRadius: 8),
      ],
    );
  }

  // TIEMPO PREPARACIÓN
  Widget _tiempoPreparacion() {
    return appIntInput(
      controller: tiempoPreparacionController,
      label: 'Tiempo de Preparación (minutos)',
      hint: 'Ej: 15',
    );
  }

  // ÁREA PREPARACIÓN
  Widget _areaPreparacion() {
    return DropdownButtonFormField<String>(
      value: areaPreparacionSeleccionada,
      items: areasPreparacion
        .map(
          (area) => DropdownMenuItem(
            value: area,
            child: Text(area, style: const TextStyle(color: Colors.white)),
          ),
        )
        .toList(),
      onChanged: onAreaPreparacionChanged,
      decoration: appDecoration('Área de Preparación'),
      style: const TextStyle(color: Colors.white),
      dropdownColor: const Color(0xFF0B0F14),
    );
  }

  // IMPRESORA COMANDAS
  Widget _impresoraComandas() {
    return DropdownButtonFormField<String>(
      value: impresoraSeleccionada,
      items: impresoras
        .map(
          (impresora) => DropdownMenuItem(
            value: impresora,
            child: Text(impresora, style: const TextStyle(color: Colors.white)),
          ),
        )
        .toList(),
      onChanged: onImpresoraChanged,
      decoration: appDecoration('Impresora de Comandas'),
      style: const TextStyle(color: Colors.white),
      dropdownColor: const Color(0xFF0B0F14),
    );
  }

  // NOTAS (TEXTAREA FLEXIBLE)
  Widget _notasPreparacion() {
    return appTextInput(
      controller: notasPreparacionController,
      label: 'Notas de Preparación',
      hint: 'Instrucciones especiales para la preparación...',
      minLines: 3,
      maxLines: 10,
      keyboardType: TextInputType.multiline,
    );
  }

  
}
