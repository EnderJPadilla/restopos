import 'package:flutter/material.dart';
import '../core/services/token_service.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  BuildContext? context;

  void setContext(BuildContext ctx) {
    context = ctx;
  }

  Future<void> showSessionExpiredDialog(Function onLogout) async {
    if (context == null) return;

    await showDialog(
      context: context!,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Sesión caducada'),
        content: const Text(
          'Tu sesión ha expirado. Por favor inicia sesión nuevamente.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await TokenService.clear();
              Navigator.of(context!).pop();
              onLogout();
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}
