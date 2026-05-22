import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:restopos/providers/auth_provider.dart';

class PinScreen extends ConsumerWidget {
  final String user;

  const PinScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF05080B),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LogoImage(),
                const SizedBox(height: 20),
                const TitleWidget(),
                const SizedBox(height: 40),
                PinPadWidget(title: user, user: user),
              ],
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: BackButtonWidget(
              onPressed: () => context.pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class LogoImage extends StatelessWidget {
  const LogoImage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.restaurant_menu,
      size: 80,
      color: Color(0xFFE49E22),
    );
  }
}

class TitleWidget extends StatelessWidget {
  const TitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'RestoPOS',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Sistema de Gestión',
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}

class BackButtonWidget extends StatefulWidget {
  final VoidCallback onPressed;

  const BackButtonWidget({super.key, required this.onPressed});

  @override
  State<BackButtonWidget> createState() => _BackButtonWidgetState();
}

class _BackButtonWidgetState extends State<BackButtonWidget> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF1B170D),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF00477B), width: 1.5),
          ),
          child: Icon(
            Icons.arrow_back,
            color: hover ? const Color(0xFFE49E22) : Colors.white,
          ),
        ),
      ),
    );
  }
}

class PinPadWidget extends ConsumerStatefulWidget {
  final String title;
  final String user;

  const PinPadWidget({
    super.key,
    required this.title,
    required this.user,
  });

  @override
  ConsumerState<PinPadWidget> createState() => _PinPadWidgetState();
}

class _PinPadWidgetState extends ConsumerState<PinPadWidget> {
  late final TextEditingController usuarioController;
  late final TextEditingController contrasenaController;
  final FocusNode _usuarioFocusNode = FocusNode();

  bool _mostrarContrasena = false;
  bool _isValidatingUser = false;
  String _lastValidatedUser = '';
  String company = '';

  @override
  void initState() {
    super.initState();

    usuarioController = TextEditingController();
    contrasenaController = TextEditingController();

    _usuarioFocusNode.addListener(_onUsuarioFocusChange);
  }

  void _onUsuarioFocusChange() {
    if (!_usuarioFocusNode.hasFocus) {
      final text = usuarioController.text.trim();

      if (text.length < 5) return;
      if (text == _lastValidatedUser) return;

      _validateUser();
    }
  }

  @override
  void dispose() {
    _usuarioFocusNode.dispose();
    usuarioController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Container(
      width: 350,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1014),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF00477B), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock, color: Color(0xFFE49E22), size: 40),
          const SizedBox(height: 15),
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'Ingrese sus credenciales',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 25),

          /// USUARIO
          TextField(
            controller: usuarioController,
            focusNode: _usuarioFocusNode,
            enabled: !authState.isLoading,
            textInputAction: TextInputAction.next,
            style: const TextStyle(color: Colors.white),
            onSubmitted: (_) {
              if (usuarioController.text.trim().length >= 5) {
                _validateUser();
              }
              FocusScope.of(context).nextFocus();
            },
            decoration: _inputDecoration(
              label: 'Usuario',
              icon: Icons.person,
            ),
          ),

          const SizedBox(height: 15),

          /// CONTRASEÑA
          TextField(
            controller: contrasenaController,
            obscureText: !_mostrarContrasena,
            enabled: !authState.isLoading,
            textInputAction: TextInputAction.send,
            style: const TextStyle(color: Colors.white),
            onSubmitted: (_) => _validateLogin(),
            decoration: _inputDecoration(
              label: 'Contraseña',
              icon: Icons.lock,
              suffix: IconButton(
                icon: Icon(
                  _mostrarContrasena
                    ? Icons.visibility
                    : Icons.visibility_off,
                  color: const Color(0xFFE49E22),
                ),
                onPressed: () => setState(() => _mostrarContrasena = !_mostrarContrasena),
              ),
            ),
          ),

          const SizedBox(height: 25),

          /// BOTÓN
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: authState.isLoading ? null : _validateLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE49E22),
              ),
              child: authState.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _validateUser() async {
    if (_isValidatingUser) return;

    final usuario = usuarioController.text.trim();
    if (usuario.length < 5) return;
    if (usuario == _lastValidatedUser) return;

    _isValidatingUser = true;
    _lastValidatedUser = usuario;

    try {
      final notifier = ref.read(authProvider.notifier);
      final success = await notifier.validateUser(usuario);

      if (!mounted) return;

      if (success) {
        company = ref.read(authProvider).value?.userBusiness ?? '';
      } else {
        company = '';
        if (mounted) {
          _showMessage('Usuario no encontrado');
        }
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Error al validar usuario');
      }
    } finally {
      _isValidatingUser = false;
    }
  }

  Future<void> _validateLogin() async {
    final usuario = usuarioController.text.trim();
    final contrasena = contrasenaController.text.trim();

    if (usuario.isEmpty || contrasena.isEmpty || company.isEmpty) {
      _showMessage('Completa todos los campos');
      return;
    }

    final notifier = ref.read(authProvider.notifier);
    final success = await notifier.validatePin(usuario, contrasena, company);

    if (!mounted) return;

    if (!success) {
      _showMessage('Credenciales incorrectas');
      contrasenaController.clear();
      return;
    }

    await _validateAndNavigate();
  }

  Future<void> _validateAndNavigate() async {
    final authStateValue = ref.read(authProvider).value;

    if (authStateValue == null) {
      _showMessage('Error: estado de sesión inválido');
      contrasenaController.clear();
      return;
    }

    if (authStateValue.userRole == null) {
      _showMessage('Acceso denegado: sin rol asignado');
      contrasenaController.clear();
      return;
    }

    if (authStateValue.userRole!.isEmpty) {
      _showMessage('Acceso denegado: rol vacío');
      contrasenaController.clear();
      return;
    }

    final userRole = authStateValue.userRole!.trim().toLowerCase();
    final requiredRole = widget.user.trim().toLowerCase();

    if (userRole != requiredRole) {
      _showMessage('Acceso denegado: rol insuficiente o incorrecto');
      contrasenaController.clear();
      return;
    }


    const roleRoutes = {
      'administrador': '/admin/dashboard',
      'mesero': '/mesero',
    };

    final route = roleRoutes[userRole];
    if (route == null) {
      _showMessage('Error: rol no configurado en el sistema');
      contrasenaController.clear();
      return;
    }
    
    if (mounted) {
      context.go(route);
    }
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: const Color(0xFFE49E22)),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFF1B170D),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF00477B), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF00477B), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE49E22), width: 2),
      ),
    );
  }
}
