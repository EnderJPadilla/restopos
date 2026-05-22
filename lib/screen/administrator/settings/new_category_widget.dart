import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restopos/providers/category_provider.dart';
import 'package:restopos/widget/app_inputs.dart';

class NewCategoryForm extends ConsumerStatefulWidget {
  const NewCategoryForm({super.key});

  @override
  ConsumerState<NewCategoryForm> createState() => _NewCategoryFormState();
}

class _NewCategoryFormState extends ConsumerState<NewCategoryForm> {
  final _formKey = GlobalKey<FormState>();
  
  String _text(String? v) => v ?? '';

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final FocusNode _categoriaFocusNode = FocusNode();
  bool activo = true;
  bool _isValidatingUser = false;
  String _lastValidatedCategoria = '';
  
  // modo editar
  bool isEditMode = false;
  String? categoriaId;

  
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final categoria = ref.read(selectedCategoryProvider);

      if (categoria == null) {
        _resetForm();
        return;
      }

      if (categoria != null) {
        _cargarFrom(categoria);
        return;
      }
    });

    _categoriaFocusNode.addListener(_onUsuarioFocusChange);
  }

  void _onUsuarioFocusChange() {
    final categoria = ref.read(selectedCategoryProvider);
    if (!_categoriaFocusNode.hasFocus) {
      final text = _nameController.text.trim();

      if (text.length < 5) return;
      if (text == _lastValidatedCategoria) return;

      // Only validate when not editing or name has changed from the original
      if (!isEditMode || categoria == null || categoria.nombre != _nameController.text) {
        _validateCategoria();
      }
    }
  }

  void _resetForm() {
    _nameController.clear();
    _descController.clear();
    activo = true;
    // Edit mode
    isEditMode = false;
    categoriaId = null;
    setState(() {});
  }

  void _cargarFrom(categoria) {
    isEditMode = true;
    categoriaId = categoria.id;
    _nameController.text = _text(categoria.nombre);
    _descController.text = _text(categoria.descripcion);
    activo = categoria.activo;
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
                isEditMode ? "Editar Categoria" : "Nueva Categoria",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Completa los datos para crear una nueva categoria',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              ref.read(selectedCategoryProvider.notifier).state = null;
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
              controller: _nameController,
              focusNode: _categoriaFocusNode,
              textInputAction: TextInputAction.next,
              style: const TextStyle(color: Colors.white),
              onSubmitted: (_) {
                if (!isEditMode && _nameController.text.trim().length >= 5) {
                  _validateCategoria();
                  FocusScope.of(context).nextFocus();
                }
              },
              decoration: _inputDecoration(
                label: 'Nombre de la categoría *', 
                hint: 'Ej: Platos fuertes'
              ),
            ),
            const SizedBox(height: 12),
            appTextInput(
              controller: _descController,
              label: 'Descripción',
              hint: 'Ej: Descripción breve de esta categoria...',
              maxLines: 4,
              minLines: 3,
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
              onPressed: () {
                ref.read(selectedCategoryProvider.notifier).state = null;
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

  Future<void> _validateCategoria() async {
    if (_isValidatingUser) return;

    final nameCategoria = _nameController.text.trim();
    if (nameCategoria.length < 5) return;
    if (nameCategoria == _lastValidatedCategoria) return;

    _isValidatingUser = true;
    _lastValidatedCategoria = nameCategoria;

    try {
      final provider = ref.read(categoryProvider.notifier);
      final success = await provider.validateCategoryName(nameCategoria, context);

      if (!success) {
        _nameController.text = '';
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Nombre de la categoria no disponible. Ya existe una Cateroria con el nombre: $nameCategoria'
            ),
            backgroundColor: Colors.red
          ),
        );
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al validar el nombre de la categoria.'),
          backgroundColor: Colors.red
        ),
      );
    } finally {
      _isValidatingUser = false;
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = ref.read(categoriasProvider);

    final payload = {
      "categoria_id": categoriaId,
      "nombre": _nameController.text,
      "descripcion": _descController.text,
      "activo": activo,
    };

    final success = isEditMode
      ? await provider.actualizarCategoria(payload)
      : await provider.crearCategoria(payload);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Categoria guardada correctamente' : provider.error ?? 'Error'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      ref.invalidate(categoryProvider);
      Navigator.pop(context);
    }
  }
}