import 'package:flutter/material.dart';
import 'package:restopos/widget/app_inputs.dart';

class NewPrinterForm extends StatefulWidget {
  const NewPrinterForm({super.key});

  @override
  State<NewPrinterForm> createState() => _NewPrinterFormState();
}

class _NewPrinterFormState extends State<NewPrinterForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _ipController = TextEditingController();
  bool activo = true;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: width < 900 ? width * 0.95 : 420, // responsive
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF121820),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18),
          bottomLeft: Radius.circular(18),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(child: _form()),
            _footer(context),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Nueva Impresora",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Configura una nueva impresora para tickets y comandas',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _form() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            appTextInput(
              controller: _nameController,
              label: 'Nombre de la impresora *',
              hint: 'Ej: Impresora principal',
              validator: (v) =>
                v == null || v.isEmpty ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 12),
            appTextInput(
              controller: _ipController,
              label: 'Dirección IP',
              hint: 'Ej: 192.168.10.1',
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: activo,
              onChanged: (v) => setState(() => activo = v),
              activeColor: const Color(0xFFE49E22),
              title: const Text(
                'Habilitada',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              subtitle: const Text(
                'La impresora esta activa y recibira trabajos',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _footer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text("Guardar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE49E22),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      "nombre": _nameController.text,
      "descripcion": _ipController.text,
      "activo": activo,
    };

    debugPrint("Guardar categoría: $data");
    Navigator.pop(context);
  }
}