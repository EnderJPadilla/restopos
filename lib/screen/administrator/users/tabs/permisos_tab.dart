import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restopos/models/usuario_model.dart';
import 'package:restopos/providers/users_provider.dart';

// final rolSeleccionadoProvider = StateProvider<String>((ref) => "" );

class PermisosTab extends ConsumerStatefulWidget {
  
  // final Map<String, List<Permiso>>? permisos;
  final Map<String, bool> permisos;

  const PermisosTab({
    super.key,
    required this.permisos,
  });

  @override
  ConsumerState<PermisosTab> createState() => _PermisosTabState();
}

class _PermisosTabState extends ConsumerState<PermisosTab>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  bool loaded = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!loaded) {
      loaded = true;
      ref.read(permisosProvider.notifier).cargarPermisos(widget.permisos);
    }
  });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final permisos = ref.watch(permisosProvider);
    final rolSeleccionado = ref.watch(rolSeleccionadoProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF121821),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          LayoutBuilder(
            builder: (context, constraints) {

              final isSmallScreen = constraints.maxWidth > 800;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isSmallScreen
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Row(
                          children: [
                            Icon(Icons.shield, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "Permisos del Sistema",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const Spacer(),
                            const Text("Plantilla:", style: TextStyle(color: Colors.white70)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                _roleChip("Administrador", rolSeleccionado == "Administrador"),
                                _roleChip("Mesero", rolSeleccionado == "Mesero"),
                                _roleChip("Cajero", rolSeleccionado == "Cajero"),
                                _roleChip("Limpiar", rolSeleccionado == "Limpiar"),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          "Configura que acciones puede realizar este usuario",
                          style: TextStyle(color: Colors.white54),
                        ),

                      ],
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Row(
                          children: const [
                            Icon(Icons.shield, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "Permisos del Sistema",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          "Configura que acciones puede realizar este usuario",
                          style: TextStyle(color: Colors.white54),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            const Text("Plantilla:", style: TextStyle(color: Colors.white70)),
                            const SizedBox(width: 8),
                            _roleChip("Administrador", rolSeleccionado == "Administrador"),
                            _roleChip("Mesero", rolSeleccionado == "Mesero"),
                            _roleChip("Cajero", rolSeleccionado == "Cajero"),
                            _roleChip("Limpiar", rolSeleccionado == "Limpiar"),
                          ],
                        )
                        
                      ],
                    ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {

                int columns = 4;
                if (constraints.maxWidth < 1200) columns = 3;
                if (constraints.maxWidth < 900) columns = 2;
                if (constraints.maxWidth < 600) columns = 1;

                return GridView(
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.2,
                  ),
                  children: [
                    _permisoGrupo("Dashboard y Reportes", Icons.bar_chart, permisos["dashboard"]!, "dashboard"),
                    _permisoGrupo("Pedidos", Icons.receipt, permisos["pedidos"]!, "pedidos"),
                    _permisoGrupo("Menu y Productos", Icons.restaurant_menu, permisos["menu"]!, "menu"),
                    _permisoGrupo("Pagos y Caja", Icons.credit_card, permisos["pagos"]!, "pagos"),
                    _permisoGrupo("Usuarios", Icons.people, permisos["usuarios"]!, "usuarios"),
                    _permisoGrupo("Mesas e Inventario", Icons.table_bar, permisos["mesas"]!, "mesas"),
                    _permisoGrupo("Sistema", Icons.settings, permisos["sistema"]!, "sistema"),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  
  }

  Widget _permisoGrupo(
    String title,
    IconData icon,
    List<Permiso> permisos,
    String groupKey,
  ) {
    return Container(
      height: 280, 
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF121821),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // HEADER CARD
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),

          const SizedBox(height: 6),
          const Divider(color: Colors.white12),

          // LISTA SCROLL INTERNO
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: permisos.length,
              itemBuilder: (context, index) {
                final p = permisos[index];

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        p.key,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Switch(
                      value: p.activo,
                      onChanged: (_) => ref.read(permisosProvider.notifier).toggle(groupKey, p.key),
                      activeColor: const Color(0xFFE49E22),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleChip(String text, bool selected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          ref.read(rolSeleccionadoProvider.notifier).state = text;
          ref.read(permisosProvider.notifier).aplicarRol(text);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE49E22) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selected ? Colors.transparent : Colors.white24),
          ),
          child: Text(
            text,
            style: TextStyle(color: selected ? Colors.black : Colors.white70),
          ),
        ),
      ),
    );
  }



}

