import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:restopos/providers/order_provider.dart';

import 'package:restopos/models/order_model.dart';
import 'package:restopos/models/table_model.dart';

class AbrirMesaModal extends ConsumerStatefulWidget {
  final TableModel mesa;

  const AbrirMesaModal({super.key, required this.mesa});

  @override
  ConsumerState<AbrirMesaModal> createState() => _AbrirMesaModalState();
}

class _AbrirMesaModalState extends ConsumerState<AbrirMesaModal> {
  int cantidad = 1;
  late List<TextEditingController> controllers;
  late List<bool> errores;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // controllers = List.generate(
    //   cantidad,
    //   (_) => TextEditingController(),
    // );
    controllers = [TextEditingController()];
    errores = [false];
  }

  void actualizarCantidad(int nuevaCantidad) {
    if (nuevaCantidad < 1 || nuevaCantidad > widget.mesa.maximumCapacity) return;

    if (nuevaCantidad > cantidad) {
      // AGREGAR
      controllers.add(TextEditingController());
      errores.add(false);
      _listKey.currentState?.insertItem(cantidad,
        duration: const Duration(milliseconds: 300)
      );
    } else {
      // ELIMINAR
      final removedController = controllers.removeLast();
      errores.removeLast();

      _listKey.currentState?.removeItem(
        cantidad - 1,
        (context, animation) => _buildAnimatedItem(
          removedController,
          cantidad - 1,
          animation,
        ),
        duration: const Duration(milliseconds: 300),
      );
    }

    setState(() {
      cantidad = nuevaCantidad;
    });
  }

  void validarYAbrir() {
    bool hayErrores = false;

    for (int i = 0; i < controllers.length; i++) {
      if (controllers[i].text.trim().isEmpty) {
        errores[i] = true;
        hayErrores = true;
      } else {
        errores[i] = false;
      }
    }

    setState(() {});

    if (hayErrores) return;

    final nombres = controllers.map((c) => c.text.trim()).toList();

    Navigator.pop(context, nombres);
  }

  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _buildAnimatedItem(
    TextEditingController controller,
    int index,
    Animation<double> animation) 
  {
    return SizeTransition(
      sizeFactor: animation,
      child: _buildTextField(controller, index),
    );
  }

  Widget _buildTextField(TextEditingController controller, int index) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        onChanged: (_) {
          if (errores[index]) {
            setState(() => errores[index] = false);
          }
        },
        decoration: InputDecoration(
          labelText: "Asistente ${index + 1}",
          hintText: "Nombre asistente ${index + 1}",
          errorText: errores[index] ? "Este campo es obligatorio" : null,
          filled: true,
          fillColor: const Color(0xFF0B0F14),
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: const TextStyle(color: Colors.white38),
          errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            // borderSide: BorderSide(
            //   color: hasError ? Colors.redAccent : Colors.transparent,
            // ),
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF05080B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Abrir Mesa ${widget.mesa.number}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () =>Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white54),
                )
              ],
            ),

            const SizedBox(height: 8),

            const Text(
              "Indica cuantos comensales se sentaran en la mesa",
              style: TextStyle(color: Colors.white54),
            ),

            const SizedBox(height: 24),

            /// CONTADOR
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _contadorBoton(Icons.remove, () {
                  actualizarCantidad(cantidad - 1);
                }),
                const SizedBox(width: 20),
                Column(
                  children: [
                    Text(
                      cantidad.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "comensales",
                      style: TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                _contadorBoton(Icons.add, () {
                  actualizarCantidad(cantidad + 1);
                }),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              "Capacidad máxima: ${widget.mesa.maximumCapacity} personas",
              style: const TextStyle(color: Colors.white38),
            ),


            // const SizedBox(height: 24),
            /// CAMPOS DINÁMICOS
            // Column(
            //   children: List.generate(cantidad, (index) {
            //     return Padding(
            //       padding: const EdgeInsets.only(bottom: 12),
            //       child: appIntInput(
            //         controller: controllers[index], 
            //         label: "Nombre asistente ${index + 1}"
            //       ),
            //     );
            //   }),
            // ),
            // SizedBox(
            //   height: cantidad * 70,
            //   child: AnimatedList(
            //     key: _listKey,
            //     initialItemCount: cantidad,
            //     itemBuilder: (context, index, animation) {
            //       return _buildAnimatedItem(controllers[index], index, animation);
            //     },
            //   ),
            // ),

            const SizedBox(height: 24),

            /// BOTONES
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  // style: OutlinedButton.styleFrom(
                  //   foregroundColor: Colors.white,
                  //   side: const BorderSide(color: Colors.white24),
                  // ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE49E22),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    final payload = tableOrders(
                      mesaId: widget.mesa.id,
                      number: widget.mesa.number,
                      nombre: widget.mesa.name ?? '',
                      comensales: cantidad,
                    );
                    ref.read(mesaSeleccionadaProvider.notifier).state = payload;
                    context.go('/mesero/registrar_pedido');
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.login),
                  label: const Text("Abrir Mesa"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _contadorBoton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }


}
