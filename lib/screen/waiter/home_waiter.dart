import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restopos/screen/waiter/table_screen.dart';
import 'package:restopos/screen/waiter/record_screen.dart';
import 'package:restopos/providers/auth_provider.dart';

// The waiter home now reads the current user from authProvider; no username
// parameter is passed via the route any longer.
class HomeWaiter extends ConsumerStatefulWidget {
  const HomeWaiter({super.key});

  @override
  ConsumerState<HomeWaiter> createState() => _HomeWaiterState();
}

class _HomeWaiterState extends ConsumerState<HomeWaiter> {
  String _selectedView = 'mesas';
  bool _isDrawerOpen = false;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final username = auth.value?.username ?? 'Mesero';

    return Scaffold(
      backgroundColor: const Color(0xFF05080B),
      appBar: _buildAppBar(username),
      body: _buildContent(),
    );
  }

  AppBar _buildAppBar(String username) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return AppBar(
      backgroundColor: const Color(0xFF0C1014),
      elevation: 1,
      shadowColor: const Color(0xFF00477B),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RestoPOS',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
          Text(
            username,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFFB0B0B0),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: IconButton(
          icon: const Icon(Icons.restaurant_menu, color: Color(0xFFE49E22), size: 28),
          onPressed: () {
            setState(() => _isDrawerOpen = !_isDrawerOpen);
            // Aquí puedes implementar el drawer/menu si lo necesitas
          },
        ),
      ),
      actions: isMobile
      ? [
        // Botón Mesas
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Center(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedView = 'mesas');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedView == 'mesas'
                      ? const Color(0xFFE49E22)
                      : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _selectedView == 'mesas'
                        ? const Color(0xFFE49E22)
                        : const Color(0xFF00477B),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.table_bar,
                    color: _selectedView == 'mesas' ? Colors.white : Colors.white70,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Botón Historial
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Center(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedView = 'historial');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedView == 'historial'
                      ? const Color(0xFFE49E22)
                      : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _selectedView == 'historial'
                        ? const Color(0xFFE49E22)
                        : const Color(0xFF00477B),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.history,
                    color: _selectedView == 'historial' ? Colors.white : Colors.white70,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Botón Reservas
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Center(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedView = 'reservas');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedView == 'reservas'
                      ? const Color(0xFFE49E22)
                      : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _selectedView == 'reservas'
                        ? const Color(0xFFE49E22)
                        : const Color(0xFF00477B),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.event,
                    color: _selectedView == 'reservas' ? Colors.white : Colors.white70,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Botón Cerrar Sesión
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFE49E22), size: 24),
            onPressed: () {
              _showLogoutDialog();
            },
            tooltip: 'Cerrar sesión',
          ),
        ),
      ]
      : [
        // Botón Mesas
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Center(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedView = 'mesas');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedView == 'mesas'
                      ? const Color(0xFFE49E22)
                      : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _selectedView == 'mesas'
                        ? const Color(0xFFE49E22)
                        : const Color(0xFF00477B),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    'Mesas',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _selectedView == 'mesas' ? Colors.white : Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Botón Historial
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Center(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedView = 'historial');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedView == 'historial'
                      ? const Color(0xFFE49E22)
                      : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _selectedView == 'historial'
                        ? const Color(0xFFE49E22)
                        : const Color(0xFF00477B),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    'Historial',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _selectedView == 'historial'
                        ? Colors.white
                        : Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Botón Reservas
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Center(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedView = 'reservas');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedView == 'reservas'
                      ? const Color(0xFFE49E22)
                      : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _selectedView == 'reservas'
                        ? const Color(0xFFE49E22)
                        : const Color(0xFF00477B),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    'Reservas',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _selectedView == 'reservas' ? Colors.white : Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Botón Cerrar Sesión
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFE49E22), size: 24),
            onPressed: () {
              _showLogoutDialog();
            },
            tooltip: 'Cerrar sesión',
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    switch (_selectedView) {
      case 'mesas':
        return const TableScreen();
      case 'historial':
        return const RecordScreen();
      default:
        return const TableScreen();
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0C1014),
          title: const Text(
            'Cerrar Sesión',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            '¿Estás seguro de que deseas cerrar sesión?',
            style: TextStyle(color: Color(0xFFB0B0B0)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFFE49E22)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                // Aquí puedes agregar lógica adicional para cerrar sesión
              },
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
