import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// ─────────────────────────────
/// ESTILOS BASE (NO TOCAR)
/// ─────────────────────────────

const _bgColor = Color(0xFF0B0F14);
const _labelColor = Colors.white70;
const _hintColor = Colors.white38;
const _textColor = Colors.white;
const _errorColor = Colors.redAccent;

final _copFormatter = NumberFormat(
  "'\$ '###,###",
  "es_CO",
);

String formatCOP(num value) {
  return _copFormatter.format(value).trim();
}

double parseCOP(String value) {
  final cleaned = value
    .replaceAll('\$', '')
    .replaceAll('.', '')
    .replaceAll(',', '')
    .trim();

  return double.tryParse(cleaned) ?? 0;
}

/// ─────────────────────────────
/// DECORATION BASE
/// ─────────────────────────────

InputDecoration appDecoration(
  String label, {
  String? hint,
  Widget? suffixIcon,
  bool hasError = false,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: _bgColor,
    labelStyle: const TextStyle(color: _labelColor),
    hintStyle: const TextStyle(color: _hintColor),
    errorStyle: const TextStyle(color: _errorColor, fontSize: 11),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: hasError ? _errorColor : Colors.transparent,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE49E22), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _errorColor),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _errorColor),
    ),
  );
}

/// ─────────────────────────────
/// INPUT BASE (INTERNO)
/// ─────────────────────────────

Widget _baseInput({
  required TextEditingController controller,
  required String label,
  String? hint,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
  String? Function(String?)? validator,
  Widget? suffixIcon,
  bool readOnly = false,
  bool enabled = true,
  int? minLines,
  int maxLines = 1,
  void Function(String)? onChanged,
  void Function()? onTap,
  bool obscureText = false,
}) {
  return TextFormField(
    controller: controller,
    enabled: enabled,
    readOnly: readOnly,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    validator: validator,
    onChanged: onChanged,
    onTap: onTap,
    minLines: minLines,
    maxLines: maxLines,
    style: const TextStyle(color: _textColor),
    decoration: appDecoration(label, hint: hint, suffixIcon: suffixIcon),
    obscureText: obscureText,
  );
}

/// ─────────────────────────────
/// INPUT TEXTO SIMPLE
/// ─────────────────────────────

Widget appTextInput({
  required TextEditingController controller,
  required String label,
  String? hint,
  String? Function(String?)? validator,
  int? minLines,
  int? maxLines,
  TextInputType? keyboardType,
}) {
  return _baseInput(
    controller: controller,
    label: label,
    hint: hint,
    validator: validator,
    keyboardType: keyboardType,
    minLines: minLines,
    maxLines: maxLines ?? 1,
  );
}


/// ─────────────────────────────
/// INPUT PASSWORD
/// ─────────────────────────────

Widget appPasswordInput({
  required TextEditingController controller,
  required String label,
  String? hint,
  String? Function(String?)? validator,
  TextInputType? keyboardType,
  Widget? suffix,
  bool obscureText = false,
}) {
  return _baseInput(
    controller: controller,
    label: label,
    hint: hint,
    validator: validator,
    keyboardType: keyboardType,
    suffixIcon: suffix,
    obscureText: obscureText,
  );
}

/// ─────────────────────────────
/// INPUT NUMÉRICO ENTERO
/// ─────────────────────────────

Widget appIntInput({
  required TextEditingController controller,
  required String label,
  String? hint,
  String? Function(String?)? validator,
  bool enabled = true,
}) {
  return _baseInput(
    controller: controller,
    label: label,
    hint: hint,
    enabled: enabled,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    validator: validator,
  );
}

/// ─────────────────────────────
/// INPUT NUMÉRICO DECIMAL
/// ─────────────────────────────

Widget appDecimalInput({
  required TextEditingController controller,
  required String label,
  String? hint,
  String? Function(String?)? validator,
  void Function(double)? onChangedValue,
}) {
  return _baseInput(
    controller: controller,
    label: label,
    hint: hint,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [
      FilteringTextInputFormatter.allow(
        RegExp(r'^\d{0,3}(\.\d{0,2})?$'),
      ),
    ],
    validator: validator,
    onChanged: (v) {
      onChangedValue?.call(double.tryParse(v) ?? 0);
    },
  );
}


/// ─────────────────────────────
/// INPUT MONEDA $
// ─────────────────────────────

Widget appMoneyInput({
  required TextEditingController controller,
  required String label,
  String? Function(String?)? validator,
  void Function(double)? onValueChanged,
}) {
  return Focus(
    onFocusChange: (hasFocus) {
      if (!hasFocus) {
        final value = parseCOP(controller.text);
        controller.text = value > 0 ? formatCOP(value) : '';
        onValueChanged?.call(value);
      }
    },
    child: _baseInput(
      controller: controller,
      label: label,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      // suffixIcon: const Padding(
      //   padding: EdgeInsets.only(right: 12),
      //   child: Text('\$', style: TextStyle(color: Colors.white70)),
      // ),
      validator: validator,
      onChanged: (value) {
        onValueChanged?.call(parseCOP(value));
      },
    ),
  );
}


/// ─────────────────────────────
/// INPUT FECHA
/// ─────────────────────────────

Widget appDateInput({
  required BuildContext context,
  required TextEditingController controller,
  required String label,
  required void Function(DateTime) onDateSelected,
}) {
  return _baseInput(
    controller: controller,
    label: label,
    readOnly: true,
    suffixIcon: const Icon(Icons.calendar_today, color: Colors.white70),
    onTap: () async {
      final date = await showDatePicker(
        context: context,
        // locale: const Locale('es', 'CO'),
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
      );
      if (date != null) {
        controller.text =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
        onDateSelected(date);
      }
    },
  );
}

/// ─────────────────────────────
/// INPUT READONLY
/// ─────────────────────────────

Widget appReadonlyInput({
  required TextEditingController controller,
  required String label,
}) {
  return _baseInput(
    controller: controller,
    label: label,
    readOnly: true,
    enabled: false,
  );
}

/// ─────────────────────────────
/// INPUT SEARCH CON DEBOUNCE
/// ─────────────────────────────

class AppSearchInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final Duration debounceTime;
  final void Function(String) onSearch;

  const AppSearchInput({
    super.key,
    required this.controller,
    required this.label,
    required this.onSearch,
    this.debounceTime = const Duration(milliseconds: 500),
  });

  @override
  State<AppSearchInput> createState() => _AppSearchInputState();
}

class _AppSearchInputState extends State<AppSearchInput> {
  Timer? _debounce;

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(widget.debounceTime, () {
      widget.onSearch(value);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _baseInput(
      controller: widget.controller,
      label: widget.label,
      suffixIcon: const Icon(Icons.search, color: Colors.white70),
      onChanged: _onChanged,
    );
  }
}
