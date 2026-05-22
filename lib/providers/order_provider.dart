import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/table_model.dart';


// Mesa seleccionada para pedido
final selectedTableProvider = StateProvider<TableModel?>((ref) => null);