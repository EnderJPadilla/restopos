import 'package:flutter/material.dart';

class MesasWidget extends StatefulWidget {
  const MesasWidget({super.key});

  @override
  State<MesasWidget> createState() => _MesasWidgetState();
}

class _MesasWidgetState extends State<MesasWidget> {

  final TextEditingController searchController = TextEditingController();

  String zonaSeleccionada = "Todas";

  final zonas = ["Todas", "Interior", "Terraza", "Privado"];

  List<Mesa> mesas = [
    Mesa(id: 1, capacidad: 2, zona: "Interior", forma: "Cuadrada", activo: false),
    Mesa(id: 2, capacidad: 2, zona: "Interior", forma: "Cuadrada", activo: true),
    Mesa(id: 3, capacidad: 2, zona: "Interior", forma: "Cuadrada", activo: true),
    Mesa(id: 4, capacidad: 2, zona: "Interior", forma: "Cuadrada", activo: true),
    Mesa(id: 5, capacidad: 4, zona: "Interior", forma: "Redonda", activo: true),
    Mesa(id: 6, capacidad: 4, zona: "Interior", forma: "Redonda", activo: true),
    Mesa(id: 7, capacidad: 4, zona: "Terraza", forma: "Redonda", activo: true),
  ];

  List<Mesa> get mesasFiltradas {
    return mesas.where((m) {
      final matchBusqueda = m.id
        .toString()
        .contains(searchController.text);

      final matchZona = zonaSeleccionada == "Todas"
        ? true
        : m.zona == zonaSeleccionada;

      return matchBusqueda && matchZona;
    }).toList();
  }

  int get totalAsientos {
    return mesas.fold(0, (sum, m) => sum + m.capacidad);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Mesas",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold
                      )
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${mesas.length} mesas · $totalAsientos asientos totales",
                      style: const TextStyle(color: Colors.grey),
                    )
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.add, color: Colors.black),
                  label: const Text("Nueva Mesa",
                    style: TextStyle(color: Colors.black)
                  ),
                )
              ],
            ),

            const SizedBox(height: 20),

            /// BUSQUEDA Y FILTRO
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Buscar por número o nombre...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF0B1220),
                      prefixIcon:
                        const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF1E293B)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                DropdownButton<String>(
                  value: zonaSeleccionada,
                  dropdownColor: const Color(0xFF0B1220),
                  items: zonas
                    .map((z) => DropdownMenuItem(
                      value: z,
                      child: Text(z,
                        style: const TextStyle(
                          color: Colors.white
                        )
                      ),
                    ))
                    .toList(),
                  onChanged: (v) {
                    setState(() => zonaSeleccionada = v!);
                  },
                ),
              ],
            ),

            const SizedBox(height: 15),

            /// CHIPS DE ZONA
            Row(
              children: [
                _zonaChip("Interior", 5),
                _zonaChip("Terraza", 1),
                _zonaChip("Privado", 2),
              ],
            ),

            const SizedBox(height: 20),

            /// LISTA
            Expanded(
              child: ListView.builder(
                itemCount: mesasFiltradas.length,
                itemBuilder: (_, i) {
                  return mesaItem(mesasFiltradas[i]);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _zonaChip(String zona, int count) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text("$zona: $count",
          style: const TextStyle(color: Colors.white)),
    );
  }

  Widget mesaItem(Mesa mesa) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        children: [

          /// NUMERO
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: _colorMesa(mesa.id),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                mesa.id.toString(),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(width: 15),

          /// INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  children: [
                    Text("Mesa ${mesa.id}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),

                    if (!mesa.activo)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text("Deshabilitada",
                            style: TextStyle(
                                color: Colors.red, fontSize: 12)),
                      )
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  "👥 ${mesa.capacidad} personas · 📍 ${mesa.zona} · ${mesa.forma}",
                  style: const TextStyle(color: Colors.grey),
                )
              ],
            ),
          ),

          /// SWITCH + ACCIONES
          Row(
            children: [

              Switch(
                value: mesa.activo,
                activeColor: const Color(0xFFF59E0B),
                onChanged: (v) {
                  setState(() => mesa.activo = v);
                },
              ),

              const SizedBox(width: 10),

              _iconBtn(Icons.copy),
              _iconBtn(Icons.edit),
              _iconBtn(Icons.delete, color: Colors.red),
            ],
          )
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, {Color color = Colors.white}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Color _colorMesa(int numero) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.pink,
      Colors.teal,
    ];
    return colors[numero % colors.length].withOpacity(0.4);
  }
}

class Mesa {
  final int id;
  final int capacidad;
  final String zona;
  final String forma;
  bool activo;

  Mesa({
    required this.id,
    required this.capacidad,
    required this.zona,
    required this.forma,
    this.activo = true,
  });
}