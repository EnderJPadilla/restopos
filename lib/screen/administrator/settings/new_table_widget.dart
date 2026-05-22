import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restopos/models/table_model.dart';
import 'package:restopos/providers/table_provider.dart';
import 'package:restopos/widget/app_inputs.dart';


class NewTableForm extends ConsumerStatefulWidget {
  const NewTableForm({super.key});

  @override
  ConsumerState<NewTableForm> createState() => _NewTableFormState();
}

class _NewTableFormState extends ConsumerState<NewTableForm> {
  final _formKey = GlobalKey<FormState>();
  
  String _text(String? v) => v ?? '';

  int number = 0;
  final numberController = TextEditingController();
  final nameController = TextEditingController();
  final maximumCapacity = TextEditingController();
  TableStatus? status = TableStatus.disponible;
  bool activo = true;
  bool booking = true;
  bool _isValidatingTable = false;
  final FocusNode _NumberFocusNode = FocusNode();
  final FocusNode _NameFocusNode = FocusNode();
  String _lastValidatedNumber = '';
  
  // modo editar
  bool isEditMode = false;
  String? tableId;

  
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final mesa = ref.read(selectedTableProvider);

      if (mesa == null) {
        _resetForm();
        return;
      }

      if (mesa != null) {
        _cargarFrom(mesa);
        return;
      }
    });

    _NumberFocusNode.addListener(_onNumberFocusChange);
    _NameFocusNode.addListener(_onNameFocusChange);
  }

  void _onNumberFocusChange() {
    final table = ref.read(selectedTableProvider);
    if (!_NumberFocusNode.hasFocus) {
      final number = numberController.text.trim().isEmpty ? 0 : int.parse(numberController.text.trim());

      if (number <= 0) return;
      // if (number == _lastValidatedNumber) return;

      // Only validate when not editing or name has changed from the original
      if (!isEditMode || table == null || table.number != number) {
        _validateMesa('number');
      }
    }
  }
  void _onNameFocusChange() {
    final table = ref.read(selectedTableProvider);
    if (!_NameFocusNode.hasFocus) {
      final name = nameController.text.trim();

      // Only validate when not editing or name has changed from the original
      if (!isEditMode || table == null || table.name != name) {
        _validateMesa('name');
      }
    }
  }

  void _resetForm() {
    numberController.clear();
    nameController.clear();
    maximumCapacity.text = '0';
    activo = true;
    booking = true;
    // Edit mode
    isEditMode = false;
    tableId = null;
    setState(() {});
  }

  void _cargarFrom(table) {
    isEditMode = true;
    tableId = table.id;
    nameController.text = _text(table.nombre);
    numberController.text = _text(table.numero?.toString());
    maximumCapacity.text = _text(table.habilidad?.toString());
    activo = table.activo;
    booking = table.booking ?? true;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

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
              Text(
                isEditMode ? "Editar Mesa" : "Nueva Mesa",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Completa los datos para crear una nueva mesa',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              ref.read(selectedTableProvider.notifier).state = null;
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close, color: Colors.white),
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
            TextField(
              controller: numberController,
              keyboardType: TextInputType.number,
              focusNode: _NumberFocusNode,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              textInputAction: TextInputAction.next,
              style: const TextStyle(color: Colors.white),
              onSubmitted: (_) {
                if (!isEditMode && int.parse(numberController.text.trim()) > 0) {
                  _validateMesa('number');
                  FocusScope.of(context).nextFocus();
                }
              },
              decoration: _inputDecoration(
                label: 'Número de mesa *', 
                hint: 'Ej: 1, 2, 3...'
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              focusNode: _NameFocusNode,
              textInputAction: TextInputAction.next,
              style: const TextStyle(color: Colors.white),
              onSubmitted: (_) {
                if (!isEditMode && nameController.text.trim().length >= 5) {
                  _validateMesa('name');
                  FocusScope.of(context).nextFocus();
                }
              },
              decoration: _inputDecoration(
                label: 'Nombre de la mesa *', 
                hint: 'Ej: Mesa 1'
              ),
            ),
            const SizedBox(height: 12),
            _EstatusTableDropdown(),
            const SizedBox(height: 12),
            TextField(
              controller: maximumCapacity,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              textInputAction: TextInputAction.done,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                label: 'Capacidad máxima', 
                hint: 'Ej: 4 personas'
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: activo,
              onChanged: (v) => setState(() => activo = v),
              activeColor: const Color(0xFFE49E22),
              title: const Text(
                'Estado',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              subtitle: const Text(
                'Visible y Activa',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: booking,
              onChanged: (v) => setState(() => booking = v),
              activeColor: const Color(0xFFE49E22),
              title: const Text(
                'Estado',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              subtitle: const Text(
                'Permitir reservas',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ─────────────────────────────
  /// DROPDOWN ESTATUS TABLE
  /// ─────────────────────────────
  Widget _EstatusTableDropdown() {
    return DropdownButtonFormField<TableStatus>(
      value: status,
      items: TableStatus.values
        .map(
          (c) => DropdownMenuItem<TableStatus>(
            value: c,
            child: Text(c.name, style: const TextStyle(color: Colors.white)),
          ),
        )
        .toList(),
      onChanged: (v) => setState(() => status = v),
      validator: (v) =>
        v == null ? 'Seleccione...' : null,
      decoration: appDecoration('Estatus *'),
      dropdownColor: const Color(0xFF0B0F14),
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
              onPressed: () {
                ref.read(selectedTableProvider.notifier).state = null;
                Navigator.pop(context);
              },
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
              onPressed: _guardar,
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

  Future<void> _validateMesa(String type) async {
    if (_isValidatingTable) return;

    int numberMesa = numberController.text.trim().isEmpty ? 0 : int.parse(numberController.text.trim());
    String nameMesa = nameController.text.trim();
    if (type == 'name' && nameMesa.length < 5) return;

    _isValidatingTable = true;
    // _lastValidatedMesa = nameMesa;

    try {
      final provider = ref.read(tableProvider.notifier);
      
      if (type == 'number') {
        final success = await provider.validateTableNumber(numberMesa, context);
        if (!success) {
          numberController.text = '';
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Número de mesa no disponible. Ya existe una Mesa con el número: $numberMesa'
              ),
              backgroundColor: Colors.red
            ),
          );
        }
      } else if (type == 'name') {
        
        final success = await provider.validateTableName(nameMesa, context);
        if (!success) {
          nameController.text = '';
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Nombre de la mesa no disponible. Ya existe una Mesa con el nombre: $nameMesa'
              ),
              backgroundColor: Colors.red
            ),
          );
        }

      }

      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al validar el nombre de la mesa.'),
          backgroundColor: Colors.red
        ),
      );
    } finally {
      _isValidatingTable = false;
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = ref.read(mesasProvider);

    final payload = {
      'id': tableId,
      'number': int.parse(numberController.text.trim()),
      'name': nameController.text.trim(),
      'maximumCapacity': int.parse(maximumCapacity.text.trim()),
      'status': status?.name,
      'activo': activo,
      'booking': booking,
    };

    final success = isEditMode
      ? await provider.actualizarMesa(payload)
      : await provider.crearMesa(payload);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Mesa guardada correctamente' : provider.error ?? 'Error'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      ref.invalidate(tableProvider);
      Navigator.pop(context);
    }
  }





}