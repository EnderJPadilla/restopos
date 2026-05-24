import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// import 'package:restopos/providers/order_provider.dart';
import 'package:restopos/models/order_model.dart';
import 'package:restopos/models/settings_model.dart';
import 'package:restopos/providers/order_provider.dart';
import 'package:restopos/providers/settings_provider.dart';

import 'package:restopos/widget/live_order_time.dart';


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


class TableOrderView extends ConsumerStatefulWidget {
  final Map<String, dynamic> dataPedido;

  const TableOrderView({super.key, required this.dataPedido});

  @override
  ConsumerState<TableOrderView> createState() => _TableOrderView();
}

class _TableOrderView extends ConsumerState<TableOrderView> {

  List<Setting> get configuraciones => ref.watch(settingProvider);


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
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 20),
                  _buildActions(),
                  const SizedBox(height: 20),
                  _buildOrderCard(),
                ],
              ),
            ),
          ),
        ),

      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFFB000),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                '${widget.dataPedido['numero']}',
                style: const TextStyle(
                  color: Color(0xFFFFB000),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.dataPedido['nombre']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 20,
                  runSpacing: 8,
                  children: [
                    _infoItem(Icons.people_outline, '${widget.dataPedido['pedido_activo']['comensales']} comensales'),
                    _infoItem(Icons.person_outline, '${widget.dataPedido['pedido_activo']['nombre_usuario']}'),
                    LiveOrderTime(
                      createdAt: widget.dataPedido['pedido_activo']['created_at'],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF33230B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFFFB000),
              ),
            ),
            child: Text(
              '${widget.dataPedido['pedido_activo']['estado']}',
              style: const TextStyle(
                color: Color(0xFFFFB000),
                fontWeight: FontWeight.w700,
                // fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          // size: 18,
          color: Colors.white70,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            // fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        // Expanded(
        //   child: _actionButton(
        //     icon: Icons.add_circle_outline,
        //     title: 'Agregar Items',
        //     iconColor: Colors.orange,
        //     onTap: onAddItems,
        //   ),
        // ),
        // const SizedBox(width: 14),
        Expanded(
          child: _actionButton(
            icon: Icons.edit_outlined,
            title: 'Editar Pedido',
            iconColor: Colors.blue,
            onTap: () {
              final payload = tableOrders(
                mesaId: widget.dataPedido['mesa_id'],
                number: widget.dataPedido['numero'],
                nombre: widget.dataPedido['nombre'] ?? 'temp_table',
                comensales: widget.dataPedido['pedido_activo']['comensales'],
              );
              ref.read(mesaSeleccionadaProvider.notifier).state = payload;
              final order = widget.dataPedido['pedido_activo'] != null
                ? Order.fromJson(widget.dataPedido['pedido_activo'])
                : null;
              ref.read(selectedOrderProvider.notifier).state = order;
              context.go('/mesero/registrar_pedido');
              Navigator.of(context).pop();
            },
          ),
        ),
        // const SizedBox(width: 14),
        // Expanded(
        //   child: _actionButton(
        //     icon: Icons.swap_horiz,
        //     title: 'Transferir Mesa',
        //     iconColor: Colors.white,
        //     onTap: onTransferTable,
        //   ),
        // ),
        const SizedBox(width: 14),
        Expanded(
          child: _actionButton(
            icon: Icons.attach_money,
            title: 'Solicitar Cuenta',
            iconColor: Colors.green,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String title,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(.08),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(.08),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Pedido Actual',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    // fontSize: 24,
                  ),
                ),
              ),
              Text(
                '${widget.dataPedido['pedido_activo']['items'].length} items',
                style: const TextStyle(
                  color: Colors.white70,
                  // fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          ...widget.dataPedido['pedido_activo']['items']
            .map(_buildItem)
            .toList(),

          const SizedBox(height: 20),

          Divider(
            color: Colors.white.withOpacity(.12),
          ),

          const SizedBox(height: 10),

          _priceRow(
            title: 'Subtotal',
            value: widget.dataPedido['pedido_activo']['subtotal'],
          ),
          const SizedBox(height: 5),
          _priceRow(
            title: 'IVA (${configuraciones.firstWhere((s) => s.impuesto > 0, orElse: () => Setting(impuesto: 0, propina: 0, moneda: '', descuentos: false, redondearTotales: false, impresion: false)).impuesto}%)',
            value: widget.dataPedido['pedido_activo']['iva'],
          ),
          const SizedBox(height: 5),
          _priceRow(
            title: 'Propina ${configuraciones.firstWhere((s) => s.propina > 0, orElse: () => Setting(impuesto: 0, propina: 0, moneda: '', descuentos: false, redondearTotales: false, impresion: false)).propina}%)',
            value: widget.dataPedido['pedido_activo']['propina'],
          ),

          const SizedBox(height: 5),

          _priceRow(
            title: 'Total',
            value: widget.dataPedido['pedido_activo']['total'],
            isTotal: true,
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(62),
                    side: BorderSide(
                      color: Colors.white.withOpacity(.2),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(
                    Icons.arrow_back_outlined,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Atras',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(62),
                    side: BorderSide(
                      color: Colors.white.withOpacity(.2),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(
                    Icons.print_outlined,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Imprimir',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB000),
                    minimumSize: const Size.fromHeight(62),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(
                    Icons.attach_money,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Solicitar Cuenta',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF33230B),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                '${item["cantidad"]}x',
                style: const TextStyle(
                  color: Color(0xFFFFB000),
                  fontWeight: FontWeight.bold,
                  // fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["nombre"],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    // fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$ ${NumberFormat('#,##0', 'es_CO').format(item["precio_unitario"])}',
                  style: const TextStyle(
                    color: Colors.white70,
                    // fontSize: 18,
                  ),
                ),
                if (item["observaciones"] != null && item["observaciones"] != '') ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        // size: 16,
                        color: Colors.white54,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item["observaciones"],
                          style: const TextStyle(
                            color: Colors.white60,
                            fontStyle: FontStyle.italic,
                            // fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Text(
            '\$ ${NumberFormat('#,##0', 'es_CO').format(item["total"])}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              // fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow({
    required String title,
    required double value,
    bool isTotal = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
        Text(
          '\$ ${NumberFormat('#,##0', 'es_CO').format(value)}',
          style: TextStyle(
            color: isTotal
              ? const Color(0xFFFFB000)
              : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 18 : 16,
          ),
        ),
      ],
    );
  }
}