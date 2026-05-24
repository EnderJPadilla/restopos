import 'dart:async';
import 'package:flutter/material.dart';

class LiveOrderTime extends StatefulWidget {
  final String createdAt;

  const LiveOrderTime({
    super.key,
    required this.createdAt,
  });

  @override
  State<LiveOrderTime> createState() => _LiveOrderTimeState();
}

class _LiveOrderTimeState extends State<LiveOrderTime> {
  late Timer _timer;
  late DateTime fechaPedido;

  @override
  void initState() {
    super.initState();

    fechaPedido = DateTime.parse(widget.createdAt);

    // refresca cada segundo
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  String get tiempoTranscurrido {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fechaPedido);

    final horas = diferencia.inHours;
    final minutos = diferencia.inMinutes.remainder(60);
    final segundos = diferencia.inSeconds.remainder(60);

    return '${horas.toString().padLeft(2, '0')}:'
      '${minutos.toString().padLeft(2, '0')}:'
      '${segundos.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      tiempoTranscurrido,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 12,
      ),
    );
  }
}