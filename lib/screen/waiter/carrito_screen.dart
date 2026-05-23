import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:restopos/models/table_model.dart';
// import 'package:restopos/models/producto_model.dart';
import 'package:restopos/screen/waiter/order_screen.dart';


class CartPage extends StatefulWidget {
  final TableModel mesa;
  final dynamic mesaOrder;
  final List<PedidoItem> carrito;
  final void Function(int, int) cambiarCantidad;

  const CartPage({
    super.key,
    required this.mesa,
    required this.mesaOrder,
    required this.carrito,
    required this.cambiarCantidad,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {

  double get subtotal => widget.carrito.fold(0, 
    (sum, item) => sum + item.producto.precio * item.cantidad
  );
  double get iva => subtotal * 0.16;
  double get propina => subtotal * 0.1;
  double get total => subtotal + iva + propina;

  // Widget _cantidadBtn(IconData icon, VoidCallback onTap) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       padding: const EdgeInsets.all(6),
  //       decoration: BoxDecoration(
  //         border: Border.all(color: AppColors.border),
  //         borderRadius: BorderRadius.circular(6),
  //       ),
  //       child: Icon(icon, size: 16, color: Colors.white),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return 
    Scaffold(
      backgroundColor: AppColors.background,
      // appBar: AppBar(
      //   backgroundColor: AppColors.card,
      //   title: const Text('Carrito', style: TextStyle(color: Colors.white)),
      //   leading: IconButton(
      //     icon: const Icon(Icons.close, color: Colors.white),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      // ),
      body: 
      Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          border: Border(left: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          children: [
            _buildHeaderMesa(context),
            Expanded(child: _buildCarrito()),
            _buildTotales(),
          ],
        ),
      ),
      // Column(
      //   children: [
      //     Expanded(
      //       child: carrito.isEmpty
      //         ? const Center(
      //             child: Text(
      //               'Sin productos',
      //               style: TextStyle(color: AppColors.textGrey)
      //             ),
      //           )
      //         : ListView.builder(
      //             padding: const EdgeInsets.all(15),
      //             itemCount: carrito.length,
      //             itemBuilder: (_, index) {
      //               final item = carrito[index];
      //               return Container(
      //                 margin: const EdgeInsets.only(bottom: 15),
      //                 padding: const EdgeInsets.all(15),
      //                 decoration: BoxDecoration(
      //                   color: AppColors.background,
      //                   borderRadius: BorderRadius.circular(10),
      //                   border: Border.all(color: AppColors.border),
      //                 ),
      //                 child: Column(
      //                   crossAxisAlignment: CrossAxisAlignment.start,
      //                   children: [
      //                     Row(
      //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                       children: [
      //                         Text(item.producto.nombre,
      //                             style: const TextStyle(
      //                                 color: Colors.white,
      //                                 fontWeight: FontWeight.bold)),
      //                         Row(
      //                           children: [
      //                             _cantidadBtn(Icons.remove,
      //                                 () => cambiarCantidad(index, -1)),
      //                             Padding(
      //                               padding: const EdgeInsets.symmetric(horizontal: 8),
      //                               child: Text(item.cantidad.toString(),
      //                                   style: const TextStyle(color: Colors.white)),
      //                             ),
      //                             _cantidadBtn(Icons.add,
      //                                 () => cambiarCantidad(index, 1)),
      //                             const SizedBox(width: 8),
      //                             GestureDetector(
      //                               onTap: () => cambiarCantidad(index, -item.cantidad),
      //                               child: const Icon(Icons.delete, color: Colors.red),
      //                             )
      //                           ],
      //                         )
      //                       ],
      //                     ),
      //                     const SizedBox(height: 8),
      //                     Text(
      //                         "\$${(item.producto.precio * item.cantidad).toStringAsFixed(2)}",
      //                         style: const TextStyle(
      //                             color: AppColors.accent, fontWeight: FontWeight.bold))
      //                   ],
      //                 ),
      //               );
      //             },
      //           ),
      //     ),
      //     Container(
      //       padding: const EdgeInsets.all(20),
      //       decoration:
      //           const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.stretch,
      //         children: [
      //           Row(
      //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //             children: [
      //               const Text('Subtotal', style: TextStyle(color: AppColors.textGrey)),
      //               Text('\$${subtotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white)),
      //             ],
      //           ),
      //           const SizedBox(height: 6),
      //           Row(
      //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //             children: [
      //               const Text('IVA (16%)', style: TextStyle(color: AppColors.textGrey)),
      //               Text('\$${iva.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white)),
      //             ],
      //           ),
      //           const SizedBox(height: 10),
      //           Row(
      //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //             children: [
      //               const Text('Total', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      //               Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
      //             ],
      //           ),
      //           const SizedBox(height: 20),
      //           ElevatedButton(
      //             style: ElevatedButton.styleFrom(
      //               backgroundColor: AppColors.accent,
      //               padding: const EdgeInsets.symmetric(vertical: 16),
      //             ),
      //             onPressed: () {},
      //             child: const Text('Enviar a Cocina', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      //           )
      //         ],
      //       ),
      //     )
      //   ],
      // ),
    );
  }

  Widget _buildHeaderMesa(BuildContext context) {
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
                widget.mesa.name != null && widget.mesa.name!.isNotEmpty 
                  ? widget.mesa.name! 
                  : 'Mesa ${widget.mesa.number}',
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
                '${widget.mesaOrder.comensales ?? 0} Comensales',
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
    if (widget.carrito.isEmpty) {
      return const Center(
        child: Text("Sin productos",
          style: TextStyle(color: AppColors.textGrey)
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: widget.carrito.length,
      itemBuilder: (_, index) {
        final item = widget.carrito[index];
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
                      _cantidadBtn(Icons.remove, () {
                        setState(() {
                          widget.cambiarCantidad(index, -1);
                        });
                      }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          item.cantidad.toString(),
                          style: const TextStyle(color: Colors.white)
                        ),
                      ),
                      _cantidadBtn(Icons.add, () {
                        setState(() {
                          widget.cambiarCantidad(index, 1);
                        });
                      }),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            widget.cambiarCantidad(index, -item.cantidad);
                          });
                        },
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

  Widget _cantidadBtn(
      IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon,
            size: 16, color: Colors.white),
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
        crossAxisAlignment:
          CrossAxisAlignment.stretch,
        children: [
          _lineaTotal("Subtotal", subtotal),
          _lineaTotal("IVA (16%)", iva),
          _lineaTotal("Propina (10%)", propina),
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
            onPressed: () { },
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
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
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

}