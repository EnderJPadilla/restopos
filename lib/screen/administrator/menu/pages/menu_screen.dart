import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:restopos/models/product_model.dart';
import 'package:restopos/providers/menu_provider.dart';
import 'package:restopos/providers/product_provider.dart';
import 'package:restopos/core/utils/product_icon_mapper.dart';


class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    ref.listen(productosProvider, (_, __) {});

    final productosFiltradores = ref.watch(productosfiltradosProvider);
    final categorias = ref.watch(categoriasProvider);

    return Column(
      children: [
        _buildHeader(context, ref),
        const SizedBox(height: 10),

        _buildCategoryFilter(ref, categorias),
        const SizedBox(height: 20),

        Expanded(
          child: productosFiltradores.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: productosFiltradores.length,
              itemBuilder: (context, index) {
                return _buildProductCard(
                  context,
                  ref,
                  productosFiltradores[index],
                  index,
                );
              },
            ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(refreshLoadingProvider);
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar producto...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFE49E22)),
                filled: true,
                fillColor: const Color(0xFF1B170D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF00477B),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFFE49E22),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          IconButton(
            tooltip: 'Actualizar',
            icon: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh, color: Color(0xFFE49E22)),
            onPressed: loading
              ? null
              : () async {
                ref.read(refreshLoadingProvider.notifier).state = true;
                await ref.read(productosProvider.notifier).cargarProductos();
                ref.read(refreshLoadingProvider.notifier).state = false;
              },
          ),
          
          const SizedBox(width: 10),

          ElevatedButton.icon(
            onPressed: () => context.go('/admin/menu/nuevo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE49E22),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Nuevo',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(WidgetRef ref, List<String> categorias) {
    final categoriaSeleccionada = ref.watch(categoriaSeleccionadaProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          for (final categoria in categorias)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: FilterChip(
                label: Text(categoria),
                selected: categoriaSeleccionada == categoria,
                onSelected: (_) {
                  ref.read(categoriaSeleccionadaProvider.notifier).state =
                    categoria;
                },
                backgroundColor: const Color(0xFF1B170D),
                selectedColor: const Color(0xFFE49E22),
                labelStyle: TextStyle(
                  color: categoriaSeleccionada == categoria
                    ? Colors.white
                    : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
                side: BorderSide(
                  color: categoriaSeleccionada == categoria
                    ? const Color(0xFFE49E22)
                    : const Color(0xFF00477B),
                  width: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    WidgetRef ref,
    Producto producto,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1014),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: producto.disponible
            ? const Color(0xFF00477B)
            : const Color(0xFFFF0000),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Image.asset(
            ProductIconMapper.asset(producto.icono),
            width: 40,
            height: 40,
            errorBuilder: (_, __, ___) {
              return const Icon(
                Icons.image_not_supported,
                color: Colors.white38,
                size: 40,
              );
            },
          ),

          const SizedBox(width: 10),

          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        producto.nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!producto.disponible)
                      _buildAgotadoBadge(),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  producto.descripcionCorta,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '\$ ${NumberFormat('#,##0', 'es_CO').format(producto.precio)}',
                  style: const TextStyle(
                    color: Color(0xFFE49E22),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          _buildControls(context, ref, producto, index),
        ],
      ),
    );
  }

  Widget _buildControls(
    BuildContext context,
    WidgetRef ref,
    Producto producto,
    int index,
  ) {
    final loading = ref.watch(productLoadingProvider(producto.id));
    final productosFiltradores = ref.watch(productosfiltradosProvider);

    return Row(
      children: [
        Text(
          producto.disponible ? 'Disponible' : 'No Disponible',
          style: TextStyle(
            color: producto.disponible ? Colors.greenAccent : Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),

        Switch(
          value: producto.disponible,
          onChanged: loading
            ? null
            : (value) {
              ref.read(productosProvider.notifier)
                .toggleDisponible(producto.id, value, context);
            },
          activeColor: Colors.green,
          inactiveThumbColor: Colors.red,
        ),

        if (loading)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),

        IconButton(
          icon: const Icon(Icons.edit, color: Color(0xFFE49E22)),
          onPressed: () {
            final product = productosFiltradores[index]; // producto actual

            // Guardar producto seleccionado
            ref.read(selectedProductProvider.notifier).state = product;

            // Navegar al formulario
            context.go('/admin/menu/editar');
          },
        ),
      ],
    );
  }


  Widget _buildAgotadoBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.red),
      ),
      child: const Text(
        'Agotado',
        style: TextStyle(
          color: Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ESTADO VACÍO
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.search_off, size: 64, color: Colors.white38),
          SizedBox(height: 16),
          Text(
            'No se encontraron productos',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
