import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:restopos/models/usuario_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restopos/providers/users_provider.dart';

class UsuariosScreen extends ConsumerWidget {
  const UsuariosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    ref.listen(userProvider, (_, __) {});
    
    final admins = ref.watch(adminsFiltradosProvider);
    final meseros = ref.watch(meserosFiltradosProvider);
    final cajeros = ref.watch(cajerosFiltradosProvider);
    
    final roles = [
      {"title": "Administradores", "users": admins},
      {"title": "Meseros", "users": meseros},
      {"title": "Cajeros", "users": cajeros},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF05080B),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context, ref),
            const SizedBox(height: 12),

            // GRID RESPONSIVE
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int columns = 1;

                  if (constraints.maxWidth > 1200) {
                    columns = 3;
                  } else if (constraints.maxWidth > 600) {
                    columns = 2;
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2, // controla altura de card
                    ),
                    itemCount: roles.length,
                    itemBuilder: (context, index) {
                      return RoleUserCard(
                        title: roles[index]["title"] as String,
                        users: roles[index]["users"] as List<Usuario>,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(refreshLoadingProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Usuarios",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)
            ),
            SizedBox(height: 4),
            Text(
              "Gestiona los usuarios del sistema",
              style: TextStyle(color: Colors.white54)
            ),
          ],
        ),
        Row(
          children: [
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
                  await ref.read(userProvider.notifier).cargarUsuarios();
                  ref.read(refreshLoadingProvider.notifier).state = false;
                },
            ),
            ElevatedButton.icon(
              onPressed: () => context.go('/admin/users/nuevo'),
              icon: const Icon(Icons.add),
              label: const Text("Nuevo Usuario"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE49E22),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ],
    );
  }

}

class RoleUserCard extends ConsumerStatefulWidget {
  final String title;
  final List<Usuario> users;

  const RoleUserCard({
    super.key,
    required this.title,
    required this.users,
  });

  @override
  ConsumerState<RoleUserCard> createState() => _RoleUserCardState();
}

class _RoleUserCardState extends ConsumerState<RoleUserCard> {
  String search = "";
  bool showActive = true;
  bool showInactive = true;

  @override
  Widget build(BuildContext context) {
    // FILTRAR USUARIOS
    final filteredUsers = widget.users.where((u) {
      final matchSearch = u.nombres.toLowerCase().contains(search.toLowerCase());
      final matchStatus =
        (u.activo && showActive) || (!u.activo && showInactive);
      return matchSearch && matchStatus;
    }).toList();

    final activos = widget.users.where((u) => u.activo).length;
    final inactivos = widget.users.where((u) => !u.activo).length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF070B10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF00477B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16
                )
              ),

              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list, color: Colors.white70),
                onSelected: (value) {
                  setState(() {
                    if (value == "activos") {
                      showActive = true;
                      showInactive = false;
                    } else if (value == "inactivos") {
                      showActive = false;
                      showInactive = true;
                    } else {
                      showActive = true;
                      showInactive = true;
                    }
                  });
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: "todos", child: Text("Todos")),
                  const PopupMenuItem(value: "activos", child: Text("Activos")),
                  const PopupMenuItem(value: "inactivos", child: Text("Inactivos")),
                ],
              ),
            ],
          ),

          const SizedBox(height: 6),

          // CONTADORES
          Row(
            children: [
              _counterBox("Activos", activos, Colors.green),
              const SizedBox(width: 8),
              _counterBox("Inactivos", inactivos, Colors.red),
            ],
          ),

          const SizedBox(height: 10),

          // SEARCH BAR
          TextField(
            onChanged: (value) => setState(() => search = value),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Buscar usuario...",
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF0E141B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),

          const SizedBox(height: 10),

          // LISTA
          Expanded(
            child: filteredUsers.isEmpty
              ? const Center(
                child: Text("Sin usuarios",
                style: TextStyle(color: Colors.white54)),
              )
              : ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  return _userItem(context, filteredUsers[index]);
                },
              ),
          ),
        ],
      ),
    );
  }

  Widget _counterBox(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        "$count $label",
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }

  Widget _userItem(BuildContext context, Usuario user) {
    final loading = ref.watch(userLoadingProvider(user.empleadoId));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Avatar iniciales
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE49E22),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                _getInitials(user.nombres),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Nombre + estado
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nombres,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  user.activo ? "Activo" : "Inactivo",
                  style: TextStyle(
                    fontSize: 11,
                    color: user.activo ? Colors.greenAccent : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),

          Row(
            children: [
              Switch(
                value: user.activo,
                onChanged: loading
                  ? null
                  : (value) {
                    ref.read(userProvider.notifier)
                      .toggleActivo(user.empleadoId, user.usuarioId, value, context);
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

              // Editar
              TextButton(
                onPressed: () {
                  // Guardar usuario seleccionado
                  ref.read(selectedUserProvider.notifier).state = user;
                  // Navegar al formulario
                  context.go('/admin/users/editar');
                },
                child: const Row(
                  children: [
                    Text("Editar", style: TextStyle(color: Colors.white70)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white54),
                  ],
                ),
              ),
              // IconButton(
              //   icon: const Icon(Icons.edit, color: Color(0xFFE49E22)),
              //   onPressed: () {
              //     // Guardar usuario seleccionado
              //     ref.read(selectedUserProvider.notifier).state = user;
              //     // Navegar al formulario
              //     context.go('/admin/usuarios/editar');
              //   },
              // ),
            ],
          ),
          
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(" ");
    return parts.length == 1 ? parts[0][0] : parts[0][0] + parts[1][0];
  }

}