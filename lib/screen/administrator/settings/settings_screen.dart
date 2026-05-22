import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:restopos/models/category_model.dart';
import 'package:restopos/models/settings_model.dart';
import 'package:restopos/models/table_model.dart';

import 'package:restopos/providers/category_provider.dart';
import 'package:restopos/providers/settings_provider.dart';
import 'package:restopos/providers/table_provider.dart';

import 'package:restopos/screen/administrator/settings/new_category_widget.dart';
import 'package:restopos/screen/administrator/settings/new_printer_widget.dart';
import 'package:restopos/screen/administrator/settings/new_table_widget.dart';
import 'package:restopos/screen/administrator/settings/table_widget.dart';
import 'package:restopos/widget/side_panel.dart';
import 'package:restopos/widget/app_inputs.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // final _formKey = GlobalKey<FormState>();

  String _text(String? v) => v ?? '';
  String _int(int? v) => (v ?? 0).toString();
  // String _double(double? v) => (v ?? 0).toString();

  final impuestoController = TextEditingController();
  final propinaController = TextEditingController();
  final monedaController = TextEditingController();
  bool descuentosController = false;
  bool redondearTotalesController = false;
  bool impresionController = false;

  // controla si los campos de configuración están en modo edición
  bool editConfig = false;
  
  // filtro de búsqueda para categorías
  String searchMesas = "";

  // Mesas
  final TextEditingController searchController = TextEditingController();

  String zonaSeleccionada = "Todas";

  final zonas = ["Todas", "Interior", "Terraza", "Privado"];


  @override
  void initState() {
    super.initState();
    impuestoController.text = _int(0);
    propinaController.text = _int(0);
    monedaController.text = _text('COP');
    descuentosController = false;
    redondearTotalesController = false;
    impresionController = false;
    searchMesas = "";
  }

  @override
  void dispose() {
    super.dispose();
    impuestoController.dispose();
    propinaController.dispose();
    monedaController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final listCategoria = ref.watch(categoriasListadas);
    final configuraciones = ref.watch(configuracionesListadas);
    final mesas = ref.watch(mesasListadas);
    final Setting? currentConfig = configuraciones.isNotEmpty ? configuraciones.first : null;
    if (configuraciones.isNotEmpty && !editConfig) {
      final config = configuraciones.first;

      impuestoController.text = _int(config.impuesto);
      propinaController.text = _int(config.propina);
      monedaController.text = _text(config.moneda);
      descuentosController = config.descuentos;
      redondearTotalesController = config.redondearTotales;
      impresionController = config.impresion;
    }


    if (currentConfig == null) {
      // still loading settings from service
      return const Scaffold(
        backgroundColor: Color(0xFF05080B),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF05080B),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 900;
            if (isMobile) {
              // MOVIL
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _configCard(),
                    const SizedBox(height: 20),
                    _printersCard(),
                    const SizedBox(height: 20),
                    _categoriesCard(listCategoria),
                    const SizedBox(height: 20),
                    // MesasWidget(),
                  ],
                ),
              );
            }
            else {
              // DESKTOP
              return SingleChildScrollView(
                child:  Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _configCard(),
                          const SizedBox(height: 20),
                          _printersCard(),
                          const SizedBox(height: 20),
                          // MesasWidget(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        children: [
                          _categoriesCard(listCategoria),
                          const SizedBox(height: 20),
                          // MesasWidget(),
                          _tablesCard(mesas),
                        ]
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _configCard() {
    return _darkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configuración General',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ajustes del sistema',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
              const Spacer(),
              if (editConfig)
                TextButton(
                  onPressed: () {
                    editConfig = false;
                    setState(() {});
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
                ),

              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () {
                  if (editConfig) {
                    _guardarConfig();
                  } else {
                    editConfig = true;
                    setState(() {});
                  }
                },
                icon: Icon(editConfig ? Icons.save : Icons.edit),
                label: Text(editConfig ? 'Guardar' : 'Editar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE49E22),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              
            ],
          ),
          const SizedBox(height: 20),

          _inputRow(
            "Impuesto (%IVA)", 
            "Porcentaje aplicado a ventas", 
            impuestoController, 
            editConfig
          ),
          const SizedBox(height: 12),

          _inputRow(
            "Propina sugerida %", 
            "Porcentaje sugerido", 
            propinaController, 
            editConfig
          ),
          const SizedBox(height: 12),

          _inputRow(
            "Modena", 
            "Formato de modena para la facturación", 
            monedaController, 
            false
          ),
          const SizedBox(height: 12),

          _toggleRow(
            "Permitir descuentos", 
            "Se aplicara descuento a ventas", 
            descuentosController, 
            editConfig,
            (v) => setState(() => descuentosController = v),
          ),
          const SizedBox(height: 12),

          _toggleRow(
            "Redondear totales", 
            "Redondear totales de facturas", 
            redondearTotalesController, 
            editConfig,
            (v) => setState(() => redondearTotalesController = v),
          ),
          const SizedBox(height: 20),

          _toggleRow(
            "Impresión automática", 
            "Imprimir tickets al confirmar pedido", 
            impresionController, 
            editConfig,
            (v) => setState(() => impresionController = v),
          ),
        ],
      ),
    );
  }

  Widget _printersCard() {
    return _darkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _title("Impresoras"),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  showSidePanel(
                    context,
                    const NewPrinterForm(),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text("Nueva impresora"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              )
            ],
          ),
          const SizedBox(height: 15),

          _printerTile("Cocina Principal", "192.168.1.100", true),
          const SizedBox(height: 10),
          _printerTile("Caja", "192.168.1.101", true),
          const SizedBox(height: 10),
          _printerTile("Caja", "192.168.1.101", true),
          const SizedBox(height: 10),
          _printerTile("Caja", "192.168.1.101", true),

          const SizedBox(height: 10),
          Text(
            "2 impresoras en total • 2 activas",
            style: TextStyle(color: Colors.grey[500]),
          )
        ],
      ),
    );
  }

  // ---------------- CATEGORIAS ----------------
  Widget _categoriesCard(List<Category> categorias) {
    
    final _random = Random();
    Color getRandomColor() {
      return Color.fromARGB(
        255,
        _random.nextInt(256),
        _random.nextInt(256),
        _random.nextInt(256),
      );
    }
  
    // FILTRAR CATEGORIAS - usa la variable de instancia searchMesas
    final filteredCategory = categorias.where((c) {
      final matchSearch = c.nombre.toLowerCase().contains(searchMesas.toLowerCase());
      return matchSearch;
    }).toList();

    return _darkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _title("Categorías"),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  showSidePanel(
                    context,
                    const NewCategoryForm(),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text("Nueva categoría"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              )
            ],
          ),
          const SizedBox(height: 15),
          TextField(
            onChanged: (value) => setState(() => searchMesas = value),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Buscar categoría...",
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF0E141B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
          
          const SizedBox(height: 15),

          if (filteredCategory.isEmpty)
            const Center(
              child: Text("Sin categorías",
              style: TextStyle(color: Colors.white54)),
            )
          else
            ...filteredCategory.map((categoria) {
              return _categoryTile(
                categoria,
                getRandomColor(),
              );
            }).toList(),

          const SizedBox(height: 10),
          Text(
            "${categorias.length} categorías en total • ${categorias.where((c) => c.activo).length} activas",
            style: const TextStyle(color: Colors.white70),
          )
        ],
      ),
    );
  }

// ---------------- MESAS ----------------
  Widget _tablesCard(List<TableModel> mesas) {
    
    final _random = Random();
    Color getRandomColor() {
      return Color.fromARGB(
        255,
        _random.nextInt(256),
        _random.nextInt(256),
        _random.nextInt(256),
      );
    }
  
    // FILTRAR MESAS - usa la variable de instancia searchMesas
    final filteredMesas = mesas.where((c) {
      final matchSearch = c.name?.toLowerCase().contains(searchMesas.toLowerCase());
      return matchSearch ?? false;
    }).toList();

    return _darkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _title("Mesas"),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  showSidePanel(
                    context,
                    const NewTableForm(),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text("Nueva mesa"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              )
            ],
          ),
          const SizedBox(height: 15),
          TextField(
            onChanged: (value) => setState(() => searchMesas = value),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Buscar mesa...",
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF0E141B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
          
          const SizedBox(height: 15),

          // if (filteredMesas.isEmpty)
          if (mesas.isEmpty)
            const Center(
              child: Text("Sin mesas",
              style: TextStyle(color: Colors.white54)),
            )
          else
            // ...filteredMesas.map((mesa) {
            ...mesas.map((mesa) {
              return _MesasTile(
                mesa,
                getRandomColor(),
              );
            }).toList(),

          const SizedBox(height: 10),
          Text(
            "${mesas.length} mesas en total • ${mesas.where((m) => m.activo).length} activas",
            // "${mesas.length} mesas en total",
            style: const TextStyle(color: Colors.white70),
          )
        ],
      ),
    );

  }


  Widget _darkCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF121820),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: child,
    );
  }

  Widget _title(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18, 
        fontWeight: FontWeight.bold, 
        color: Colors.white
      ),
    );
  }

  Widget _inputRow(String title, String subTitle, TextEditingController value, bool editConfig) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
            Text(
              subTitle,
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        SizedBox(
          width: 60,
          child: TextField(
            controller: value,
            enabled: editConfig,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(
              label: '', 
              hint: '16'
            ),
          ),
          
        ),
      ],
    );
  }

  Widget _toggleRow(String title, String subTitle, bool value, bool enabled, ValueChanged<bool>? onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
            Text(
              subTitle,
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        Switch(
          value: value,
          onChanged: enabled ? onChanged : null,
          activeColor: Colors.amber,
        ),
      ],
    );
  }

  Widget _printerTile(String name, String ip, bool connected) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0F14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE49E22),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: const Icon(Icons.print, size: 22),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name, 
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
              ),
              Text(
                ip,
                style: TextStyle( fontSize: 12, color: Colors.white70)
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: connected ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              connected ? "Conectada" : "Desconectada",
              style: const TextStyle(fontSize: 12, color: Colors.black),
            ),
          ),
          const SizedBox(width: 10),
          Switch(
            value: true,
            onChanged: (_) {},
            activeColor: Colors.amber,
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _categoryTile(Category categoria, Color color) {
    final loading = ref.watch(categoryLoadingProvider(categoria.id));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0F14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            categoria.nombre,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
          ),
          const SizedBox(width: 8),
          Text(
            categoria.numeroProductos == 1 
              ? '${categoria.numeroProductos} producto' 
              : '${categoria.numeroProductos} productos',
            style: TextStyle(color: Colors.white70)
          ),
          const Spacer(),
          Switch(
            value: categoria.activo,
            onChanged: loading
              ? null
              : (value) {
                ref.read(categoryProvider.notifier)
                  .toggleActivo(categoria.id, value, context);
              },
            activeColor: Colors.amber,
          ),
          IconButton(
            onPressed: () {
              ref.read(selectedCategoryProvider.notifier).state = categoria;
              showSidePanel(
                context,
                const NewCategoryForm(),
              );
            },
            icon: const Icon(Icons.edit, color: Colors.white54)
          ),
          IconButton(
            tooltip: 'Eliminar categoria',
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () {
              ref.read(selectedCategoryProvider.notifier).state = categoria;
              _confirmarEliminar('Categoría');
            },
          ),
        ],
      ),
    );
  }
  
  Widget _MesasTile(TableModel mesa, Color color) {
    final loading = ref.watch(categoryLoadingProvider(mesa.id));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0F14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: mesa.number != null 
              ? Text(
                mesa.number.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
              )
              : Text(
                '?',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
              )
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${mesa.name}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
          ),
          const SizedBox(width: 12),
          Icon(Icons.people, color: Colors.white54),
          const SizedBox(width: 4),
          Text(
            mesa.maximumCapacity == 1 
              ? '${mesa.maximumCapacity} persona' 
              : '${mesa.maximumCapacity} personas',
            style: TextStyle(color: Colors.white70)
          ),
          const SizedBox(width: 12),
          Text(
            mesa.status.toString().split('.').last.toUpperCase(),
            style: TextStyle(color: Colors.white70)
          ),
          const Spacer(),
          Switch(
            value: mesa.activo ?? false,
            onChanged: 
            loading
              ? null
              : 
              (value) {
                ref.read(tableProvider.notifier)
                  .toggleActivo(mesa.id, value, context);
              },
            activeColor: Colors.amber,
          ),
          IconButton(
            onPressed: () {
              ref.read(selectedTableProvider.notifier).state = mesa;
              showSidePanel(
                context,
                const NewTableForm(),
              );
            },
            icon: const Icon(Icons.edit, color: Colors.white54)
          ),
          IconButton(
            tooltip: 'Eliminar mesa',
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () {
              ref.read(selectedTableProvider.notifier).state = mesa;
              _confirmarEliminar('Mesa');
            },
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
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
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

  Future<void> _confirmarEliminar(String tipo) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text('Confirmar eliminación'),
            ],
          ),
          content: Text(
            '¿Estás seguro de eliminar esta $tipo?\n\nEsta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      if (tipo == 'Categoría') {
        _eliminarCategoria();
      } else if (tipo == 'Mesa') {
        _eliminarMesa();
      }
    } else {
      ref.read(selectedCategoryProvider.notifier).state = null;
    }
  }

  Future<void> _eliminarCategoria() async {
    final provider = ref.read(categoriasProvider);
    final categoria = ref.read(selectedCategoryProvider);

    if (categoria == null) return;

    final success = await provider.eliminarCategoria(categoria.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Categoria eliminada' : provider.error ?? 'Error'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      ref.invalidate(categoryProvider);
      ref.read(selectedCategoryProvider.notifier).state = null;
      context.go('/admin/settings');
    }
  }

  Future<void> _eliminarMesa() async {
    final provider = ref.read(mesasProvider);
    final mesaDelete = ref.read(selectedTableProvider);

    if (mesaDelete == null) return;

    final success = await provider.eliminarMesa(mesaDelete.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Mesa eliminada' : provider.error ?? 'Error'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      ref.invalidate(tableProvider);
      ref.read(selectedTableProvider.notifier).state = null;
      context.go('/admin/settings');
    }
  }

  Future<void> _guardarConfig() async {
    // if (!_formKey.currentState!.validate()) return;
    final provider = ref.read(settingsProvider);

    final payload = {
      "impuesto": impuestoController.text.trim(),
      "propina": propinaController.text.trim(),
      "moneda": monedaController.text.trim(),
      "descuentos": descuentosController,
      "redondearTotales": redondearTotalesController,
      "impresion": impresionController
    };

    final success = await provider.actualizarSettings(payload);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Configuraciones guardadas correctamente' : provider.error ?? 'Error'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      editConfig = false;
      setState(() {});
    }

  }

}
