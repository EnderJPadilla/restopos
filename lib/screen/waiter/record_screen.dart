import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF05080B);
  static const card = Color(0xFF070B10);
  static const border = Color(0xFF00477B);
  static const accent = Color(0xFFFFA000);
  static const textGrey = Color(0xFF9CA3AF);

  static const preparando = Color(0xFFF59E0B);
  static const listo = Color(0xFF22C55E);
  static const registrado = Color(0xFF3B82F6);
}

class PedidoProducto {
  final String nombre;
  final int cantidad;
  final double precio;

  PedidoProducto({
    required this.nombre,
    required this.cantidad,
    required this.precio,
  });
}

class Pedido {
  final int mesa;
  final String hora;
  final String estado;
  final List<PedidoProducto> productos;

  Pedido({
    required this.mesa,
    required this.hora,
    required this.estado,
    required this.productos,
  });

  double get total {
    double t = 0;
    for (var p in productos) {
      t += p.precio;
    }
    return t;
  }
}

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {

  /// Simulación de datos (aquí conectarás tu API o BD)
  List<Pedido> pedidos = [
    Pedido(
      mesa: 3,
      hora: "09:43 a.m.",
      estado: "Preparando",
      productos: [
        PedidoProducto(nombre: "Ensalada César", cantidad: 2, precio: 170),
        PedidoProducto(nombre: "Filete de Res", cantidad: 1, precio: 320),
        PedidoProducto(nombre: "Cerveza Nacional", cantidad: 2, precio: 110),
      ],
    ),
    Pedido(
      mesa: 6,
      hora: "09:13 a.m.",
      estado: "Listo",
      productos: [
        PedidoProducto(nombre: "Pollo a la Parrilla", cantidad: 2, precio: 390),
        PedidoProducto(nombre: "Agua Fresca", cantidad: 2, precio: 70),
      ],
    ),
    Pedido(
      mesa: 9,
      hora: "10:03 a.m.",
      estado: "Registrado",
      productos: [
        PedidoProducto(nombre: "Parrillada Especial", cantidad: 1, precio: 550),
        PedidoProducto(nombre: "Margarita", cantidad: 2, precio: 190),
      ],
    ),
  ];

  Color estadoColor(String estado) {
    switch (estado) {
      case "Preparando":
        return AppColors.preparando;
      case "Listo":
        return AppColors.listo;
      default:
        return AppColors.registrado;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Mis Pedidos del Día",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: pedidos.length,
                itemBuilder: (context, index) {
                  return pedidoCard(pedidos[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget pedidoCard(Pedido pedido) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
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
                        pedido.mesa.toString(),
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
                    "Mesa ${pedido.mesa}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 14, color: AppColors.textGrey),
                      const SizedBox(width: 4),
                      Text(
                        pedido.hora,
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
                  border: Border.all(color: estadoColor(pedido.estado)),
                ),
                child: Text(
                  pedido.estado,
                  style: TextStyle(
                    color: estadoColor(pedido.estado),
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
                children: pedido.productos.map((p) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${p.cantidad}x ${p.nombre}",
                            style: const TextStyle(
                              color: AppColors.textGrey,
                            ),
                          ),
                        ),
                        Text(
                          "\$${p.precio.toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.white),
                        )
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
                    "Total: \$${pedido.total.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const Spacer(),

                  outlinedButton(Icons.print, "Reimprimir"),

                  const SizedBox(width: 10),

                  if (pedido.estado != "Listo")
                    outlinedButton(Icons.edit, "Editar"),
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
}