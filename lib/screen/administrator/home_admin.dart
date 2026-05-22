import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:restopos/providers/auth_provider.dart';
import 'package:restopos/widget/left_bar.dart';

class HomeAdmin extends ConsumerStatefulWidget {
  final String? userName;
  final Widget child;

  const HomeAdmin({
    super.key,
    required this.child,
    this.userName = 'Administrador',
  });

  @override
  ConsumerState<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends ConsumerState<HomeAdmin> {
  bool sidebarVisible = true;

  @override
  void initState() {
    super.initState();
    _initializeLocalization();
  }

  Future<void> _initializeLocalization() async {
    await initializeDateFormatting('es_ES', null);
    Intl.defaultLocale = 'es_ES';
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat(
      'EEEE, d \'de\' MMMM \'del\' yyyy',
      'es_ES',
    );
    return formatter.format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: sidebarVisible ? 250 : 80,
            child: LeftBar(
              userName: widget.userName,
              collapsed: sidebarVisible,
              onToggleSidebar: () {
                setState(() => sidebarVisible = !sidebarVisible);
              },
              onLogout: () async {
                final authNotifier = ref.read(authProvider.notifier);
                await authNotifier.logout();

                if (context.mounted) {
                  context.go('/login');
                }
              },
              onMenuChanged: (option) {
                // NAVEGACIÓN CON GoRouter
                switch (option) {
                  case 'Dashboard':
                    context.go('/admin/dashboard');
                    break;
                  case 'Menú':
                    context.go('/admin/menu');
                    break;
                  case 'Usuarios':
                    context.go('/admin/users');
                    break;
                  case 'Reportes':
                    context.go('/admin/reports');
                    break;
                  case 'Configuración':
                    context.go('/admin/settings');
                    break;
                  default:
                    break;
                }
              },
            ),
          ),
          
          // Main Content
          Expanded(
            child: Container(
              color: const Color(0xFF05080B),
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  // Text(
                  //   _getTitleFromRoute(context),
                  //   style: const TextStyle(
                  //     fontSize: 40,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.white,
                  //   ),
                  // ),
                  Text(
                    _getFormattedDate(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // CONTENIDO DINÁMICO
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 👇 Mantiene tu header dinámico SIN estado local
  String _getTitleFromRoute(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    if (location.contains('dashboard')) return 'Dashboard';
    if (location.contains('menu')) return 'Menú';
    if (location.contains('users')) return 'Usuarios';

    return 'Panel';
  }
}
