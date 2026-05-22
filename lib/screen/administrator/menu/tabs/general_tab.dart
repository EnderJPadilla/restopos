import 'package:flutter/material.dart';
import 'package:restopos/models/category_model.dart';
import 'package:restopos/widget/app_inputs.dart';

class GeneralTab extends StatefulWidget {
  final TextEditingController nombreController;
  final TextEditingController skuController;
  final TextEditingController barcodeController;
  final TextEditingController descripcionCortaController;
  final TextEditingController descripcionCompletaController;
  final TextEditingController tagController;
  final String? iconoSeleccionado;
  final ValueChanged<String> onIconoChanged;

  final List<Category> categorias;
  final Category? categoriaSeleccionada;
  final ValueChanged<Category?> onCategoriaChanged;

  final bool disponible;
  final ValueChanged<bool> onDisponibleChanged;

  final List<String> tags;
  final Function(String) onAddTag;
  final Function(String) onRemoveTag;

  const GeneralTab({
    super.key,
    required this.nombreController,
    required this.skuController,
    required this.barcodeController,
    required this.descripcionCortaController,
    required this.descripcionCompletaController,
    required this.tagController,
    required this.categorias,
    this.categoriaSeleccionada,
    required this.onCategoriaChanged,
    required this.disponible,
    required this.onDisponibleChanged,
    required this.iconoSeleccionado,
    required this.onIconoChanged,
    required this.tags,
    required this.onAddTag,
    required this.onRemoveTag,
  });

  @override
  State<GeneralTab> createState() => _GeneralTabState();
}

class _GeneralTabState extends State<GeneralTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF121821),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Información General', icon: Icons.view_in_ar),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: appTextInput(
                    controller: widget.nombreController,
                    label: 'Nombre del Producto *',
                    hint: 'Ej: Hamburguesa Clásica',
                    validator: (v) =>
                      v == null || v.isEmpty ? 'Campo requerido' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: appTextInput(
                    controller: widget.skuController,
                    label: 'SKU / Código Interno *',
                    hint: 'Ej: HAM-001',
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
                  child: appIntInput(
                    controller: widget.barcodeController,
                    label: 'Código de Barras',
                    hint: 'Ej: 7501234567890',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _categoriaDropdown(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            appTextInput(
              controller: widget.descripcionCortaController,
              label: 'Descripción Corta',
              hint: 'Descripción breve para el ticket',
            ),

            const SizedBox(height: 16),

            appTextInput(
              controller: widget.descripcionCompletaController,
              label: 'Descripción Completa',
              hint: 'Descripción detallada del producto',
            ),

            const SizedBox(height: 24),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: widget.disponible,
              onChanged: widget.onDisponibleChanged,
              activeColor: const Color(0xFFE49E22),
              title: const Text(
                'Producto Disponible',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              subtitle: const Text(
                'Mostrar en menú y permitir pedidos',
                style: TextStyle(color: Colors.white70),
              ),
            ),

            const SizedBox(height: 24),

            _iconSelector(),

            const Divider(height: 40),

            _sectionTitle('Etiquetas de Filtro', icon: Icons.filter_list),

            TextFormField(
              controller: widget.tagController,
              style: const TextStyle(color: Colors.white),
              decoration: appDecoration(
                'Agregar etiqueta',
                hint: 'Presione Enter para agregar',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white70),
                  onPressed: () {
                    if (widget.tagController.text.isNotEmpty) {
                      widget.onAddTag(widget.tagController.text);
                      widget.tagController.clear();
                    }
                  },
                ),
              ),
              onFieldSubmitted: (v) {
                if (v.isNotEmpty) {
                  widget.onAddTag(v);
                  widget.tagController.clear();
                }
              },
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.tags
                .map(
                  (tag) => Chip(
                    label: Text(tag),
                    backgroundColor: const Color(0xFFE49E22),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => widget.onRemoveTag(tag),
                  ),
                )
                .toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// ─────────────────────────────
  /// DROPDOWN CATEGORÍAS (LOCAL)
  /// ─────────────────────────────
  Widget _categoriaDropdown() {
    return DropdownButtonFormField<Category>(
      value: widget.categoriaSeleccionada,
      items: widget.categorias
        .map(
          (c) => DropdownMenuItem<Category>(
            value: c,
            child: Text(c.nombre, style: const TextStyle(color: Colors.white)),
          ),
        )
        .toList(),
      onChanged: widget.onCategoriaChanged,
      validator: (v) =>
        v == null ? 'Seleccione una categoría' : null,
      decoration: appDecoration('Categoría *'),
      dropdownColor: const Color(0xFF0B0F14),
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

    

  final List<ProductIconItem> _productIcons = const [
    ProductIconItem('salchipapas', 'Salchipapas', 'assets/icons/products/salchipapas.png'),
    ProductIconItem('hamburguesa', 'Hamburguesa', 'assets/icons/products/hamburguesa.png'),
    ProductIconItem('pizza', 'Pizza', 'assets/icons/products/pizza.png'),
    ProductIconItem('soda', 'Soda', 'assets/icons/products/soda.png'),
    ProductIconItem('perro_caliente', 'Perro Caliente', 'assets/icons/products/perro_caliente.png'),
    ProductIconItem('asados', 'Asados', 'assets/icons/products/asados.png'),
    ProductIconItem('jugos', 'Jugos', 'assets/icons/products/jugos.png'),
    ProductIconItem('mazorca', 'Mazorca', 'assets/icons/products/mazorca.png'),
  ];

  Widget _iconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Ícono para el Menú', icon: Icons.image),

        DropdownButtonFormField<String>(
          value: widget.iconoSeleccionado,
          decoration: appDecoration(
            'Seleccionar ícono',
            hint: 'Elija un ícono para el producto',
          ),
          dropdownColor: const Color(0xFF0B0F14),
          iconEnabledColor: Colors.white70,
          items: _productIcons.map((icon) {
            return DropdownMenuItem<String>(
              value: icon.id,
              child: Row(
                children: [
                  Image.asset(
                    icon.asset,
                    width: 26,
                    height: 26,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.image_not_supported,
                      color: Colors.redAccent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    icon.label,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) widget.onIconoChanged(v);
          },

          /// cómo se ve el valor seleccionado
          selectedItemBuilder: (context) {
            return _productIcons.map((icon) {
              return Row(
                children: [
                  Image.asset(
                    icon.asset,
                    width: 22,
                    height: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    icon.label,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              );
            }).toList();
          },
        ),
      ],
    );
  }

}

class ProductIconItem {
  final String id;
  final String label;
  final String asset;

  const ProductIconItem(this.id, this.label, this.asset);
}