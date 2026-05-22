import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:restopos/core/services/token_service.dart';
import 'package:restopos/widget/logouth_button.dart';

class LeftBar extends StatefulWidget {
  final String? userName;
  final VoidCallback? onLogout;
  final Function(String)? onMenuChanged;
  final VoidCallback? onToggleSidebar;
  final bool collapsed;

  const LeftBar({
    super.key,
    this.userName = 'Administrador',
    this.onLogout,
    this.onMenuChanged,
    this.onToggleSidebar,
    this.collapsed = false,
  });

  @override
  State<LeftBar> createState() => _LeftBarState();
}

class _LeftBarState extends State<LeftBar> {
  String? selectedOption;
  String userName = 'Usuario';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Detectar ruta actual
    final location = GoRouterState.of(context).uri.path;

    if (location.startsWith('/admin/dashboard')) {
      selectedOption = 'Dashboard';
    } else if (location.startsWith('/admin/menu')) {
      selectedOption = 'Menú';
    } else if (location.startsWith('/admin/users')) {
      selectedOption = 'Usuarios';
    } else if (location.startsWith('/admin/reports')) {
      selectedOption = 'Reportes';
    } else if (location.startsWith('/admin/settings')) {
      selectedOption = 'Configuración';
    } else {
      selectedOption ??= 'Dashboard';
    }
  }

  @override
  Widget build(BuildContext context) {
    // return AnimatedContainer(
    //   duration: const Duration(milliseconds: 250),
    //   curve: Curves.easeInOut,
    //   width: widget.collapsed ? 80 : 250,
    //   decoration: BoxDecoration(
    //     color: const Color(0xFF05080B),
    //     border: Border(
    //       right: BorderSide(color: const Color(0xFF00477B), width: 2),
    //     ),
    //   ),
    //   child: Column(
    //     children: [
    //       _buildHeader(),
    //       Expanded(child: _buildMenuItems()),
    //       _buildFooter(),
    //     ],
    //   ),
    // );

    return LayoutBuilder(
      builder: (context, constraints) {

        // if (constraints.maxWidth < 900) collapsed = true;

        return Container(
          width: (constraints.maxWidth < 900) ? 80 : widget.collapsed ? 80 : 250,
          decoration: BoxDecoration(
            color: const Color(0xFF05080B),
            border: Border(
              right: BorderSide(color: const Color(0xFF00477B), width: 2),
            ),
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildMenuItems()),
              _buildFooter(),
            ],
          ),
        );
      },
    );


  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF00477B), 
            width: 2
          )
        ),
      ),
      child: !widget.collapsed
        ? const Icon(Icons.restaurant, color: Colors.white, size: 32)
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('RestoPos',
              style: TextStyle(
                fontSize: 28, 
                fontWeight: FontWeight.w900, 
                color: Colors.white, letterSpacing: 1.5,
              )
            ),
            SizedBox(height: 5),
            Text('Panel de Administración',
              style: TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.w400, 
                color: Colors.white.withOpacity(0.6),
              )
            ),
          ],
        ),
    );
  }


  Widget _buildMenuItems() {
    final menuOptions = [
      'Dashboard',
      'Menú',
      'Usuarios',
      'Reportes',
      'Configuración',
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: menuOptions.length,
      itemBuilder: (context, index) {
        final option = menuOptions[index];
        final isSelected = selectedOption == option;

        return Tooltip(
          message: option,
          child: _buildMenuItem(
            label: option,
            isSelected: isSelected,
            onTap: () {
              setState(() => selectedOption = option);
              widget.onMenuChanged?.call(option);
            },
          ),
        );
      },
    );
  }

  // Widget _buildMenuItem({
  //   required String label,
  //   required bool isSelected,
  //   required VoidCallback onTap,
  // }) {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  //     decoration: BoxDecoration(
  //       color: isSelected ? const Color(0xFF1B170D) : Colors.transparent,
  //       borderRadius: BorderRadius.circular(8),
  //       border: Border.all(
  //         color: isSelected
  //           ? const Color(0xFFE49E22)
  //           : const Color(0xFF00477B),
  //         width: isSelected ? 2 : 1,
  //       ),
  //     ),
  //     child: Material(
  //       color: Colors.transparent,
  //       child: InkWell(
  //         onTap: onTap,
  //         borderRadius: BorderRadius.circular(8),
  //         child: Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
  //           child: Row(
  //             children: [
  //               Icon(
  //                 _getIconForOption(label),
  //                 color: isSelected
  //                   ? const Color(0xFFE49E22)
  //                   : Colors.white70,
  //                 size: 20,
  //               ),
  //               const SizedBox(width: 12),
  //               Text(
  //                 label,
  //                 style: TextStyle(
  //                   fontSize: 14,
  //                   letterSpacing: 1.5,
  //                   fontWeight: FontWeight.w500,
  //                   color: isSelected
  //                     ? const Color(0xFFE49E22)
  //                     : Colors.white70,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget _buildMenuItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1B170D) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? const Color(0xFFE49E22) : const Color(0xFF00477B),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          child: Row(
            mainAxisAlignment:
              !widget.collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(
                _getIconForOption(label),
                color: isSelected ? const Color(0xFFE49E22) : Colors.white70,
                size: 22,
              ),
              if (widget.collapsed) ...[
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? const Color(0xFFE49E22) : Colors.white70,
                  ),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }


  IconData _getIconForOption(String option) {
    switch (option) {
      case 'Dashboard':
        return Icons.bar_chart;
      case 'Menú':
        return Icons.restaurant_menu;
      case 'Usuarios':
        return Icons.people;
      case 'Reportes':
        return Icons.assessment;
      case 'Configuración':
        return Icons.settings;
      default:
        return Icons.circle;
    }
  }

  
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: const Color(0xFF00477B), 
            width: 2
          )
        ),
      ),
      child: Column(
        children: [
          Row(
            // mainAxisAlignment: widget.collapsed
            //   ? MainAxisAlignment.center
            //   : MainAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar
              if (widget.collapsed) ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE49E22),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: FutureBuilder<String>(
                      future: _getUserInitials(),
                      builder: (context, snapshot) {
                        final initials = snapshot.data ?? 'A';
                        return Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF05080B),
                            letterSpacing: 1.2,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],

              // TEXTS ONLY WHEN EXPANDED
              if (widget.collapsed) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Administrador',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // TOGGLE BUTTON (ALWAYS VISIBLE)
              IconButton(
                onPressed: widget.onToggleSidebar,
                icon: Icon(
                  !widget.collapsed ? Icons.menu : Icons.menu_open,
                  color: Colors.white70,
                ),
                tooltip: !widget.collapsed ? 'Expandir menú' : 'Ocultar menú',
              ),
            ],
          ),

          // LOGOUT ONLY WHEN EXPANDED
          if (widget.collapsed) ...[
            const SizedBox(height: 10),
            const LogoutButton(),
          ],
        ],
      ),
    );
  }


  Future<void> _loadUserName() async {
    final name = await TokenService.getName();
    if (!mounted) return;

    setState(() {
      userName = _formatName(name);
    });
  }

  String _formatName(String? name) {
    String nameFinshed = 'Usuario';
    if (name == null || name.trim().isEmpty) return 'Usuario';

    final parts = name
      .trim()
      .replaceAll(RegExp(r'[._-]+'), ' ')
      .split(RegExp(r'\s+'));

    if (parts.length == 1) return parts[0];
    if (parts.length == 2)
      nameFinshed = '${parts[0]} ${parts[1]}';
    if (parts.length > 2)
      nameFinshed = '${parts[0]} ${parts[parts.length - 2]}';

    return nameFinshed;
  }


  Future<String> _getUserInitials() async {
    final name = await TokenService.getUsuarioName();

    if (name == null || name.trim().isEmpty) return 'A';

    final parts = name
      .trim()
      .replaceAll(RegExp(r'[._-]+'), ' ')
      .split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return (parts[0][0] + parts[1][0]).toUpperCase();
  }



}
