import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restopos/core/services/token_service.dart';

import 'package:restopos/core/utils/product_icon_mapper.dart';

import 'package:restopos/providers/table_provider.dart';
import 'package:restopos/providers/order_provider.dart';
import 'package:restopos/providers/product_provider.dart';
import 'package:restopos/providers/menu_provider.dart';
import 'package:restopos/providers/settings_provider.dart';

import 'package:restopos/models/table_model.dart';
import 'package:restopos/models/product_model.dart';
import 'package:restopos/models/settings_model.dart';
import 'package:restopos/models/order_model.dart';

import 'package:restopos/screen/waiter/carrito_screen.dart';
import 'package:restopos/screen/waiter/confirmar_pedido_modal.dart';

class AppColors {
  static const background = Color(0xFF05080B);
  static const card = Color(0xFF070B10);
  static const border = Color(0xFF00477B);
  static const accent = Color(0xFFFFA000);
  static const textGrey = Color(0xFF9CA3AF);
}


class PedidoItem {
  final Producto producto;
  int cantidad;
  final TextEditingController notasController;

  PedidoItem({
    required this.producto,
    this.cantidad = 1,
    String? notas,
  }) : notasController = TextEditingController(text: notas ?? '');

  void dispose() {
    notasController.dispose();
  }
}

class PedidoScreen extends ConsumerStatefulWidget {
  const PedidoScreen({super.key});

  @override
  ConsumerState<PedidoScreen> createState() => _PedidoScreenState();
}

class _PedidoScreenState extends ConsumerState<PedidoScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController searchController = TextEditingController();
  dynamic mesaSeleccionada = null;
  dynamic mesaOrder = null;
  dynamic usuarioId = null;
  // dynamic configuraciones = null;

  String categoriaSeleccionada = "Todos";
  String notasPreparacion = "";

  // controla si los campos de configuración están en modo edición
  bool editConfig = false;

  List<String> get categorias => ref.watch(categoriasProvider);
  List<Producto> get productos => ref.watch(productosfiltradosProvider);
  List<Setting> get configuraciones => ref.watch(settingProvider);

  final List<PedidoItem> carrito = [];

  // Valores calculados
  // double get iva => subtotal * 0.16;
  double get iva => subtotal * configuraciones.firstWhere((s) => s.impuesto > 0, orElse: () => Setting(impuesto: 0, propina: 0, moneda: '', descuentos: false, redondearTotales: false, impresion: false)).impuesto / 100;
  // double get propina => subtotal * 0.1;
  double get propina => subtotal * configuraciones.firstWhere((s) => s.propina > 0, orElse: () => Setting(impuesto: 0, propina: 0, moneda: '', descuentos: false, redondearTotales: false, impresion: false)).propina / 100;
  double get total => subtotal + iva + propina;

  List<Producto> get productosFiltrados {
    return productos.where((p) {
      final coincideBusqueda = p.nombre
        .toLowerCase()
        .contains(searchController.text.toLowerCase());

      final coincideCategoria = categoriaSeleccionada == "Todos"
        ? true
        : p.categoria == categoriaSeleccionada;

      return coincideBusqueda && coincideCategoria;
    }).toList();
  }

  void agregarProducto(Producto producto) {
    final index =
      carrito.indexWhere((item) => item.producto.nombre == producto.nombre);

    setState(() {
      if (index != -1) {
        carrito[index].cantidad++;
      } else {
        carrito.add(PedidoItem(producto: producto));
      }
    });
  }

  void cambiarCantidad(int index, int cambio) {
    setState(() {
      carrito[index].cantidad += cambio;
      if (carrito[index].cantidad <= 0) {
        carrito[index].dispose();
        carrito.removeAt(index);
      }
    });
  }

  double get subtotal {
    return carrito.fold(
      0, (sum, item) => sum + item.producto.precio * item.cantidad
    );
  }


  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      usuarioId = TokenService.getUsuarioId();
      final dynamic mesa = ref.read(selectedTableProvider);
      final dynamic dataMesaOrder = ref.read(mesaSeleccionadaProvider);

      if (mesa == null || dataMesaOrder == null) {
        _resetForm();
        return;
      }

      if (mesa != null && dataMesaOrder != null && mesa.id == dataMesaOrder.mesaId) {
        _cargarFrom(mesa, dataMesaOrder);
        return;
      }
    });
  }

  void _resetForm() {
    mesaSeleccionada = null;
    mesaOrder = null;
  }

  void _cargarFrom(mesa, dataMesaOrder) {
    setState(() {
      mesaSeleccionada = mesa;
      mesaOrder = dataMesaOrder;
    });
    // print('Mesa seleccionada: ${mesa.number}');
    // print('Data Mesa seleccionada: ${dataMesaOrder.mesaId}');
  }

  @override
  void dispose() {
    for (final item in carrito) {
      item.dispose();
    }
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    final isMobile = MediaQuery.of(context).size.width < 800;
    final isTablet = MediaQuery.of(context).size.width < 1200;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isMobile
        ? AppBar(
            backgroundColor: AppColors.card,
            title: const Text(
              'Registrar Pedido',
              style: TextStyle(color: Colors.white)
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.go('/mesero'),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => Scaffold(
                      backgroundColor: AppColors.background,
                      body: CartPage(
                        mesa: mesaSeleccionada ?? 
                          TableModel(
                            id: "temp_table",
                            number: 0, 
                            maximumCapacity: 0, 
                            status: TableStatus.disponible,
                            activo: true,
                            booking: false
                          ),
                        mesaOrder: mesaOrder,
                        carrito: carrito,
                        cambiarCantidad: cambiarCantidad,
                      ),
                    ),
                  ));
                },
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.shopping_cart, color: Colors.white),
                    if (carrito.isNotEmpty)
                      Positioned(
                        right: 0,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8)
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            carrito.length.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                  ],
                ),
              )
            ],
          )
        : null,
      body: Row(
        children: [
          /// IZQUIERDA - PRODUCTOS
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildBusqueda(),
                  const SizedBox(height: 15),
                  _buildCategorias(isMobile: isMobile),
                  const SizedBox(height: 20),
                  Expanded(child: _buildGridProductos())
                ],
              ),
            ),
          ),

          /// DERECHA - CARRITO (solo en pantallas anchas)
          if (!isMobile)
            Container(
              width: isTablet ? 320 : 420,
              decoration: const BoxDecoration(
                color: AppColors.card,
                border: Border(left: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                children: [
                  _buildHeaderMesa(),
                  Expanded(child: _buildCarrito()),
                  _buildTotales(),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _buildCategorias({required bool isMobile}) {
    if (isMobile) {
      return Row(
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.card,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              side: const BorderSide(color: AppColors.border),
            ),
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                backgroundColor: AppColors.card,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                builder: (_) {
                  return ListView(
                    padding: const EdgeInsets.all(12),
                    children: categorias.map((cat) {
                      final selected = cat == categoriaSeleccionada;
                      return ListTile(
                        tileColor: selected ? const Color(0xFF1E1B16) : null,
                        title: Text(cat, style: TextStyle(color: selected ? Colors.white : AppColors.textGrey)),
                        onTap: () {
                          setState(() => categoriaSeleccionada = cat);
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  );
                },
              );
            },
            icon: const Icon(Icons.filter_list, color: Colors.white),
            label: const Text('Filtradas', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              categoriaSeleccionada,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categorias.map((cat) {
          final selected = cat == categoriaSeleccionada;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                setState(() => categoriaSeleccionada = cat);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.accent : AppColors.card,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  cat,
                  style: TextStyle(color: selected ? Colors.black : Colors.white),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBusqueda() {
    return TextField(
      controller: searchController,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Buscar producto...',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        prefixIcon: const Icon(Icons.search, color: Color(0xFFE49E22)),
        filled: true,
        fillColor: AppColors.card,
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
    );
  }

  Widget _buildGridProductos() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: LayoutBuilder(
        builder: (context, constraints) {
          int columns = 2;

          if (constraints.maxWidth > 1200) {
            columns = 6;
          } else if (constraints.maxWidth > 850) {
            columns = 4;
          } else if (constraints.maxWidth > 600) {
            columns = 3;
          }

          return GridView.builder(
            itemCount: productosFiltrados.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (_, index) {
              final producto = productosFiltrados[index];
              final isSelected = carrito.any((c) => c.producto.nombre == producto.nombre);
              return GestureDetector(
                onTap: () => agregarProducto(producto),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFE49E22) : AppColors.border,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Center(
                          child: producto.icono != '' 
                          ? Image.asset(
                            ProductIconMapper.asset(producto.icono),
                            width: 80,
                            height: 80,
                            errorBuilder: (_, __, ___) {
                              return const Icon(
                                Icons.image_not_supported,
                                color: Colors.white38,
                                size: 40,
                              );
                            },
                          )
                          : Icon(
                            Icons.restaurant,
                            size: 40,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ),
                      Text(
                        producto.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        )
                      ),
                      Text(
                        producto.descripcion,
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 12
                        )
                      ),
                      const SizedBox(height: 6),
                      Text(
                        // "\$${producto.precio.toStringAsFixed(2)}",
                        '\$ ${NumberFormat('#,##0', 'es_CO').format(producto.precio)}',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold
                        )
                      )
                    ],
                  ),
                ),
              );
            },
          );

        },
      ),
    );
    
  }

  Widget _buildHeaderMesa() {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                // 'Mesa ${mesaSeleccionada != null ? mesaSeleccionada.number : 'No Cargada'}',
                mesaSeleccionada.name != null && mesaSeleccionada.name!.isNotEmpty 
                  ? mesaSeleccionada.name! 
                  : 'Mesa ${mesaSeleccionada.number}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold
                ),
              ),
              IconButton(
                onPressed: () {
                  if (isMobile) {
                    Navigator.of(context).pop();
                  } else {
                    context.go('/mesero');
                  }
                },
                icon: const Icon(Icons.close, color: Colors.white54),
              ),
            ] 
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Nuevo pedido',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.group, color: Colors.white54),
              const SizedBox(width: 6),
              Text(
                // '${mesaSeleccionada != null ? mesaSeleccionada.maximumCapacity : 0}',
                '${mesaOrder.comensales ?? 0} Comensales',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ] 
          ),
        ],
      )
      
    );
  }

  Widget _buildCarrito() {
    final isMobile = MediaQuery.of(context).size.width < 800;

    if (carrito.isEmpty) {
      return Center(
        child: Text("Sin productos",
          style: TextStyle(
            fontSize: isMobile ? 12 : 12,
            color: AppColors.textGrey
          )
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: carrito.length,
      itemBuilder: (_, index) {
        final item = carrito[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.producto.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ),
                  Row(
                    children: [
                      _cantidadBtn(Icons.remove, () => cambiarCantidad(index, -1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          item.cantidad.toString(),
                          style: const TextStyle(color: Colors.white)
                        ),
                      ),
                      _cantidadBtn(Icons.add, () => cambiarCantidad(index, 1)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => cambiarCantidad(index, -item.cantidad),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.red
                        ),
                      )
                    ],
                  )
                ],
              ),
              const SizedBox(height: 8),
              Text(
                // "\$${(item.producto.precio).toStringAsFixed(2)}",
                '\$ ${NumberFormat('#,##0', 'es_CO').format(item.producto.precio)}',
                style: const TextStyle(
                  color: Colors.white70,
                )
              ),
              const SizedBox(height: 8),
              TextField(
                controller: item.notasController,
                minLines: 1,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(color: Colors.white),
                onChanged: (_) {
                  // if (errores[index]) {
                  //   setState(() => errores[index] = false);
                  // }
                },
                decoration: InputDecoration(
                  hintText: "Notas de preparación.",
                  filled: true,
                  fillColor: const Color(0xFF0B0F14),
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintStyle: const TextStyle(color: Colors.white38),
                  errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    // borderSide: BorderSide(
                    //   color: hasError ? Colors.redAccent : Colors.transparent,
                    // ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE49E22), width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.redAccent),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.redAccent),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    // "\$${(item.producto.precio * item.cantidad).toStringAsFixed(2)}",
                    '\$ ${NumberFormat('#,##0', 'es_CO').format(item.producto.precio * item.cantidad)}',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold
                    )
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _cantidadBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16, 
          color: Colors.white
        ),
      ),
    );
  }

  Widget _buildTotales() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _lineaTotal("Subtotal", subtotal),
          _lineaTotal("IVA (${configuraciones.firstWhere((s) => s.impuesto > 0, orElse: () => Setting(impuesto: 0, propina: 0, moneda: '', descuentos: false, redondearTotales: false, impresion: false)).impuesto}%)", iva),
          _lineaTotal("Propina (${configuraciones.firstWhere((s) => s.propina > 0, orElse: () => Setting(impuesto: 0, propina: 0, moneda: '', descuentos: false, redondearTotales: false, impresion: false)).propina}%)", propina),
          const SizedBox(height: 10),
          _lineaTotal("Total", total, esTotal: true),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE49E22),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              // Enviar pedido a cocina
              // _guardarPedido();
              final payload = _cargarPedidoPayload();
              modalConfirmarPedido(context, payload);
            },
            icon: const Icon(Icons.publish),
            label: const Text("Enviar a Cocina"),
          ),
        ],
      ),
    );
  }

  Widget _lineaTotal(String label, double valor,
      {bool esTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: esTotal
              ? Colors.white
              : AppColors.textGrey,
            fontWeight: esTotal ? FontWeight.bold : null
          )
        ),
        Text(
          // "\$${valor.toStringAsFixed(2)}",
          '\$ ${NumberFormat('#,##0', 'es_CO').format(valor)}',
          style: TextStyle(
            color: esTotal ? AppColors.accent : Colors.white,
            fontWeight: esTotal ? FontWeight.bold : null
          )
        )
      ],
    );
  }

  // Construir payload del pedido
  Map<String, dynamic> _cargarPedidoPayload() {
    final payload = {
      "id": '',
      "usuario_id": usuarioId,
      "cliente_nombre": '',
      "cliente_documento": '',
      "mesa_id": mesaSeleccionada != null ? mesaSeleccionada.id : 'temp_table',
      "nombre_mesa": mesaOrder != null ? mesaOrder.nombre : 'temp_table',
      "numero_mesa": mesaOrder != null ? mesaOrder.number : 0,
      "comensales": mesaOrder != null ? mesaOrder.comensales : 0,
      "productos": carrito.map((item) => {
        "producto_id": item.producto.id,
        "nombre_producto": item.producto.nombre,
        "cantidad": item.cantidad,
        "precio": item.producto.precioDespuesImpuesto,
        "subTotal": item.producto.precioDespuesImpuesto * item.cantidad,
        "observacion": item.notasController.text.trim() == '' ? '' : item.notasController.text.trim(),
      }).toList(),
      "subtotal": subtotal,
      "impuesto": iva,
      "propina": propina,
      "descuento": 0,
      "total": total,
    };
    // print("================== Payload del pedido =================");
    // print("Payload del pedido: $payload");
    // print("======================================================");
    return payload;
  }

  // // Guardar pedido
  // Future<void> _guardarPedido() async {
  //   // if (!_formKey.currentState!.validate()) return;
  //   final provider = ref.read(orderProvider);

  //   final payload = {
  //     "id": '',
  //     "usuario_id": await TokenService.getUsuarioId(),
  //     "cliente_nombre": '',
  //     "cliente_documento": '',
  //     "mesa_id": mesaSeleccionada != null ? mesaSeleccionada.id : 'temp_table',
  //     "nombre_mesa": mesaOrder != null ? mesaOrder.nombre : 'temp_table',
  //     "comensales": mesaOrder != null ? mesaOrder.comensales : 0,
  //     "productos": carrito.map((item) => {
  //       "producto_id": item.producto.id,
  //       "nombre_producto": item.producto.nombre,
  //       "cantidad": item.cantidad,
  //       "precio": item.producto.precioDespuesImpuesto,
  //       "subTotal": item.producto.precioDespuesImpuesto * item.cantidad,
  //       "observacion": item.notasController.text.trim() == '' ? '' : item.notasController.text.trim(),
  //     }).toList(),
  //     "subtotal": subtotal,
  //     "impuesto": iva,
  //     "propina": propina,
  //     "descuento": 0,
  //     "total": total,
  //   };

  //   final success = await provider.guardarPedidos(payload);

  //   if (!mounted) return;

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(success ? 'Pedido registrado correctamente' : provider.error ?? 'Error'),
  //       backgroundColor: success ? Colors.green : Colors.red,
  //     ),
  //   );

  //   if (success) {
  //     editConfig = false;
  //     setState(() {});
  //   }

  // }


  Future<void> modalConfirmarPedido(BuildContext context, pedido) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConfirmarPedidoModal(pedido: pedido),
    );
  }


}
