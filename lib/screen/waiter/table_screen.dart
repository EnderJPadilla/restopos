import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restopos/models/table_model.dart';
import 'package:restopos/providers/order_provider.dart';
import 'package:restopos/screen/waiter/abrir_mesa_modal.dart';

class AppColors {
  static const background =  Color(0xFF05080B);

  static const green = Color(0xFF00C853);
  static const greenSoft = Color(0xFF0F2D1F);

  static const orange = Color(0xFFFFA000);
  static const orangeSoft = Color(0xFF2A1E0F);

  static const blue = Color(0xFF2196F3);
  static const blueSoft = Color(0xFF0E2235);

  static const greySoft = Color(0xFF1C2433);
}

class TableScreen extends StatefulWidget {
  const TableScreen({super.key});

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  TableStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final allTables = List.generate(12, (i) {
      if (i == 2) {
        return TableModel(
          id: "table_3",
          number: 3,
          name: "Preparando",
          maximumCapacity: 2,
          status: TableStatus.ocupada,
        );
      }

      if (i == 5) {
        return TableModel(
          id: "table_6",
          number: 6,
          maximumCapacity: 4,
          status: TableStatus.ocupada,
          name: "Listo",
        );
      }

      if (i == 8) {
        return TableModel(
          id: "table_9",
          number: 9,
          maximumCapacity: 6,
          status: TableStatus.ocupada,
          name: "Registrado",
        );
      }

      if (i == 10) {
        return TableModel(
          id: "table_11",
          number: 11,
          maximumCapacity: 6,
          status: TableStatus.reservada,
          name: "Reservada",
        );
      }

      return TableModel(
        id: "table_${i + 1}",
        number: i + 1,
        maximumCapacity: (i % 4) + 2,
        status: TableStatus.disponible,
      );
    });

    final availableCount = allTables.where((t) => t.status == TableStatus.disponible).length;
    final occupiedCount = allTables.where((t) => t.status == TableStatus.ocupada).length;
    final reservedCount = allTables.where((t) => t.status == TableStatus.reservada).length;

    final tables = _filterStatus == null
      ? allTables
      : allTables.where((t) => t.status == _filterStatus).toList();

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          SummaryRow(
            selectedStatus: _filterStatus,
            onSelectStatus: (status) => setState(() => _filterStatus = status),
            availableCount: availableCount,
            occupiedCount: occupiedCount,
            reservedCount: reservedCount,
          ),
          const SizedBox(height: 25),
          Expanded(
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
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: tables.length,
                  itemBuilder: (context, index) {
                    return TableCard(table: tables[index]);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          if (_filterStatus != null)
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => setState(() => _filterStatus = null),
              child: const Text(
                'Mostrar todas',
                style: TextStyle(color: Colors.white70),
              ),
            ),
        ],
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  final TableStatus? selectedStatus;
  final void Function(TableStatus? status) onSelectStatus;
  final int availableCount;
  final int occupiedCount;
  final int reservedCount;

  const SummaryRow({
    super.key,
    required this.selectedStatus,
    required this.onSelectStatus,
    required this.availableCount,
    required this.occupiedCount,
    required this.reservedCount,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 720;

        Widget buildCard({
          required Color color,
          required String title,
          required String subtitle,
          required int count,
          required TableStatus status,
        }) {
          final isSelected = selectedStatus == status;
          return GestureDetector(
            onTap: () => onSelectStatus(status),
            child: SummaryCard(
              color: color,
              title: title,
              subtitle: subtitle,
              count: count,
              selected: isSelected,
            ),
          );
        }

        if (isMobile) {
          return Column(
            children: [
              buildCard(
                color: AppColors.green,
                title: "Disponibles",
                subtitle: "Listas para asignar",
                count: availableCount,
                status: TableStatus.disponible,
              ),
              const SizedBox(height: 16),
              buildCard(
                color: AppColors.orange,
                title: "Ocupadas",
                subtitle: "Con pedidos activos",
                count: occupiedCount,
                status: TableStatus.ocupada,
              ),
              const SizedBox(height: 16),
              buildCard(
                color: AppColors.blue,
                title: "Reservadas",
                subtitle: "Pendientes",
                count: reservedCount,
                status: TableStatus.reservada,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: buildCard(
                color: AppColors.green,
                title: "Disponibles",
                subtitle: "Listas para asignar",
                count: availableCount,
                status: TableStatus.disponible,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: buildCard(
                color: AppColors.orange,
                title: "Ocupadas",
                subtitle: "Con pedidos activos",
                count: occupiedCount,
                status: TableStatus.ocupada,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: buildCard(
                color: AppColors.blue,
                title: "Reservadas",
                subtitle: "Pendientes",
                count: reservedCount,
                status: TableStatus.reservada,
              ),
            ),
          ],
        );
      },
    );
  }
}

class SummaryCard extends StatelessWidget {
  final Color color;
  final String title;
  final String subtitle;
  final int count;
  final bool selected;

  const SummaryCard({
    super.key,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.count,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: selected ? color.withOpacity(0.2) : AppColors.greySoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? color : Colors.transparent,
          width: selected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(.2),
            child: Text(
              count.toString(),
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                )
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white54),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class TableCard extends ConsumerWidget {
  final TableModel table;

  const TableCard({super.key, required this.table});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color borderColor;
    Color backgroundColor;

    switch (table.status) {
      case TableStatus.disponible:
        borderColor = AppColors.green;
        backgroundColor = AppColors.greenSoft;
        break;
      case TableStatus.ocupada:
        borderColor = AppColors.orange;
        backgroundColor = AppColors.orangeSoft;
        break;
      case TableStatus.reservada:
        borderColor = Colors.grey;
        backgroundColor = AppColors.greySoft;
        break;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Guardar mesa seleccionada
          ref.read(selectedTableProvider.notifier).state = table;
          mostrarModalAbrirMesa(context, table);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                table.number.toString(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 16, 
                    color: Colors.white54
                  ),
                  const SizedBox(width: 4),
                  Text(
                    table.maximumCapacity.toString(),
                    style: const TextStyle(color: Colors.white54),
                  )
                ],
              ),
              if (table.name != null) ...[
                const SizedBox(height: 12),
                FractionallySizedBox(
                  widthFactor: 0.9,
                  child: Container(
                    padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        table.name!,
                        style: TextStyle(color: borderColor, fontSize: 12),
                      ),
                    )
                  ),
                ),
              ],
              // if (table.time != null) ...[
              //   const SizedBox(height: 8),
              //   Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       const Icon(Icons.access_time,
              //         size: 14, color: Colors.white38),
              //       const SizedBox(width: 4),
              //       Text(
              //         table.time!,
              //         style:
              //           const TextStyle(color: Colors.white38, fontSize: 12),
              //       )
              //     ],
              //   )
              // ]
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> mostrarModalAbrirMesa(BuildContext context, TableModel mesa) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AbrirMesaModal(mesa: mesa),
  );
}