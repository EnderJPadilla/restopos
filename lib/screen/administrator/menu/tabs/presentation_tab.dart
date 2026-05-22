import 'package:flutter/material.dart';

class PresentationTab extends StatelessWidget {
  final bool destacado;
  final bool mostrarEnPos;
  final bool mostrarEnMenuOnline;

  final ValueChanged<bool> onDestacadoChanged;
  final ValueChanged<bool> onMostrarEnPosChanged;
  final ValueChanged<bool> onMostrarEnMenuOnlineChanged;

  const PresentationTab({
    super.key,
    required this.destacado,
    required this.mostrarEnPos,
    required this.mostrarEnMenuOnline,
    required this.onDestacadoChanged,
    required this.onMostrarEnPosChanged,
    required this.onMostrarEnMenuOnlineChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E131A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon: Icons.visibility_outlined,
            text: 'Visibilidad',
          ),
          const SizedBox(height: 12),

          _switchTile(
            title: 'Destacado',
            subtitle: 'Mostrar en sección de destacados',
            value: destacado,
            onChanged: onDestacadoChanged,
          ),

          _switchTile(
            title: 'Mostrar en POS',
            subtitle: 'Visible para meseros y cajeros',
            value: mostrarEnPos,
            onChanged: onMostrarEnPosChanged,
          ),

          _switchTile(
            title: 'Mostrar en Menú Online',
            subtitle: 'Visible en pedidos online',
            value: mostrarEnMenuOnline,
            onChanged: onMostrarEnMenuOnlineChanged,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0F14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: const Color(0xFFE49E22),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
