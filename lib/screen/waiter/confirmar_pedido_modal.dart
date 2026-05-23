import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:restopos/core/services/token_service.dart';

import 'package:restopos/providers/order_provider.dart';

import 'package:restopos/models/order_model.dart';
import 'package:restopos/models/table_model.dart';

class AppColors {
  static const background = Color(0xFF05080B);
  static const card = Color(0xFF070B10);
  static const border = Color(0xFF00477B);
  static const accent = Color(0xFFFFA000);
  static const textGrey = Color(0xFF9CA3AF);

  static const revision = Color(0xFFF59E0B);
  static const listo = Color(0xFF22C55E);
  static const registrado = Color(0xFF3B82F6);
}

class ConfirmarPedidoModal extends ConsumerStatefulWidget {
  final Map<String, dynamic> pedido;

  const ConfirmarPedidoModal({super.key, required this.pedido});

  @override
  ConsumerState<ConfirmarPedidoModal> createState() => _ConfirmarPedidoModalState();
}

class _ConfirmarPedidoModalState extends ConsumerState<ConfirmarPedidoModal> {
  int cantidad = 1;
  late List<TextEditingController> controllers;
  late List<bool> errores;
  String horaActual = DateFormat('HH:mm').format(DateTime.now());

  Color estadoColor(String estado) {
    switch (estado) {
      case "En Revision":
        return AppColors.revision;
      case "Listo":
        return AppColors.listo;
      default:
        return AppColors.registrado;
    }
  }

  @override
  void initState() {
    super.initState();
    controllers = [TextEditingController()];
    errores = [false];
  }


  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF05080B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Confirmar Pedido ${widget.pedido['nombre_mesa']}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () =>Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white54),
                )
              ],
            ),

            const SizedBox(height: 2),

            const Text(
              "Se enviara el pedido a cocina. Por favor confirme que toda la información es correcta antes de proceder.",
              style: TextStyle(color: Colors.white54),
            ),

            const SizedBox(height: 24),

            // Lista de productos
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _pedidoCard(widget.pedido),
              ],
            ),

            const SizedBox(height: 24),

            /// BOTONES
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  // style: OutlinedButton.styleFrom(
                  //   foregroundColor: Colors.white,
                  //   side: const BorderSide(color: Colors.white24),
                  // ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Revisar', style: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE49E22),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    _guardarPedido();
                  },
                  icon: const Icon(Icons.login),
                  label: const Text("Enviar a Cocina"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _pedidoCard(Map<String, dynamic> pedido) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        pedido['numero_mesa'].toString(),
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${pedido['nombre_mesa']}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14, color: AppColors.textGrey
                          ),
                          const SizedBox(width: 4),
                          Text(
                            // pedido.hora,
                            horaActual,
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 12,
                            ),
                          )
                        ],
                      )
                    ],
                  ),

                  const Spacer(),

                  Container(
                    padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: estadoColor('En Revision')),
                    ),
                    child: Text(
                      'En Revisión',
                      style: TextStyle(
                        color: estadoColor('En Revision'),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// PRODUCTOS
              Column(
                children: (pedido['productos'] as List<dynamic>).map<Widget>((p) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${p['cantidad']}x ${p['nombre_producto']}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "${p['observacion']}",
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        Text(
                          // "\$${(p['precio'] as num).toStringAsFixed(2)}",
                          '\$ ${NumberFormat('#,##0', 'es_CO').format(p['precio'])}',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const Divider(height: 25, color: AppColors.border),

              /// FOOTER
              Row(
                children: [

                  Text(
                    "Total:",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const Spacer(),

                  Text(
                    // "\$${(pedido['total'] as num).toStringAsFixed(2)}",
                    '\$ ${NumberFormat('#,##0', 'es_CO').format(pedido['total'])}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                ],
              )
            ],
          ),
        ),
      ),
    );
  }


  Widget outlinedButton(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(color: Colors.white),
          )
        ],
      ),
    );
  }


  
  // Guardar pedido
  Future<void> _guardarPedido() async {
    final provider = ref.read(orderProvider);

    final payload = {
      ...widget.pedido,
      "usuario_id": await TokenService.getUsuarioId(),
    };

    final success = await provider.guardarPedidos(payload);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Pedido registrado correctamente' : provider.error ?? 'Error'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      setState(() {});
      context.go('/mesero');
      Navigator.of(context).pop();
    }

  }

}
