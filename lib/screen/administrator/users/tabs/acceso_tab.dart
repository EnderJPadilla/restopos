import 'package:flutter/material.dart';
import 'package:restopos/widget/app_inputs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restopos/providers/users_provider.dart';


// final rolSeleccionadoProvider = StateProvider<String>((ref) => "");

class AccesoTab extends ConsumerStatefulWidget {
  
  final TextEditingController nombreUsuarioController;
  final String? rolSeleccionado;
  final List<String> roles;
  final TextEditingController pinSecretController;
  final bool cambioPin;
  final bool isEditMode;

  final ValueChanged<String?> onRolChanged;
  final ValueChanged<bool> onCambioPinChanged;

  const AccesoTab({
    super.key,
    required this.nombreUsuarioController,
    required this.rolSeleccionado,
    required this.roles,
    required this.pinSecretController,
    required this.cambioPin,
    required this.isEditMode,
    required this.onRolChanged,
    required this.onCambioPinChanged,
  });

  @override
  ConsumerState<AccesoTab> createState() => _AccesoTabState();
}


class _AccesoTabState extends ConsumerState<AccesoTab>
  with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  bool _mostrarContrasena = false;

  
  final FocusNode _userFocusNode = FocusNode();
  bool _isValidatingUser = false;
  String _lastValidatedUser = '';

  @override
  void initState() {
    super.initState();

    _userFocusNode.addListener(_onUsuarioFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onUsuarioFocusChange() {
    final usuario = ref.read(selectedUserProvider);
    if (!_userFocusNode.hasFocus) {
      final text = widget.nombreUsuarioController.text.trim();

      if (text.length < 5) return;
      if (text == _lastValidatedUser) return;

      // Only validate when not editing or name has changed from the original
      if (usuario == null || usuario.nombreUsuario != widget.nombreUsuarioController.text) {
        _validateNombreUsuario();
      }
    }
  }
    
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final rolSeleccionado = ref.watch(rolSeleccionadoProvider);
    final usuarioSelect = ref.read(selectedUserProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF121821),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _baseCard(
            title: "Credenciales de Acceso",
            subtitle: "Datos de autenticacion para ingresar al sistema",
            icon: Icons.key_outlined,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: 
                      TextField(
                        controller: widget.nombreUsuarioController,
                        focusNode: _userFocusNode,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(color: Colors.white),
                        onSubmitted: (_) {
                          if (usuarioSelect?.nombreUsuario != widget.nombreUsuarioController.text.trim().length >= 5) {
                            _validateNombreUsuario();
                            FocusScope.of(context).nextFocus();
                          }
                        },
                        decoration: _inputDecoration(
                          label: 'Nombre de usuario *', 
                          hint: 'Nombre de usuario para el sistema'
                        ),
                      ),
                      // appTextInput(
                      //   controller: widget.nombreUsuarioController,
                      //   label: 'Nombre de usuario *',
                      //   hint: 'Nombre de usuario para el sistema',
                      //   validator: (v) =>
                      //     v == null || v.isEmpty ? 'Campo requerido' : null,
                      // ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: widget.rolSeleccionado,
                        items: widget.roles
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c, style: const TextStyle(color: Colors.white)),
                            ),
                          )
                          .toList(),
                        onChanged: (value) {
                          widget.onRolChanged(value);
                          ref.read(rolSeleccionadoProvider.notifier).state = value!;
                          ref.read(permisosProvider.notifier).aplicarRol(value);
                        },
                        validator: (v) =>
                          v == null ? 'Seleccione un rol' : null,
                        decoration: appDecoration('Rol en el Sistema *'),
                        dropdownColor: const Color(0xFF0B0F14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: appPasswordInput(
                          controller: widget.pinSecretController,
                          label: 'PIN de acceso *',
                          hint: 'PIN de acceso al sistema',
                          validator: (v) {
                            // Si es creación (no edit mode) se requiere PIN
                            if (!widget.isEditMode) {
                              return v == null || v.isEmpty ? 'Campo requerido' : null;
                            }
                            // Si estamos en edición, sólo requerir PIN si se marcó cambio de PIN
                            if (widget.isEditMode && widget.cambioPin) {
                              return v == null || v.isEmpty ? 'Campo requerido' : null;
                            }
                            return null;
                          },
                          obscureText: !_mostrarContrasena,
                          suffix: IconButton(
                            icon: Icon(
                              _mostrarContrasena
                                ? Icons.visibility
                                : Icons.visibility_off,
                              color: const Color(0xFFE49E22),
                            ),
                            onPressed: () =>
                              setState(() => _mostrarContrasena = !_mostrarContrasena),
                          ),
                        ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: widget.cambioPin,
                        onChanged: widget.onCambioPinChanged,
                        activeColor: const Color(0xFFE49E22),
                        title: const Text(
                          'Requiere Cambio de PIN',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: const Text(
                          'El usuario debera cambiar su PIN en el proximo inicio de sesion',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    )
                    
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
    
  }

  _baseCard({
    required String title,
    required String? subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Colors.white54)),
        ],
        const SizedBox(height: 20),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    bool hasError = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Color(0xFF0B0F14),
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white38),
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: hasError ? Colors.redAccent : Colors.transparent,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE49E22), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  Future<void> _validateNombreUsuario() async {
    if (_isValidatingUser) return;

    final nameUsuario = widget.nombreUsuarioController.text.trim();
    if (nameUsuario.length < 5) return;
    if (nameUsuario == _lastValidatedUser) return;

    _isValidatingUser = true;
    _lastValidatedUser = nameUsuario;

    try {
      final provider = ref.read(userProvider.notifier);
      final success = await provider.validateUserName(nameUsuario, context);

      if (!success) {
        widget.nombreUsuarioController.text = '';
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Nombre de Usuario no disponible. Ya existe otro Usuario con el nombre: $nameUsuario'
            ),
            backgroundColor: Colors.red
          ),
        );
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al validar el nombre del Usuario.'),
          backgroundColor: Colors.red
        ),
      );
    } finally {
      _isValidatingUser = false;
    }
  }

}