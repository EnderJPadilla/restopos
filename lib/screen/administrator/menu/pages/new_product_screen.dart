import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:restopos/models/category_model.dart';
import 'package:restopos/providers/product_provider.dart';
import 'package:restopos/providers/menu_provider.dart';
import 'package:restopos/providers/category_provider.dart';

import '../tabs/general_tab.dart';
import '../tabs/prices_tab.dart';
import '../tabs/inventory_tab.dart';
import '../tabs/preparation_tab.dart';
import '../tabs/presentation_tab.dart';
import 'package:restopos/widget/app_inputs.dart';

class NewProduct extends ConsumerStatefulWidget {
  const NewProduct({super.key});

  @override
  ConsumerState<NewProduct> createState() => _NewProductState();
}

class _NewProductState extends ConsumerState<NewProduct> {
  final _formKey = GlobalKey<FormState>();

  String _text(String? v) => v ?? '';
  String _int(int? v) => (v ?? 0).toString();
  String _double(double? v) => (v ?? 0).toString();

  // General
  final nombreController = TextEditingController();
  final skuController = TextEditingController();
  final barcodeController = TextEditingController();
  final descripcionCortaController = TextEditingController();
  final descripcionCompletaController = TextEditingController();
  final tagController = TextEditingController();

  String? iconoProductoSeleccionado;
  Category? categoriaSeleccionada;
  bool disponible = true;
  final List<String> tags = [];
  // Las categorías se obtienen desde el provider en `build()` como `List<Category>`.

  // Prices
  final costoController = TextEditingController();
  final precioVentaController = TextEditingController();
  bool impuestoIncluido = true;
  final impuestoController = TextEditingController(text: '15');
  final precioDespuesImpuestoController = TextEditingController();
  final precioEspecialController = TextEditingController();
  DateTime? fechaInicioPromo;
  DateTime? fechaFinPromo;

  // Inventory
  bool controlarInventario = false;
  final stockController = TextEditingController();
  final alertaStockController = TextEditingController();
  String unidadMedida = 'Pieza';

  // Preparation
  final tiempoPreparacionController = TextEditingController();
  String? areaPreparacionSeleccionada;
  String? impresoraSeleccionada;
  final notasPreparacionController = TextEditingController();

  final areasPreparacion = ['Cocina', 'Barra', 'Bebidas', 'Parrilla', 'Postres'];
  final impresoras = ['Cocina', 'Barra', 'Caja'];

  // Presentation
  bool destacado = false;
  bool mostrarEnPos = true;
  bool mostrarEnMenuOnline = true;

  // modo editar
  bool isEditMode = false;
  String? productoId;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final producto = ref.read(selectedProductProvider);

      if (producto == null) {
        _resetForm();
        return;
      }

      if (producto != null) {
        _cargarFrom(producto);
        return;
      }
    });
  }

  void _resetForm() {
    // General
    nombreController.clear();
    skuController.clear();
    barcodeController.clear();
    descripcionCortaController.clear();
    descripcionCompletaController.clear();
    tagController.clear();

    iconoProductoSeleccionado = null;
    categoriaSeleccionada = null;
    disponible = true;
    tags.clear();

    // Prices
    costoController.clear();
    precioVentaController.clear();
    impuestoController.text = '16';
    precioDespuesImpuestoController.clear();
    precioEspecialController.clear();
    impuestoIncluido = true;
    fechaInicioPromo = null;
    fechaFinPromo = null;

    // Inventory
    controlarInventario = false;
    stockController.clear();
    alertaStockController.clear();
    unidadMedida = 'Pieza';

    // Preparation
    tiempoPreparacionController.clear();
    areaPreparacionSeleccionada = null;
    impresoraSeleccionada = null;
    notasPreparacionController.clear();

    // Presentation
    destacado = false;
    mostrarEnPos = true;
    mostrarEnMenuOnline = true;

    // Edit mode
    isEditMode = false;
    productoId = null;

    setState(() {});
  }

  void _cargarFrom(producto) {
    isEditMode = true;
    productoId = producto.id;

    nombreController.text = _text(producto.nombre);
    skuController.text = _text(producto.sku);
    barcodeController.text = _text(producto.barcode);
    descripcionCortaController.text = _text(producto.descripcionCorta);
    descripcionCompletaController.text = _text(producto.descripcion);
    final categorias = ref.read(categoriasListadas);
    if (categorias.isNotEmpty) {
      categoriaSeleccionada = categorias.firstWhere(
        (c) => c.nombre == producto.categoria,
        orElse: () => categorias.first,
      );
    } else {
      categoriaSeleccionada = null;
    }
    iconoProductoSeleccionado = producto.icono;
    disponible = producto.disponible;
    tags
      ..clear()
      ..addAll(producto.tags);

    costoController.text = _double(producto.costo);
    precioVentaController.text = _double(producto.precio);
    impuestoIncluido = producto.impuestoIncluido;
    impuestoController.text = _int(producto.tasaImpuesto);
    precioDespuesImpuestoController.text = _double(producto.precioDespuesImpuesto);
    precioEspecialController.text = _double(producto.precioEspecial);

    controlarInventario = producto.controlarInventario;
    stockController.text = _int(producto.stockActual);
    alertaStockController.text = _int(producto.stockMinimo);
    // unidadMedida = _text(producto.unidadMedida) ?? 'Pieza';
    if (producto.unidadMedida != null && producto.unidadMedida == '') {
      unidadMedida = producto.unidadMedida;
    } else {
      unidadMedida = 'Pieza';
    }

    tiempoPreparacionController.text = _int(producto.tiempoPreparacion);
    if (producto.areaPreparacion != null && areasPreparacion.contains(producto.areaPreparacion)) {
      areaPreparacionSeleccionada = producto.areaPreparacion;
    } else {
      areaPreparacionSeleccionada = null;
    }
    impresoraSeleccionada = producto.impresoras.isNotEmpty
      ? producto.impresoras.first
      : null;
    notasPreparacionController.text = _text(producto.notasPreparacion);

    destacado = producto.destacado;
    mostrarEnPos = producto.mostrarPos;
    mostrarEnMenuOnline = producto.mostrarOnline;

    setState(() {});
  }


  @override
  void dispose() {
    nombreController.dispose();
    skuController.dispose();
    barcodeController.dispose();
    descripcionCortaController.dispose();
    descripcionCompletaController.dispose();
    tagController.dispose();
    precioVentaController.dispose();
    costoController.dispose();
    impuestoController.dispose();
    precioDespuesImpuestoController.dispose();
    precioEspecialController.dispose();
    stockController.dispose();
    alertaStockController.dispose();
    tiempoPreparacionController.dispose();
    notasPreparacionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categorias = ref.watch(categoriasListadas);

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditMode ? 'Editar Producto' : 'Nuevo Producto',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              const Text(
                'Complete la información del producto',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          actions: [
            if (isEditMode)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                tooltip: 'Eliminar producto',
                onPressed: _confirmarEliminarProducto,
              ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                ref.read(selectedProductProvider.notifier).state = null;
                isEditMode = false;
                context.go('/admin/menu');
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white70)
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _guardarProducto,
              icon: const Icon(Icons.save),
              label: Text(isEditMode ? 'Actualizar' : 'Guardar Producto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE49E22),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),

        body: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _tabs(),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: TabBarView(
                  children: [
                    GeneralTab(
                      nombreController: nombreController,
                      skuController: skuController,
                      barcodeController: barcodeController,
                      descripcionCortaController: descripcionCortaController,
                      descripcionCompletaController: descripcionCompletaController,
                      tagController: tagController,
                      categorias: categorias,
                      categoriaSeleccionada: categoriaSeleccionada,
                      disponible: disponible,
                      tags: tags,
                      onCategoriaChanged: (v) => setState(() => categoriaSeleccionada = v),
                      onDisponibleChanged: (v) => setState(() => disponible = v),
                      iconoSeleccionado: iconoProductoSeleccionado,
                      onIconoChanged: (v) => setState(() => iconoProductoSeleccionado = v),
                      onAddTag: _addTag,
                      onRemoveTag: _removeTag,
                    ),

                    PricesTab(
                      precioVentaController: precioVentaController,
                      costoController: costoController,
                      impuestoController: impuestoController,
                      precioDespuesImpuestoController: precioDespuesImpuestoController,
                      precioEspecialController: precioEspecialController,
                      fechaInicioPromo: fechaInicioPromo,
                      fechaFinPromo: fechaFinPromo,
                      impuestoIncluido: impuestoIncluido,
                      onFechaInicioChanged: (v) => setState(() => fechaInicioPromo = v),
                      onFechaFinChanged: (v) => setState(() => fechaFinPromo = v),
                      onImpuestoIncluidoChanged: (v) => setState(() => impuestoIncluido = v),
                    ),

                    InventoryTab(
                      controlarInventario: controlarInventario,
                      onControlarInventarioChanged: (v) => setState(() => controlarInventario = v),
                      stockController: stockController,
                      alertaStockController: alertaStockController,
                      unidadMedida: unidadMedida,
                      onUnidadMedidaChanged: (v) => setState(() => unidadMedida = v ?? 'Pieza'),
                    ),

                    PreparationTab(
                      tiempoPreparacionController: tiempoPreparacionController,
                      areaPreparacionSeleccionada: areaPreparacionSeleccionada,
                      impresoraSeleccionada: impresoraSeleccionada,
                      notasPreparacionController: notasPreparacionController,
                      areasPreparacion: areasPreparacion,
                      impresoras: impresoras,
                      onAreaPreparacionChanged: (v) => setState(() => areaPreparacionSeleccionada = v),
                      onImpresoraChanged: (v) => setState(() => impresoraSeleccionada = v),
                    ),

                    PresentationTab(
                      destacado: destacado,
                      mostrarEnPos: mostrarEnPos,
                      mostrarEnMenuOnline: mostrarEnMenuOnline,
                      onDestacadoChanged: (v) => setState(() => destacado = v),
                      onMostrarEnPosChanged: (v) => setState(() => mostrarEnPos = v),
                      onMostrarEnMenuOnlineChanged: (v) => setState(() => mostrarEnMenuOnline = v),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabs() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 600,
        height: 50,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF121821),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const TabBar(
          isScrollable: true,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: Color(0xEC0B0F14),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          tabs: [
            Tab(text: 'General'),
            Tab(text: 'Precios'),
            Tab(text: 'Inventario'),
            Tab(text: 'Preparación'),
            Tab(text: 'Presentación'),
          ],
        ),
      ),
    );
  }

  void _addTag(String value) {
    final tag = value.trim();
    if (tag.isNotEmpty && !tags.contains(tag)) {
      setState(() {
        tags.add(tag);
        tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() => tags.remove(tag));
  }

  Future<void> _guardarProducto() async {
    final provider = ref.read(productProvider);

    final payload = _buildProductPayload();

    final success = isEditMode
      ? await provider.actualizarProducto(payload)
      : await provider.crearProducto(payload);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Producto guardado correctamente' : provider.error ?? 'Error'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      ref.invalidate(productosProvider);
      context.go('/admin/menu');
    }
  }

  Map<String, dynamic> _buildProductPayload() {
    return {
      'producto': {
        'id': productoId,
        'nombre': nombreController.text.trim(),
        'sku': skuController.text.trim(),
        'barcode': barcodeController.text.trim(),
        'categoria': categoriaSeleccionada?.nombre,
        'descripcion_corta': descripcionCortaController.text.trim(),
        'descripcion_completa': descripcionCompletaController.text.trim(),
        'icono': iconoProductoSeleccionado,
        'disponible': disponible,
        'destacado': destacado,
        'mostrar_pos': mostrarEnPos,
        'mostrar_online': mostrarEnMenuOnline,
      },
      'precios': {
        'costo': parseCOP(costoController.text),
        'precio_venta': parseCOP(precioVentaController.text),
        'impuesto': double.tryParse(impuestoController.text) ?? 0,
        'impuesto_incluido': impuestoIncluido,
        'precio_con_impuesto': parseCOP(precioDespuesImpuestoController.text),
        'precio_especial': parseCOP(precioEspecialController.text),
        'promo_inicio': fechaInicioPromo?.toIso8601String(),
        'promo_fin': fechaFinPromo?.toIso8601String(),
      },
      'inventario': {
        'controlar': controlarInventario,
        'stock_actual': int.tryParse(stockController.text) ?? 0,
        'stock_minimo': int.tryParse(alertaStockController.text) ?? 0,
        'unidad_medida': unidadMedida,
      },
      'preparacion': {
        'tiempo': int.tryParse(tiempoPreparacionController.text) ?? 0,
        'area': areaPreparacionSeleccionada,
        'impresoras': impresoraSeleccionada,
        'notas': notasPreparacionController.text.trim(),
      },
      'tags': tags,
    };
  }

  Future<void> _confirmarEliminarProducto() async {
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
          content: const Text(
            '¿Estás seguro de eliminar este producto?\n\nEsta acción no se puede deshacer.',
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
      _eliminarProducto();
    }
  }

  Future<void> _eliminarProducto() async {
    final provider = ref.read(productProvider);

    if (productoId == null) return;

    final success = await provider.eliminarProducto(productoId!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Producto eliminado' : provider.error ?? 'Error'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      ref.invalidate(productosProvider);
      ref.read(selectedProductProvider.notifier).state = null;
      context.go('/admin/menu');
    }
  }



}
