import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    
    return Scaffold(
      backgroundColor: Color(0xFF05080B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LogoImage(),
            SizedBox(height: 20),
            Title(),
            SizedBox(height: 20),
            isMobile 
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ButtonSession(
                    icon: Icons.verified_user,
                    name: 'Administrador',
                    description: 'Dashboard, reportes y Configuración',
                    isMobile: isMobile,
                    onPressed: () => context.pushNamed(
                      'pin',
                      pathParameters: {'user': 'Administrador'},
                    ),
                  ),
                  SizedBox(height: 20),
                  ButtonSession(
                    icon: Icons.add_card,
                    name: 'Cajero',
                    description: 'Cobros y Facturas',
                    isMobile: isMobile,
                    onPressed: () => context.pushNamed(
                      'pin',
                      pathParameters: {'user': 'Cajero'},
                    ),
                  ),
                  SizedBox(height: 20),
                  ButtonSession(
                    icon: Icons.people_alt,
                    name: 'Mesero',
                    description: 'Pedidos y mesas',
                    isMobile: isMobile,
                    onPressed: () => context.pushNamed(
                      'pin',
                      pathParameters: {'user': 'Mesero'},
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ButtonSession(
                    icon: Icons.verified_user,
                    name: 'Administrador',
                    description: 'Dashboard, reportes y Configuración',
                    isMobile: isMobile,
                    onPressed: () => context.pushNamed(
                      'pin',
                      pathParameters: {'user': 'Administrador'},
                    ),
                  ),
                  SizedBox(width: 15),
                  ButtonSession(
                    icon: Icons.add_card,
                    name: 'Cajero',
                    description: 'Cobros y Facturas',
                    isMobile: isMobile,
                    onPressed: () => context.pushNamed(
                      'pin',
                      pathParameters: {'user': 'Cajero'},
                    ),
                  ),
                  SizedBox(width: 15),
                  ButtonSession(
                    icon: Icons.people_alt,
                    name: 'Mesero',
                    description: 'Pedidos y mesas',
                    isMobile: isMobile,
                    onPressed: () => context.pushNamed(
                      'pin',
                      pathParameters: {'user': 'Mesero'},
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}


class LogoImage extends StatelessWidget {
  const LogoImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconWidget(
      width: 80,
      height: 80,
      icon: Icons.restaurant_menu,
      color: const Color(0xFFE49E22),
      size: 60,
    );
  }
}

class IconWidget extends StatelessWidget {
  final double width;
  final double height;
  final IconData icon;
  final Color color;
  final double size;

  const IconWidget({
    super.key,
    required this.width,
    required this.height,
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color(0xFF1B170D),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        icon,
        color: color,
        size: size,
      ),
    );
    
  }
}

class Title extends StatelessWidget {
  const Title({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('RestoPOS',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 2.0,
          )
        ),
        SizedBox(height: 10),
        Text('Sistema de Gestión',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFFFFFFF).withOpacity(0.5),
          )
        ),
      ],
    );
  }
}

class ButtonSession extends StatefulWidget {
  final IconData icon;
  final String name;
  final String description;
  final bool isMobile;
  final VoidCallback? onPressed;

  const ButtonSession({
    super.key,
    required this.icon,
    required this.name,
    required this.description,
    required this.isMobile,
    this.onPressed,
  });

  @override
  State<ButtonSession> createState() => _ButtonSessionState();
}

class _ButtonSessionState extends State<ButtonSession> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: widget.isMobile 
          ? Container(
            width: 300,
            height: 90,
            decoration: BoxDecoration(
              color: Color(0xFF0C1014),
              border: Border.all(
                color: isHovered ? Colors.green : Color(0xFF00477B),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 20),
                IconWidget(
                  width: 50,
                  height: 50,
                  icon: widget.icon,
                  color: const Color(0xFFE49E22),
                  size: 25,
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        widget.description,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
          : Container(
            width: 250,
            height: 200,
            decoration: BoxDecoration(
              color: Color(0xFF0C1014),
              border: Border.all(
                color: isHovered ? Colors.green : Color(0xFF00477B),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconWidget(
                  width: 50,
                  height: 50,
                  icon: widget.icon,
                  color: const Color(0xFFE49E22),
                  size: 25,
                ),
                SizedBox(height: 20),
                Text(
                  widget.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    widget.description,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }
}